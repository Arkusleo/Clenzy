from fastapi import APIRouter, Depends, HTTPException, status
from typing import List
from sqlalchemy.orm import Session
from .. import models, schemas, auth
from ..database import get_db
from datetime import timedelta

router = APIRouter()

@router.post("/signup", response_model=schemas.UserResponse)
def signup(user: schemas.UserCreate, db: Session = Depends(get_db)):
    db_user = db.query(models.User).filter(models.User.email == user.email).first()
    if db_user:
        raise HTTPException(status_code=400, detail="Email already registered")
        
    hashed_password = auth.get_password_hash(user.password)
    new_user = models.User(
        full_name=user.full_name,
        email=user.email,
        phone=user.phone,
        hashed_password=hashed_password,
        role=user.role or "user"
    )
    db.add(new_user)
    db.flush()  # Get new_user.id
    
    # Create empty wallet for user
    new_wallet = models.Wallet(user_id=new_user.id)
    db.add(new_wallet)
    
    # If the user signed up as a worker, prepopulate their partner profile
    if new_user.role == "worker":
        # Check if skills exists
        skills_list = user.skills if user.skills and isinstance(user.skills, list) else []
        new_partner = models.PartnerProfile(
            user_id=new_user.id,
            business_name=user.profession if user.profession else None,
            custom_skills=skills_list
        )
        db.add(new_partner)
    
    db.commit()
    db.refresh(new_user)
    
    return new_user

@router.post("/login", response_model=schemas.Token)
def login(user_credentials: schemas.LoginRequest, db: Session = Depends(get_db)):
    user = db.query(models.User).filter(models.User.email == user_credentials.email).first()
    
    if not user or not auth.verify_password(user_credentials.password, user.hashed_password):
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN, detail="Invalid Credentials"
        )
        
    access_token_expires = timedelta(minutes=auth.ACCESS_TOKEN_EXPIRE_MINUTES)
    access_token = auth.create_access_token(
        data={"email": user.email, "role": user.role, "user_id": user.id}, 
        expires_delta=access_token_expires
    )
    
    is_profile_complete = False
    if user.role in ["worker", "agency_partner", "individual_partner"] and user.partner_profile:
        is_profile_complete = user.partner_profile.is_profile_complete

    return {
        "access_token": access_token, 
        "token_type": "bearer", 
        "user_id": user.id, 
        "role": user.role,
        "is_profile_complete": is_profile_complete
    }
@router.get("/me", response_model=schemas.UserResponse)
def get_current_user_profile(current_user: models.User = Depends(auth.get_current_user)):
    return current_user

@router.put("/me", response_model=schemas.UserResponse)
def update_current_user_profile(
    user_update: schemas.UserUpdate, 
    db: Session = Depends(get_db),
    current_user: models.User = Depends(auth.get_current_user)
):
    if user_update.email and user_update.email != current_user.email:
        # Check if email is already taken
        if db.query(models.User).filter(models.User.email == user_update.email).first():
            raise HTTPException(status_code=400, detail="Email already registered")
        current_user.email = user_update.email
    
    if user_update.full_name is not None:
        current_user.full_name = user_update.full_name
        
    if user_update.phone is not None:
        current_user.phone = user_update.phone
        
    db.commit()
    db.refresh(current_user)
    return current_user

# --- Addresses Endpoints ---

@router.post("/me/complete_profile", response_model=schemas.UserResponse)
def complete_partner_profile(
    db: Session = Depends(get_db),
    current_user: models.User = Depends(auth.get_current_user)
):
    if not current_user.partner_profile:
        raise HTTPException(status_code=400, detail="Partner profile not found")
        
    current_user.partner_profile.is_profile_complete = True
    db.commit()
    db.refresh(current_user)
    return current_user

# --- Addresses Endpoints ---

@router.post("/me/addresses", response_model=schemas.AddressResponse)
def create_address(
    address: schemas.AddressCreate,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(auth.get_current_user)
):
    if address.is_default:
        # Unset other default addresses
        db.query(models.Address).filter(
            models.Address.user_id == current_user.id,
            models.Address.is_default == True
        ).update({"is_default": False})
        
    new_address = models.Address(
        **address.model_dump(),
        user_id=current_user.id
    )
    db.add(new_address)
    db.commit()
    db.refresh(new_address)
    
    # If this is the user's first address, make it default automatically
    if not address.is_default:
        total_addresses = db.query(models.Address).filter(models.Address.user_id == current_user.id).count()
        if total_addresses == 1:
            new_address.is_default = True
            db.commit()
            db.refresh(new_address)
            
    return new_address

@router.get("/me/addresses", response_model=List[schemas.AddressResponse])
def get_addresses(
    db: Session = Depends(get_db),
    current_user: models.User = Depends(auth.get_current_user)
):
    return db.query(models.Address).filter(models.Address.user_id == current_user.id).all()

@router.put("/me/addresses/{address_id}", response_model=schemas.AddressResponse)
def update_address(
    address_id: int,
    address_update: schemas.AddressUpdate,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(auth.get_current_user)
):
    db_address = db.query(models.Address).filter(
        models.Address.id == address_id,
        models.Address.user_id == current_user.id
    ).first()
    
    if not db_address:
        raise HTTPException(status_code=404, detail="Address not found")
        
    update_data = address_update.model_dump(exclude_unset=True)
    
    if update_data.get("is_default"):
        # Unset other default addresses
        db.query(models.Address).filter(
            models.Address.user_id == current_user.id,
            models.Address.is_default == True,
            models.Address.id != address_id
        ).update({"is_default": False})
        
    for key, value in update_data.items():
        setattr(db_address, key, value)
        
    db.commit()
    db.refresh(db_address)
    return db_address

@router.delete("/me/addresses/{address_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_address(
    address_id: int,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(auth.get_current_user)
):
    db_address = db.query(models.Address).filter(
        models.Address.id == address_id,
        models.Address.user_id == current_user.id
    ).first()
    
    if not db_address:
        raise HTTPException(status_code=404, detail="Address not found")
        
    was_default = db_address.is_default
    
    db.delete(db_address)
    db.commit()
    
    # If we deleted the default address, set another one as default if any exist
    if was_default:
        another = db.query(models.Address).filter(models.Address.user_id == current_user.id).first()
        if another:
            another.is_default = True
            db.commit()