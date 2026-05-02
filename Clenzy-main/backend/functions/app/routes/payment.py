import os
from datetime import datetime
import razorpay
from fastapi import APIRouter, Depends, HTTPException, status
from pydantic import BaseModel
from sqlalchemy.orm import Session
from .. import models, schemas, auth
from ..database import get_db

router = APIRouter()

RAZORPAY_KEY_ID = os.getenv("RAZORPAY_KEY_ID", "rzp_test_SOLxtzwnLqUA87")
RAZORPAY_KEY_SECRET = os.getenv("RAZORPAY_KEY_SECRET", "qRO6OncNl0v9nZUiywaQ3Oct")

razorpay_client = razorpay.Client(auth=(RAZORPAY_KEY_ID, RAZORPAY_KEY_SECRET))

PAYMENT_SUCCESS = "success"
PAYMENT_FAILED = "failed"
PAYMENT_PENDING = "pending"

def calculate_payout(amount: float):
    platform_fee = int(amount * 0.15)
    worker_amount = amount - platform_fee
    return platform_fee, worker_amount

class OrderRequest(BaseModel):
    amount: float
    currency: str = 'INR'
    job_id: int
    user_id: int

class VerifyPaymentRequest(BaseModel):
    razorpay_order_id: str
    razorpay_payment_id: str
    razorpay_signature: str

class RefundRequest(BaseModel):
    razorpay_payment_id: str

@router.post("/create-order")
async def create_order(request: OrderRequest, db: Session = Depends(get_db)):
    try:
        user = db.query(models.User).filter(models.User.id == request.user_id).first()
        if not user:
            raise HTTPException(status_code=404, detail="User not found")

        job = db.query(models.Job).filter(models.Job.id == request.job_id).first()
        if not job:
            raise HTTPException(status_code=404, detail="Job not found")

        amount_paise = int(request.amount * 100)
        data = {
            "amount": amount_paise,
            "currency": request.currency,
            "receipt": f"job_{request.job_id}_user_{request.user_id}"
        }
        order = razorpay_client.order.create(data=data)

        new_payment = models.Payment(
            job_id=request.job_id,
            user_id=request.user_id,
            razorpay_order_id=order['id'],
            amount=request.amount,
            currency=request.currency,
            payment_status=PAYMENT_PENDING
        )
        db.add(new_payment)
        db.commit()
        db.refresh(new_payment)

        return {
            "orderId": order['id'],
            "amount": request.amount,
            "currency": request.currency,
            "key": RAZORPAY_KEY_ID
        }
    except HTTPException:
        raise
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=400, detail=str(e))

@router.post("/verify-payment")
async def verify_payment(request: VerifyPaymentRequest, db: Session = Depends(get_db)):
    try:
        payment = db.query(models.Payment).filter(
            models.Payment.razorpay_order_id == request.razorpay_order_id
        ).first()

        if not payment:
            raise HTTPException(status_code=404, detail="Payment record not found")

        if payment.payment_status == PAYMENT_SUCCESS:
            return {"status": "already_verified"}

        params_dict = {
            'razorpay_order_id': request.razorpay_order_id,
            'razorpay_payment_id': request.razorpay_payment_id,
            'razorpay_signature': request.razorpay_signature
        }

        try:
            razorpay_client.utility.verify_payment_signature(params_dict)
        except Exception:
            payment.payment_status = PAYMENT_FAILED
            db.commit()
            raise HTTPException(status_code=400, detail="Invalid payment signature")

        payment.payment_status = PAYMENT_SUCCESS
        payment.razorpay_payment_id = request.razorpay_payment_id
        payment.razorpay_signature = request.razorpay_signature
        
        platform_fee, worker_amount = calculate_payout(payment.amount)
        payment.platform_fee = platform_fee
        payment.worker_amount = worker_amount
        
        payment_details = razorpay_client.payment.fetch(request.razorpay_payment_id)
        payment.payment_method = payment_details.get("method")
        
        # We need worker_id to create payout. Since job_id might point to a worker:
        job = db.query(models.Job).filter(models.Job.id == payment.job_id).first()
        worker_id = job.worker_id if job and job.worker_id else payment.user_id
        
        payout = models.Payout(
            worker_id=worker_id,
            payment_id=payment.id,
            worker_amount=worker_amount,
            payout_status="pending"
        )
        db.add(payout)
        db.commit()
        
        return {
            "status": "success",
            "message": "Payment verified successfully",
            "payment_id": payment.id,
            "worker_amount": worker_amount
        }
    except HTTPException:
        raise
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=400, detail=str(e))

@router.post("/refund")
def refund(request: RefundRequest, db: Session = Depends(get_db)):
    try:
        payment = db.query(models.Payment).filter(
            models.Payment.razorpay_payment_id == request.razorpay_payment_id
        ).first()
        
        if not payment:
            raise HTTPException(status_code=404, detail="Payment not found")
        
        if payment.payment_status not in [PAYMENT_SUCCESS, PAYMENT_PENDING]:
            raise HTTPException(status_code=400, detail="Cannot refund payment in current status")
        
        razorpay_client.payment.refund(request.razorpay_payment_id)
        payment.payment_status = "refunded"
        db.commit()
            
        return {
            "status": "success",
            "message": "Refund initiated successfully",
            "payment_id": payment.id
        }
    except HTTPException:
        raise
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=400, detail=str(e))
