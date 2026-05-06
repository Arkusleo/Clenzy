from fastapi import APIRouter, Depends, HTTPException, status
from motor.motor_asyncio import AsyncIOMotorDatabase
from bson import ObjectId
from typing import List

from .. import schemas, auth
from ..database import get_database

router = APIRouter()

@router.get("/stats", response_model=schemas.AdminStatsResponse)
async def get_admin_dashboard_stats(
    db: AsyncIOMotorDatabase = Depends(get_database), 
    current_admin: dict = Depends(auth.get_current_admin)
):
    total_users = await db.users.count_documents({"role": "user"})
    total_partners = await db.users.count_documents({
        "role": {"$in": ["individual_partner", "agency_partner", "worker"]}
    })
    total_jobs = await db.jobs.count_documents({})
    
    # Calculate revenue
    pipeline = [
        {"$match": {"status": "completed"}},
        {"$group": {"_id": None, "total": {"$sum": "$price"}}}
    ]
    cursor = db.jobs.aggregate(pipeline)
    total_revenue = 0.0
    async for doc in cursor:
        total_revenue = doc.get("total", 0.0)
        break
    
    pending_partners = await db.partner_profiles.count_documents({"approval_status": "pending"})
    
    return schemas.AdminStatsResponse(
        total_users=total_users,
        total_partners=total_partners,
        total_jobs=total_jobs,
        total_revenue=total_revenue,
        pending_partners=pending_partners
    )

@router.get("/users", response_model=List[schemas.UserResponse])
async def get_all_users(
    skip: int = 0, limit: int = 100, 
    db: AsyncIOMotorDatabase = Depends(get_database), 
    current_admin: dict = Depends(auth.get_current_admin)
):
    cursor = db.users.find({}).skip(skip).limit(limit)
    users = []
    async for user in cursor:
        user["id"] = str(user["_id"])
        users.append(user)
    return users

@router.put("/users/{user_id}/status")
async def toggle_user_status(
    user_id: str,
    is_active: bool,
    db: AsyncIOMotorDatabase = Depends(get_database),
    current_admin: dict = Depends(auth.get_current_admin)
):
    try:
        obj_id = ObjectId(user_id)
    except:
        raise HTTPException(status_code=404, detail="User not found")
        
    user = await db.users.find_one({"_id": obj_id})
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    
    if user_id == current_admin["id"] and not is_active:
        raise HTTPException(status_code=400, detail="Cannot deactivate yourself")

    await db.users.update_one({"_id": obj_id}, {"$set": {"is_active": is_active}})
    return {"message": f"User status updated. Active: {is_active}"}

@router.get("/jobs", response_model=List[schemas.JobResponse])
async def get_all_jobs(
    skip: int = 0, limit: int = 100,
    db: AsyncIOMotorDatabase = Depends(get_database),
    current_admin: dict = Depends(auth.get_current_admin)
):
    cursor = db.jobs.find({}).sort("created_at", -1).skip(skip).limit(limit)
    jobs = []
    async for job in cursor:
        job["id"] = str(job["_id"])
        jobs.append(job)
    return jobs

@router.put("/partner-approvals/{profile_id}")
async def approve_or_reject_partner(
    profile_id: str,
    approve: bool,
    db: AsyncIOMotorDatabase = Depends(get_database),
    current_admin: dict = Depends(auth.get_current_admin)
):
    try:
        obj_id = ObjectId(profile_id)
    except:
        raise HTTPException(status_code=404, detail="Partner profile not found")
        
    profile = await db.partner_profiles.find_one({"_id": obj_id})
    if not profile:
        raise HTTPException(status_code=404, detail="Partner profile not found")
        
    new_status = "approved" if approve else "rejected"
    await db.partner_profiles.update_one({"_id": obj_id}, {"$set": {"approval_status": new_status}})
        
    return {"message": f"Partner profile has been {new_status}"}

@router.get("/partner-approvals", response_model=List[schemas.AdminPartnerProfileResponse])
async def get_pending_partners(
    skip: int = 0, limit: int = 100,
    db: AsyncIOMotorDatabase = Depends(get_database),
    current_admin: dict = Depends(auth.get_current_admin)
):
    cursor = db.partner_profiles.find({"approval_status": "pending"}).skip(skip).limit(limit)
    profiles = []
    async for profile in cursor:
        profile["id"] = str(profile["_id"])
        user = await db.users.find_one({"_id": ObjectId(profile["user_id"])})
        if user:
            user["id"] = str(user["_id"])
            profile["user"] = user
        profiles.append(profile)
    return profiles