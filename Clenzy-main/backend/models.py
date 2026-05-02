from sqlalchemy import Column, BigInteger, Text, Double, ForeignKey, DateTime
from sqlalchemy.sql import func
from database import Base

class User(Base):
    __tablename__ = "users"
    id = Column(BigInteger, primary_key=True, index=True)

class Job(Base):
    __tablename__ = "jobs"
    id = Column(BigInteger, primary_key=True, index=True)

class Payment(Base):
    __tablename__ = "payments"
    id = Column(BigInteger, primary_key=True, index=True)
    job_id = Column(BigInteger, ForeignKey("jobs.id"), nullable=False)
    user_id = Column(BigInteger, ForeignKey("users.id"), nullable=False)
    razorpay_order_id = Column(Text, unique=True, index=True, nullable=False)
    razorpay_payment_id = Column(Text, unique=True, index=True, nullable=True)
    razorpay_signature = Column(Text, nullable=True)
    amount = Column(Double, nullable=False)
    currency = Column(Text, nullable=False, default="INR")
    payment_status = Column(Text, nullable=False, default="pending")  # pending / success / failed / refunded
    payment_method = Column(Text, nullable=True)  # card / upi / wallet / netbanking
    platform_fee = Column(Double, nullable=True)
    worker_amount = Column(Double, nullable=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now(), nullable=False)
    updated_at = Column(DateTime(timezone=True), onupdate=func.now(), server_default=func.now(), nullable=False)

class Payout(Base):
    __tablename__ = "payouts"
    id = Column(BigInteger, primary_key=True, index=True)
    worker_id = Column(BigInteger, nullable=False)
    payment_id = Column(BigInteger, ForeignKey("payments.id"), nullable=False)
    worker_amount = Column(Double, nullable=False)
    payout_status = Column(Text, nullable=False, default="pending")  # pending / paid / failed
    created_at = Column(DateTime(timezone=True), server_default=func.now(), nullable=False)
