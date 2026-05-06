from fastapi import APIRouter, Depends, HTTPException, status
from typing import List
from motor.motor_asyncio import AsyncIOMotorDatabase
from bson import ObjectId
from .. import schemas, auth
from ..database import get_database, str_object_id
from datetime import timedelta, datetime

router = APIRouter()

@router.post("/signup", response_model=schemas.UserResponse)
async def signup(user: schemas.UserCreate, db: AsyncIOMotorDatabase = Depends(get_database)):
    if await db.users.find_one({"email": user.email}):
        raise HTTPException(status_code=400, detail="Email already registered")

    if await db.users.find_one({"phone": user.phone}):
        raise HTTPException(status_code=400, detail="Phone number already registered")
        
    hashed_password = auth.get_password_hash(user.password)
    new_user = {
        "full_name": user.full_name,
        "email": user.email,
        "phone": user.phone,
        "hashed_password": hashed_password,
        "role": user.role or "user",
        "is_active": True,
        "is_verified": False,
        "is_online": False,
        "created_at": datetime.utcnow(),
        "favorite_partners": []
    }
    
    result = await db.users.insert_one(new_user)
    user_id_str = str(result.inserted_id)
    new_user["id"] = user_id_str
    
    # Create empty wallet for user
    await db.wallets.insert_one({
        "user_id": user_id_str,
        "balance": 0.0,
        "transactions": []
    })
    
    # If the user signed up as a worker, prepopulate their partner profile
    if new_user["role"] == "worker":
        skills_list = user.skills if user.skills and isinstance(user.skills, list) else []
        await db.partner_profiles.insert_one({
            "user_id": user_id_str,
            "business_type": "individual",
            "business_name": user.profession if user.profession else None,
            "custom_skills": skills_list,
            "city": "",
            "service_radius": 10.0,
            "approval_status": "pending",
            "is_profile_complete": False,
            "average_rating": 0.0,
            "total_reviews": 0,
            "use_same_as_profile_name": True
        })
    
    return new_user

@router.post("/login", response_model=schemas.Token)
async def login(user_credentials: schemas.LoginRequest, db: AsyncIOMotorDatabase = Depends(get_database)):
    user = await db.users.find_one({"email": user_credentials.email})
    
    if not user or not auth.verify_password(user_credentials.password, user["hashed_password"]):
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN, detail="Invalid Credentials"
        )
        
    user_id_str = str(user["_id"])
    access_token_expires = timedelta(minutes=auth.ACCESS_TOKEN_EXPIRE_MINUTES)
    access_token = auth.create_access_token(
        data={"email": user["email"], "role": user.get("role", "user"), "user_id": user_id_str}, 
        expires_delta=access_token_expires
    )
    
    is_profile_complete = False
    if user.get("role") in ["worker", "agency_partner", "individual_partner"]:
        partner = await db.partner_profiles.find_one({"user_id": user_id_str})
        if partner:
            is_profile_complete = partner.get("is_profile_complete", False)

    return {
        "access_token": access_token, 
        "token_type": "bearer", 
        "user_id": user_id_str, 
        "role": user.get("role", "user"),
        "is_profile_complete": is_profile_complete
    }

@router.get("/me", response_model=schemas.UserResponse)
async def get_current_user_profile(current_user: dict = Depends(auth.get_current_user)):
    return current_user

@router.put("/me", response_model=schemas.UserResponse)
async def update_current_user_profile(
    user_update: schemas.UserUpdate, 
    db: AsyncIOMotorDatabase = Depends(get_database),
    current_user: dict = Depends(auth.get_current_user)
):
    update_data = {}
    if user_update.email and user_update.email != current_user["email"]:
        if await db.users.find_one({"email": user_update.email}):
            raise HTTPException(status_code=400, detail="Email already registered")
        update_data["email"] = user_update.email
    
    if user_update.full_name is not None:
        update_data["full_name"] = user_update.full_name
        
    if user_update.phone is not None:
        update_data["phone"] = user_update.phone
        
    if update_data:
        await db.users.update_one({"_id": ObjectId(current_user["id"])}, {"$set": update_data})
        current_user.update(update_data)
        
    return current_user

