from fastapi import APIRouter, Depends, HTTPException, status
from motor.motor_asyncio import AsyncIOMotorDatabase
from bson import ObjectId
from .. import schemas, auth
from ..database import get_database
import random
from datetime import datetime

router = APIRouter()

def generate_otp():
    return str(random.randint(1000, 9999))

@router.post("/", response_model=schemas.JobResponse)
async def create_job(job: schemas.JobCreate, db: AsyncIOMotorDatabase = Depends(get_database), current_user: dict = Depends(auth.get_current_user)):
    otp = generate_otp()
    new_job = job.model_dump()
    new_job["customer_id"] = current_user["id"]
    new_job["status"] = "accepted" if job.provider_id else "searching"
    new_job["worker_id"] = job.provider_id if job.provider_id else None
    new_job["agency_id"] = None
    new_job["otp"] = otp
    new_job["created_at"] = datetime.utcnow()
    new_job["completed_at"] = None
    
    if job.provider_id:
        new_job["accepted_at"] = datetime.utcnow()
    else:
        new_job["accepted_at"] = None
        
    result = await db.jobs.insert_one(new_job)
    new_job["id"] = str(result.inserted_id)
    return new_job

@router.get("/customer", response_model=list[schemas.JobResponse])
async def get_customer_jobs(db: AsyncIOMotorDatabase = Depends(get_database), current_user: dict = Depends(auth.get_current_user)):
    cursor = db.jobs.find({"customer_id": current_user["id"]})
    jobs = []
    async for job in cursor:
        job["id"] = str(job["_id"])
        jobs.append(job)
    return jobs

@router.get("/worker", response_model=list[schemas.JobResponse])
async def get_worker_jobs(db: AsyncIOMotorDatabase = Depends(get_database), current_user: dict = Depends(auth.get_current_user)):
    cursor = db.jobs.find({"worker_id": current_user["id"]})
    jobs = []
    async for job in cursor:
        job["id"] = str(job["_id"])
        jobs.append(job)
    return jobs

@router.get("/available", response_model=list[schemas.JobResponse])
async def get_available_jobs(db: AsyncIOMotorDatabase = Depends(get_database), current_user: dict = Depends(auth.get_current_user)):
    if current_user.get("role") == "user":
        raise HTTPException(status_code=403, detail="Not authorized")
        
    cursor = db.jobs.find({"status": "searching"})
    jobs = []
    async for job in cursor:
        job["id"] = str(job["_id"])
        jobs.append(job)
    return jobs

@router.post("/{job_id}/accept", response_model=schemas.JobResponse)
async def accept_job(job_id: str, db: AsyncIOMotorDatabase = Depends(get_database), current_user: dict = Depends(auth.get_current_user)):
    try:
        obj_id = ObjectId(job_id)
    except:
        raise HTTPException(status_code=404, detail="Job not found")
        
    job = await db.jobs.find_one({"_id": obj_id})
    if not job:
        raise HTTPException(status_code=404, detail="Job not found")
    if job.get("status") != "searching":
        raise HTTPException(status_code=400, detail="Job is no longer available")
    if current_user.get("role") == "user":
        raise HTTPException(status_code=403, detail="Only workers can accept jobs")
        
    now = datetime.utcnow()
    await db.jobs.update_one(
        {"_id": obj_id}, 
        {"$set": {"worker_id": current_user["id"], "status": "accepted", "accepted_at": now}}
    )
    
    job["worker_id"] = current_user["id"]
    job["status"] = "accepted"
    job["accepted_at"] = now
    job["id"] = str(job["_id"])
    return job

@router.put("/{job_id}/status", response_model=schemas.JobResponse)
async def update_job_status(job_id: str, new_status: str, db: AsyncIOMotorDatabase = Depends(get_database), current_user: dict = Depends(auth.get_current_user)):
    try:
        obj_id = ObjectId(job_id)
    except:
        raise HTTPException(status_code=404, detail="Job not found")
        
    job = await db.jobs.find_one({"_id": obj_id})
    if not job:
        raise HTTPException(status_code=404, detail="Job not found")
        
    valid_transitions = {
        'accepted': ['arrived'],
        'arrived': ['started'],
        'started': ['completed'],
    }
    
    if job.get("worker_id") != current_user["id"]:
        raise HTTPException(status_code=403, detail="Not assigned to this job")
        
    if new_status not in valid_transitions.get(job.get("status"), []):
        raise HTTPException(status_code=400, detail=f"Cannot transition from {job.get('status')} to {new_status}")
    
    await db.jobs.update_one({"_id": obj_id}, {"$set": {"status": new_status}})
    job["status"] = new_status
    job["id"] = str(job["_id"])
    return job

@router.post("/{job_id}/verify-otp", response_model=schemas.JobResponse)
async def verify_otp(job_id: str, otp: str, db: AsyncIOMotorDatabase = Depends(get_database), current_user: dict = Depends(auth.get_current_user)):
    try:
        obj_id = ObjectId(job_id)
    except:
        raise HTTPException(status_code=404, detail="Job not found")
        
    job = await db.jobs.find_one({"_id": obj_id})
    if not job:
        raise HTTPException(status_code=404, detail="Job not found")
        
    if job.get("otp") != otp:
        raise HTTPException(status_code=400, detail="Invalid OTP")
        
    now = datetime.utcnow()
    await db.jobs.update_one({"_id": obj_id}, {"$set": {"status": "completed", "completed_at": now}})
    
    worker_share = float(job.get("price", 0)) * 0.85
    platform_commission = float(job.get("price", 0)) * 0.15
    
    worker_id = job.get("worker_id")
    if worker_id:
        await db.wallets.update_one(
            {"user_id": worker_id},
            {"$inc": {"balance": worker_share, "total_earnings": worker_share}}
        )
        
    # Transactions
    await db.transactions.insert_many([
        {"user_id": worker_id, "type": "earning", "amount": worker_share, "job_id": job_id, "description": "Job earnings", "created_at": now},
        {"user_id": None, "type": "commission", "amount": platform_commission, "job_id": job_id, "description": "Platform commission", "created_at": now}
    ])
    
    job["status"] = "completed"
    job["completed_at"] = now
    job["id"] = str(job["_id"])
    return job

# --- Promo Codes ---
@router.post("/promo/validate", response_model=schemas.PromoValidateResponse)
async def validate_promo_code(
    promo: schemas.PromoValidateRequest,
    db: AsyncIOMotorDatabase = Depends(get_database),
    current_user: dict = Depends(auth.get_current_user)
):
    code_record = await db.promo_codes.find_one({"code": promo.code, "is_active": True})
    
    if not code_record:
        return schemas.PromoValidateResponse(valid=False, discount_amount=0.0, message="Invalid or expired promo code")
        
    valid_until = code_record.get("valid_until")
    if valid_until and valid_until < datetime.utcnow():
        return schemas.PromoValidateResponse(valid=False, discount_amount=0.0, message="Promo code expired")
        
    discount = promo.job_total * (float(code_record.get("discount_percentage", 0)) / 100.0)
    max_discount = code_record.get("max_discount")
    if max_discount and discount > float(max_discount):
        discount = float(max_discount)
        
    return schemas.PromoValidateResponse(valid=True, discount_amount=discount, message="Promo code applied successfully")
