from fastapi import APIRouter, Depends, HTTPException, status
from motor.motor_asyncio import AsyncIOMotorDatabase
from .. import schemas, auth
from ..database import get_database

router = APIRouter()

@router.get("/balance")
async def get_balance(db: AsyncIOMotorDatabase = Depends(get_database), current_user: dict = Depends(auth.get_current_user)):
    wallet = await db.wallets.find_one({"user_id": current_user["id"]})
    if not wallet:
        return {"balance": 0.0, "total_earnings": 0.0}
    return {"balance": wallet.get("balance", 0.0), "total_earnings": wallet.get("total_earnings", 0.0)}

@router.get("/transactions")
async def get_transactions(db: AsyncIOMotorDatabase = Depends(get_database), current_user: dict = Depends(auth.get_current_user)):
    cursor = db.transactions.find({"user_id": current_user["id"]}).sort("created_at", -1)
    transactions = []
    async for tx in cursor:
        tx["id"] = str(tx["_id"])
        transactions.append(tx)
    return transactions