@router.post("/me/complete_profile", response_model=schemas.UserResponse)
async def complete_partner_profile(
    db: AsyncIOMotorDatabase = Depends(get_database),
    current_user: dict = Depends(auth.get_current_user)
):
    result = await db.partner_profiles.update_one(
        {"user_id": current_user["id"]},
        {"$set": {"is_profile_complete": True}}
    )
    if result.matched_count == 0:
        raise HTTPException(status_code=400, detail="Partner profile not found")
        
    return current_user

# --- Addresses Endpoints ---

@router.post("/me/addresses", response_model=schemas.AddressResponse)
async def create_address(
    address: schemas.AddressCreate,
    db: AsyncIOMotorDatabase = Depends(get_database),
    current_user: dict = Depends(auth.get_current_user)
):
    if address.is_default:
        await db.addresses.update_many(
            {"user_id": current_user["id"], "is_default": True},
            {"$set": {"is_default": False}}
        )
        
    new_address = address.model_dump()
    new_address["user_id"] = current_user["id"]
    new_address["created_at"] = datetime.utcnow()
    
    result = await db.addresses.insert_one(new_address)
    new_address["id"] = str(result.inserted_id)
    
    if not address.is_default:
        total_addresses = await db.addresses.count_documents({"user_id": current_user["id"]})
        if total_addresses == 1:
            await db.addresses.update_one({"_id": result.inserted_id}, {"$set": {"is_default": True}})
            new_address["is_default"] = True
            
    return new_address

@router.get("/me/addresses", response_model=List[schemas.AddressResponse])
async def get_addresses(
    db: AsyncIOMotorDatabase = Depends(get_database),
    current_user: dict = Depends(auth.get_current_user)
):
    cursor = db.addresses.find({"user_id": current_user["id"]})
    addresses = []
    async for addr in cursor:
        addr["id"] = str(addr["_id"])
        addresses.append(addr)
    return addresses

@router.put("/me/addresses/{address_id}", response_model=schemas.AddressResponse)
async def update_address(
    address_id: str,
    address_update: schemas.AddressUpdate,
    db: AsyncIOMotorDatabase = Depends(get_database),
    current_user: dict = Depends(auth.get_current_user)
):
    try:
        obj_id = ObjectId(address_id)
    except:
        raise HTTPException(status_code=404, detail="Address not found")
        
    db_address = await db.addresses.find_one({"_id": obj_id, "user_id": current_user["id"]})
    if not db_address:
        raise HTTPException(status_code=404, detail="Address not found")
        
    update_data = address_update.model_dump(exclude_unset=True)
    
    if update_data.get("is_default"):
        await db.addresses.update_many(
            {"user_id": current_user["id"], "is_default": True, "_id": {"$ne": obj_id}},
            {"$set": {"is_default": False}}
        )
        
    if update_data:
        await db.addresses.update_one({"_id": obj_id}, {"$set": update_data})
        db_address.update(update_data)
        
    db_address["id"] = str(db_address["_id"])
    return db_address

@router.delete("/me/addresses/{address_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_address(
    address_id: str,
    db: AsyncIOMotorDatabase = Depends(get_database),
    current_user: dict = Depends(auth.get_current_user)
):
    try:
        obj_id = ObjectId(address_id)
    except:
        raise HTTPException(status_code=404, detail="Address not found")
        
    db_address = await db.addresses.find_one({"_id": obj_id, "user_id": current_user["id"]})
    if not db_address:
        raise HTTPException(status_code=404, detail="Address not found")
        
    was_default = db_address.get("is_default", False)
    await db.addresses.delete_one({"_id": obj_id})
    
    if was_default:
        another = await db.addresses.find_one({"user_id": current_user["id"]})
        if another:
            await db.addresses.update_one({"_id": another["_id"]}, {"$set": {"is_default": True}})

