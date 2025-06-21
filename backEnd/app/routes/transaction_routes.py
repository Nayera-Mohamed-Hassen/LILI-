from fastapi import APIRouter, HTTPException
from typing import Optional, List
from pydantic import BaseModel
from datetime import datetime
from pymongo import MongoClient
import os
from dotenv import load_dotenv
from ..mySQLConnection import selectUser
from ..notification_utils import create_notification

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
        # Get user for validation
        user_result = selectUser(id=transaction.user_id)
        if not user_result:
            raise HTTPException(status_code=404, detail="User not found")
        transaction_doc = transaction.dict()
        transaction_doc["date"] = transaction.date or datetime.now().isoformat()
        db.transactions.insert_one(transaction_doc)
        if transaction.transaction_type == "expense":
            update_budget_estimation(transaction_doc)
            create_notification(
                user_id=transaction.user_id,
                notif_type="spending",
                title="New Expense Added",
                body=f"You added a new expense in {transaction.category}.",
                data={"amount": transaction.amount, "category": transaction.category},
                icon="spending"
            )
        return {"status": "success", "message": "Transaction added successfully"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/transactions/{user_id}")
async def get_transactions(user_id: str):
    try:
        user_result = selectUser(id=user_id)
        if not user_result:
            raise HTTPException(status_code=404, detail="User not found")
        transactions = list(db.transactions.find({"user_id": user_id}, {"_id": 0}))
        return transactions
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.post("/card/add")
async def add_card(card: Card):
    try:
        user_result = selectUser(id=card.user_id)
        if not user_result:
            raise HTTPException(status_code=404, detail="User not found")
        house_id = user_result[0].get("house_Id")
        if not house_id:
            raise HTTPException(status_code=404, detail="House ID not found for user")
        card_doc = card.dict()
        card_doc["house_id"] = house_id
        card_doc["date_added"] = datetime.now().isoformat()
        card_doc["last_four"] = card_doc["card_number"][-4:]
        db.cards.insert_one(card_doc)
        return {"status": "success", "message": "Card added successfully"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/cards/{user_id}")
async def get_cards(user_id: str):
    try:
        user_result = selectUser(id=user_id)
        if not user_result:
            raise HTTPException(status_code=404, detail="User not found")
        house_id = user_result[0].get("house_Id")
        if not house_id:
            raise HTTPException(status_code=404, detail="House ID not found for user")
        cards = list(db.cards.find({"house_id": house_id}, {"_id": 0}))
        return cards
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

def update_budget_estimation(transaction: dict):
    try:
        month = datetime.now().strftime("%Y-%m")
        budget_data = db.budget_estimation.find_one({
            "user_id": transaction["user_id"],
            "month": month
        })
        if not budget_data:
            budget_data = {
                "user_id": transaction["user_id"],
                "month": month,
                "categories": {},
                "total_spent": 0
            }
        category = transaction["category"]
        if category not in budget_data["categories"]:
            budget_data["categories"][category] = 0
        budget_data["categories"][category] += transaction["amount"]
        budget_data["total_spent"] = sum(budget_data["categories"].values())
        db.budget_estimation.update_one(
            {"user_id": transaction["user_id"], "month": month},
            {"$set": budget_data},
            upsert=True
        )
        # Pseudo-code for spending irregularity and budget exceeded (to be run in analytics/budget logic)
        check_spending_alerts()
    except Exception as e:
        print(f"Error updating budget estimation: {e}")

# Pseudo-code for spending irregularity and budget exceeded (to be run in analytics/budget logic)
def check_spending_alerts():
    # For each user/category, check for irregularity or budget exceeded
    # Example:
    # if irregularity_detected:
    create_notification(
        user_id="<user_id>",
        notif_type="spending",
        title="Spending Irregularity Detected",
        body="Irregular spending detected in category: Groceries.",
        data={"category": "Groceries"},
        icon="spending"
    )
    # if budget_exceeded:
    create_notification(
        user_id="<user_id>",
        notif_type="spending",
        title="Budget Exceeded",
        body="You have exceeded your budget for category: Groceries.",
        data={"category": "Groceries"},
        icon="spending"
    ) 