import os
from datetime import datetime
import razorpay
from fastapi import APIRouter, Depends, HTTPException, status
from pydantic import BaseModel
from motor.motor_asyncio import AsyncIOMotorDatabase
from bson import ObjectId

from .. import schemas, auth
from ..database import get_database

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
    job_id: str
    user_id: str

class VerifyPaymentRequest(BaseModel):
    razorpay_order_id: str
    razorpay_payment_id: str
    razorpay_signature: str

class RefundRequest(BaseModel):
    razorpay_payment_id: str

@router.post("/create-order")
async def create_order(request: OrderRequest, db: AsyncIOMotorDatabase = Depends(get_database)):
    try:
        user_obj_id = ObjectId(request.user_id)
        job_obj_id = ObjectId(request.job_id)
    except:
        raise HTTPException(status_code=400, detail="Invalid IDs")
        
    user = await db.users.find_one({"_id": user_obj_id})
    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    job = await db.jobs.find_one({"_id": job_obj_id})
    if not job:
        raise HTTPException(status_code=404, detail="Job not found")

    amount_paise = int(request.amount * 100)
    data = {
        "amount": amount_paise,
        "currency": request.currency,
        "receipt": f"job_{request.job_id}"[:40]
    }
    order = razorpay_client.order.create(data=data)

    new_payment = {
        "job_id": request.job_id,
        "user_id": request.user_id,
        "razorpay_order_id": order['id'],
        "amount": request.amount,
        "currency": request.currency,
        "payment_status": PAYMENT_PENDING,
        "created_at": datetime.utcnow()
    }
    
    result = await db.payments.insert_one(new_payment)

    return {
        "orderId": order['id'],
        "amount": request.amount,
        "currency": request.currency,
        "key": RAZORPAY_KEY_ID
    }

@router.post("/verify-payment")
async def verify_payment(request: VerifyPaymentRequest, db: AsyncIOMotorDatabase = Depends(get_database)):
    payment = await db.payments.find_one({"razorpay_order_id": request.razorpay_order_id})

    if not payment:
        raise HTTPException(status_code=404, detail="Payment record not found")

    if payment.get("payment_status") == PAYMENT_SUCCESS:
        return {"status": "already_verified"}

    params_dict = {
        'razorpay_order_id': request.razorpay_order_id,
        'razorpay_payment_id': request.razorpay_payment_id,
        'razorpay_signature': request.razorpay_signature
    }

    try:
        razorpay_client.utility.verify_payment_signature(params_dict)
    except Exception:
        await db.payments.update_one(
            {"_id": payment["_id"]},
            {"$set": {"payment_status": PAYMENT_FAILED}}
        )
        raise HTTPException(status_code=400, detail="Invalid payment signature")

    platform_fee, worker_amount = calculate_payout(payment.get("amount", 0))
    
    payment_details = razorpay_client.payment.fetch(request.razorpay_payment_id)
    method = payment_details.get("method")
    
    update_data = {
        "payment_status": PAYMENT_SUCCESS,
        "razorpay_payment_id": request.razorpay_payment_id,
        "razorpay_signature": request.razorpay_signature,
        "platform_fee": platform_fee,
        "worker_amount": worker_amount,
        "payment_method": method
    }
    
    await db.payments.update_one({"_id": payment["_id"]}, {"$set": update_data})
    
    job_id = payment.get("job_id")
    try:
        job_obj_id = ObjectId(job_id)
        job = await db.jobs.find_one({"_id": job_obj_id})
    except:
        job = None
        
    worker_id = job.get("worker_id") if job and job.get("worker_id") else payment.get("user_id")
    
    payout = {
        "worker_id": worker_id,
        "payment_id": str(payment["_id"]),
        "worker_amount": worker_amount,
        "payout_status": "pending",
        "created_at": datetime.utcnow()
    }
    await db.payouts.insert_one(payout)
    
    return {
        "status": "success",
        "message": "Payment verified successfully",
        "payment_id": str(payment["_id"]),
        "worker_amount": worker_amount
    }

@router.post("/refund")
async def refund(request: RefundRequest, db: AsyncIOMotorDatabase = Depends(get_database)):
    payment = await db.payments.find_one({"razorpay_payment_id": request.razorpay_payment_id})
    
    if not payment:
        raise HTTPException(status_code=404, detail="Payment not found")
    
    if payment.get("payment_status") not in [PAYMENT_SUCCESS, PAYMENT_PENDING]:
        raise HTTPException(status_code=400, detail="Cannot refund payment in current status")
    
    try:
        razorpay_client.payment.refund(request.razorpay_payment_id)
    except Exception as e:
        raise HTTPException(status_code=400, detail=f"Refund failed: {str(e)}")
        
    await db.payments.update_one(
        {"_id": payment["_id"]},
        {"$set": {"payment_status": "refunded"}}
    )
        
    return {
        "status": "success",
        "message": "Refund initiated successfully",
        "payment_id": str(payment["_id"])
    }
