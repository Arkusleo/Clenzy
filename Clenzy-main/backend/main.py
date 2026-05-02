import os
import json
import hmac
import hashlib
from datetime import datetime
import razorpay
from fastapi import FastAPI, HTTPException, Depends, Request
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from sqlalchemy.orm import Session
from dotenv import load_dotenv

from database import engine, Base, get_db
import models

load_dotenv()

# Create tables if they don't exist
Base.metadata.create_all(bind=engine)

RAZORPAY_KEY_ID = os.getenv("RAZORPAY_KEY_ID")
RAZORPAY_KEY_SECRET = os.getenv("RAZORPAY_KEY_SECRET")
WEBHOOK_SECRET = os.getenv("WEBHOOK_SECRET")

if not RAZORPAY_KEY_ID or not RAZORPAY_KEY_SECRET:
    raise Exception("Razorpay API keys not configured")

razorpay_client = razorpay.Client(auth=(RAZORPAY_KEY_ID, RAZORPAY_KEY_SECRET))

PAYMENT_SUCCESS = "success"
PAYMENT_FAILED = "failed"
PAYMENT_PENDING = "pending"

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=[
        "http://localhost:3000",
        "https://clenzy.app"
    ],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

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

@app.get("/")
def read_root():
    return {"message": "Razorpay server is running with Database."}

@app.post("/create-order")
async def create_order(request: OrderRequest, db: Session = Depends(get_db)):
    try:
        # Check if user and job exist
        user = db.query(models.User).filter(models.User.id == request.user_id).first()
        if not user:
            raise HTTPException(status_code=404, detail="User not found")

        job = db.query(models.Job).filter(models.Job.id == request.job_id).first()
        if not job:
            raise HTTPException(status_code=404, detail="Job not found")

        # convert rupees to paise for Razorpay
        amount_paise = int(request.amount * 100)
        data = {
            "amount": amount_paise,
            "currency": request.currency,
            "receipt": f"job_{request.job_id}_user_{request.user_id}"
        }
        order = razorpay_client.order.create(data=data)

        # Save to database
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

@app.post("/verify-payment")
async def verify_payment(request: VerifyPaymentRequest, db: Session = Depends(get_db)):
    try:
        payment = db.query(models.Payment).filter(
            models.Payment.razorpay_order_id == request.razorpay_order_id
        ).first()

        if not payment:
            raise HTTPException(status_code=404, detail="Payment record not found")

        # Prevent Duplicate Payment Verification
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
            # Payment signature failed
            payment.payment_status = PAYMENT_FAILED
            payment.updated_at = datetime.utcnow()
            db.commit()
            raise HTTPException(status_code=400, detail="Invalid payment signature")

        # Payment is successful
        payment.payment_status = PAYMENT_SUCCESS
        payment.razorpay_payment_id = request.razorpay_payment_id
        payment.razorpay_signature = request.razorpay_signature
        payment.updated_at = datetime.utcnow()
        
        # Calculate and save payout info
        platform_fee, worker_amount = calculate_payout(payment.amount)
        payment.platform_fee = platform_fee
        payment.worker_amount = worker_amount
        
        # Save payment method
        payment_details = razorpay_client.payment.fetch(request.razorpay_payment_id)
        payment.payment_method = payment_details.get("method")
        
        # Create a payout record (mocking worker_id discovery from job)
        # In real app, job.worker_id would be used
        payout = models.Payout(
            worker_id=999, # Placeholder
            payment_id=payment.id,
            worker_amount=worker_amount,
            payout_status="pending"
        )
        db.add(payout)
        
        db.commit()
        return {"status": "success", "message": "Payment verified successfully"}

    except HTTPException:
        raise
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=400, detail=str(e))

@app.post("/razorpay/webhook")
async def razorpay_webhook(request: Request, db: Session = Depends(get_db)):
    body = await request.body()
    signature = request.headers.get("X-Razorpay-Signature")

    try:
        razorpay_client.utility.verify_webhook_signature(
            body.decode('utf-8'),
            signature,
            WEBHOOK_SECRET
        )
    except Exception:
        raise HTTPException(status_code=400, detail="Invalid webhook signature")

    data = json.loads(body)
    
    if data["event"] == "payment.captured":
        payload = data["payload"]["payment"]["entity"]
        order_id = payload["order_id"]
        payment_id = payload["id"]
        
        payment = db.query(models.Payment).filter(
            models.Payment.razorpay_order_id == order_id
        ).first()
        
        if payment and payment.payment_status != PAYMENT_SUCCESS:
            payment.payment_status = PAYMENT_SUCCESS
            payment.razorpay_payment_id = payment_id
            payment.payment_method = payload.get("method")
            payment.updated_at = datetime.utcnow()
            
            # Calculate and save payout info
            platform_fee, worker_amount = calculate_payout(payment.amount)
            payment.platform_fee = platform_fee
            payment.worker_amount = worker_amount
            
            # Create payout record
            payout = models.Payout(
                worker_id=999, # Placeholder
                payment_id=payment.id,
                worker_amount=worker_amount,
                payout_status="pending"
            )
            db.add(payout)
            db.commit()

    return {"status": "webhook processed"}

@app.get("/admin/payments")
def get_payments(db: Session = Depends(get_db)):
    payments = db.query(models.Payment).all()
    return payments

@app.post("/refund")
def refund(payment_id: str, db: Session = Depends(get_db)):
    try:
        # Initiate refund with Razorpay
        razorpay_client.payment.refund(payment_id)
        
        # Update database status
        payment = db.query(models.Payment).filter(
            models.Payment.razorpay_payment_id == payment_id
        ).first()
        if payment:
            payment.payment_status = "refunded"
            payment.updated_at = datetime.utcnow()
            db.commit()
            
        return {"status": "refund initiated"}
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))