# --- Presence ---
@router.patch("/me/presence", response_model=schemas.UserResponse)
async def update_presence(
    is_online: bool,
    db: AsyncIOMotorDatabase = Depends(get_database),
    current_user: dict = Depends(auth.get_current_user)
):
    await db.users.update_one({"_id": ObjectId(current_user["id"])}, {"$set": {"is_online": is_online}})
    current_user["is_online"] = is_online
    return current_user

# --- Reviews ---
@router.post("/reviews", response_model=schemas.ReviewResponse)
async def create_review(
    review: schemas.ReviewCreate,
    db: AsyncIOMotorDatabase = Depends(get_database),
    current_user: dict = Depends(auth.get_current_user)
):
    try:
        job_obj_id = ObjectId(review.job_id)
    except:
        raise HTTPException(status_code=404, detail="Job not found")
        
    job = await db.jobs.find_one({"_id": job_obj_id})
    if not job or job.get("status") != "completed":
        raise HTTPException(status_code=400, detail="Job must be completed to leave a review")
        
    partner_profile = await db.partner_profiles.find_one({"user_id": review.partner_id})
    if not partner_profile:
        raise HTTPException(status_code=404, detail="Partner not found")
        
    new_review = review.model_dump()
    new_review["reviewer_id"] = current_user["id"]
    new_review["created_at"] = datetime.utcnow()
    
    result = await db.reviews.insert_one(new_review)
    new_review["id"] = str(result.inserted_id)
    
    total = partner_profile.get("total_reviews", 0)
    current_avg = partner_profile.get("average_rating", 0.0)
    new_avg = ((current_avg * total) + review.rating) / (total + 1)
    
    await db.partner_profiles.update_one(
        {"user_id": review.partner_id},
        {"$set": {"average_rating": new_avg, "total_reviews": total + 1}}
    )
    
    return new_review

@router.get("/reviews/{partner_id}", response_model=List[schemas.ReviewResponse])
async def get_partner_reviews(
    partner_id: str,
    db: AsyncIOMotorDatabase = Depends(get_database)
):
    cursor = db.reviews.find({"partner_id": partner_id})
    reviews = []
    async for rev in cursor:
        rev["id"] = str(rev["_id"])
        reviews.append(rev)
    return reviews

# --- Favorites ---
@router.post("/me/favorites/{partner_id}")
async def add_favorite_partner(
    partner_id: str,
    db: AsyncIOMotorDatabase = Depends(get_database),
    current_user: dict = Depends(auth.get_current_user)
):
    try:
        partner_obj = ObjectId(partner_id)
    except:
        raise HTTPException(status_code=404, detail="Partner not found")
        
    partner = await db.users.find_one({"_id": partner_obj})
    if not partner:
        raise HTTPException(status_code=404, detail="Partner not found")
        
    favorites = current_user.get("favorite_partners", [])
    if partner_id not in favorites:
        await db.users.update_one(
            {"_id": ObjectId(current_user["id"])},
            {"$push": {"favorite_partners": partner_id}}
        )
    return {"status": "success"}

@router.delete("/me/favorites/{partner_id}")
async def remove_favorite_partner(
    partner_id: str,
    db: AsyncIOMotorDatabase = Depends(get_database),
    current_user: dict = Depends(auth.get_current_user)
):
    favorites = current_user.get("favorite_partners", [])
    if partner_id in favorites:
        await db.users.update_one(
            {"_id": ObjectId(current_user["id"])},
            {"$pull": {"favorite_partners": partner_id}}
        )
    return {"status": "success"}

@router.get("/me/favorites", response_model=List[schemas.UserResponse])
async def get_favorite_partners(
    db: AsyncIOMotorDatabase = Depends(get_database),
    current_user: dict = Depends(auth.get_current_user)
):
    favorites = current_user.get("favorite_partners", [])
    partners = []
    for fav_id in favorites:
        try:
            partner = await db.users.find_one({"_id": ObjectId(fav_id)})
            if partner:
                partner["id"] = str(partner["_id"])
                partners.append(partner)
        except:
            pass
    return partners