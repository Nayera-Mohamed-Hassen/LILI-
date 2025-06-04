from fastapi import APIRouter, HTTPException
from typing import Optional, List
from pydantic import BaseModel
from datetime import datetime
from pymongo import MongoClient
import os
from dotenv import load_dotenv
from ..mySQLConnection import selectUser

load_dotenv()
MONGO_URI = os.getenv("MONGO_URI")
client = MongoClient(MONGO_URI)
db = client["lili"]

router = APIRouter()

class Transaction(BaseModel):
    user_id: str
    amount: float
    category: str
    description: Optional[str] = None
    transaction_type: str  # "income" or "expense"
    source: Optional[str] = None  # for income
    date: Optional[str] = None

class Card(BaseModel):
    user_id: str
    card_type: str
    card_number: str
    expiry_date: str
    cvv: str
    cardholder_name: str

@router.post("/transaction/add")
async def add_transaction(transaction: Transaction):
    try:
        # Get house_id for the user
        house_result = selectUser(f'SELECT house_Id FROM user_tbl WHERE user_Id = "{transaction.user_id}"')
        if not house_result:
            raise HTTPException(status_code=404, detail="House ID not found for user")
        
        house_id = house_result[0]["house_Id"]
        
        # Prepare transaction document
        transaction_doc = transaction.dict()
        transaction_doc["house_id"] = house_id
        transaction_doc["date"] = transaction.date or datetime.now().isoformat()
        
        # Insert into MongoDB
        db.transactions.insert_one(transaction_doc)
        
        # Update budget estimation data
        if transaction.transaction_type == "expense":
            update_budget_estimation(transaction_doc)
        
        return {"status": "success", "message": "Transaction added successfully"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/transactions/{user_id}")
async def get_transactions(user_id: str):
    try:
        # Get house_id for the user
        house_result = selectUser(f'SELECT house_Id FROM user_tbl WHERE user_Id = "{user_id}"')
        if not house_result:
            raise HTTPException(status_code=404, detail="House ID not found for user")
        
        house_id = house_result[0]["house_Id"]
        
        # Get transactions from MongoDB
        transactions = list(db.transactions.find(
            {"house_id": house_id},
            {"_id": 0}  # Exclude MongoDB _id from results
        ))
        
        return transactions
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.post("/card/add")
async def add_card(card: Card):
    try:
        # Get house_id for the user
        house_result = selectUser(f'SELECT house_Id FROM user_tbl WHERE user_Id = "{card.user_id}"')
        if not house_result:
            raise HTTPException(status_code=404, detail="House ID not found for user")
        
        house_id = house_result[0]["house_Id"]
        
        # Prepare card document
        card_doc = card.dict()
        card_doc["house_id"] = house_id
        card_doc["date_added"] = datetime.now().isoformat()
        
        # Store the full card number
        card_doc["last_four"] = card_doc["card_number"][-4:]
        
        # Insert into MongoDB
        db.cards.insert_one(card_doc)
        
        return {"status": "success", "message": "Card added successfully"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/cards/{user_id}")
async def get_cards(user_id: str):
    try:
        # Get house_id for the user
        house_result = selectUser(f'SELECT house_Id FROM user_tbl WHERE user_Id = "{user_id}"')
        if not house_result:
            raise HTTPException(status_code=404, detail="House ID not found for user")
        
        house_id = house_result[0]["house_Id"]
        
        # Get cards from MongoDB
        cards = list(db.cards.find(
            {"house_id": house_id},
            {"_id": 0}  # Exclude only MongoDB _id from results
        ))
        
        return cards
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

def update_budget_estimation(transaction: dict):
    """Update budget estimation data with new transaction"""
    try:
        # Get existing budget data for the month
        month = datetime.now().strftime("%Y-%m")
        budget_data = db.budget_estimation.find_one({
            "house_id": transaction["house_id"],
            "month": month
        })
        
        if not budget_data:
            # Create new budget data for the month
            budget_data = {
                "house_id": transaction["house_id"],
                "month": month,
                "categories": {},
                "total_spent": 0
            }
        
        # Update category spending
        category = transaction["category"]
        if category not in budget_data["categories"]:
            budget_data["categories"][category] = 0
        budget_data["categories"][category] += transaction["amount"]
        
        # Update total spending
        budget_data["total_spent"] = sum(budget_data["categories"].values())
        
        # Upsert budget data
        db.budget_estimation.update_one(
            {
                "house_id": transaction["house_id"],
                "month": month
            },
            {"$set": budget_data},
            upsert=True
        )
        
    except Exception as e:
        print(f"Error updating budget estimation: {e}") 