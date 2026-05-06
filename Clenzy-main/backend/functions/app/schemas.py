from pydantic import BaseModel, EmailStr
from typing import Optional, List, Any
from datetime import datetime

# --- Users ---
class UserBase(BaseModel):
    full_name: str
    email: EmailStr
    phone: str
    role: Optional[str] = "user"

class UserCreate(UserBase):
    password: str
    profession: Optional[str] = None
    experience: Optional[int] = None
    skills: Optional[List[str]] = None

class UserUpdate(BaseModel):
    full_name: Optional[str] = None
    email: Optional[EmailStr] = None
    phone: Optional[str] = None
    is_online: Optional[bool] = None

class UserResponse(UserBase):
    id: str
    is_active: bool
    is_verified: bool
    is_online: bool
    created_at: datetime
    
# --- Addresses ---
class AddressBase(BaseModel):
    label: str
    full_address: str
    city: str
    state: str
    pincode: str
    is_default: Optional[bool] = False

class AddressCreate(AddressBase):
    pass

class AddressUpdate(BaseModel):
    label: Optional[str] = None
    full_address: Optional[str] = None
    city: Optional[str] = None
    state: Optional[str] = None
    pincode: Optional[str] = None
    is_default: Optional[bool] = None

class AddressResponse(AddressBase):
    id: str
    user_id: str
    created_at: datetime
    
# --- Auth ---
class Token(BaseModel):
    access_token: str
    token_type: str
    user_id: str
    role: str
    is_profile_complete: Optional[bool] = False

class TokenData(BaseModel):
    email: Optional[str] = None
    role: Optional[str] = None

class LoginRequest(BaseModel):
    email: EmailStr
    password: str

# --- Jobs ---
class JobBase(BaseModel):
    service_type: str
    price: float
    workers_needed: int
    latitude: float
    longitude: float
    address: str
    description: Optional[str] = None

class JobCreate(JobBase):
    provider_id: Optional[str] = None

class JobResponse(JobBase):
    id: str
    customer_id: str
    worker_id: Optional[str] = None
    agency_id: Optional[str] = None
    status: str
    otp: str
    created_at: datetime
    accepted_at: Optional[datetime] = None
    completed_at: Optional[datetime] = None
    
# --- Admin ---
class AdminStatsResponse(BaseModel):
    total_users: int
    total_partners: int
    total_jobs: int
    total_revenue: float
    pending_partners: int

class AdminPartnerProfileResponse(BaseModel):
    id: str
    user_id: str
    bio: Optional[str] = None
    business_type: str
    business_name: Optional[str] = None
    use_same_as_profile_name: bool
    city: str
    service_radius: float
    approval_status: str
    is_profile_complete: bool
    average_rating: float
    total_reviews: int
    
    # We include user details as a nested dict for easy display
    user: Optional[UserResponse] = None

# --- Reviews ---
class ReviewBase(BaseModel):
    rating: int # 1-5
    comment: Optional[str] = None

class ReviewCreate(ReviewBase):
    job_id: str
    partner_id: str

class ReviewResponse(ReviewBase):
    id: str
    job_id: str
    reviewer_id: str
    partner_id: str
    created_at: datetime
    
# --- Promo Codes ---
class PromoValidateRequest(BaseModel):
    code: str
    job_total: float

class PromoValidateResponse(BaseModel):
    valid: bool
    discount_amount: float
    message: str
