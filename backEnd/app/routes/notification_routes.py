from fastapi import APIRouter, HTTPException, Body, Request
from pydantic import BaseModel
from ..notification_utils import get_notifications, mark_notification_read, delete_notification, create_notification
from pymongo import MongoClient
import os
from dotenv import load_dotenv

load_dotenv()
MONGO_URI = os.getenv("MONGO_URI")
client = MongoClient(MONGO_URI)
db = client["lili"]

router = APIRouter(prefix="/notifications", tags=["Notifications"])

class MarkReadRequest(BaseModel):
    notification_id: str

@router.get("/{user_id}")
def list_notifications(user_id: str, unread_only: bool = False):
    try:
        return get_notifications(user_id, unread_only)
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.post("/mark_read")
def mark_read(req: MarkReadRequest):
    if mark_notification_read(req.notification_id):
        return {"status": "success"}
    raise HTTPException(status_code=404, detail="Notification not found")

@router.delete("/{notification_id}")
def delete_notif(notification_id: str):
    if delete_notification(notification_id):
        return {"status": "success"}
    raise HTTPException(status_code=404, detail="Notification not found")

@router.post("/mark_all_read")
async def mark_all_notifications_as_read(request: Request):
    data = await request.json()
    user_id = data.get("user_id")
    if not user_id:
        raise HTTPException(status_code=400, detail="Missing user_id")
    result = db["notifications"].update_many(
        {"user_id": user_id, "is_read": False},
        {"$set": {"is_read": True}}
    )
    return {"marked_count": result.modified_count}

@router.post("/send")
async def send_notification(request: Request):
    data = await request.json()
    user_ids = data.get("user_ids", [])
    title = data.get("title", "")
    body = data.get("body", "")
    notif_type = data.get("type", "event")
    extra_data = data.get("data", {})
    if not user_ids or not title or not body:
        raise HTTPException(status_code=400, detail="Missing required fields")
    notif_ids = []
    for user_id in user_ids:
        notif_id = create_notification(user_id, notif_type, title, body, extra_data)
        notif_ids.append(notif_id)
    return {"success": True, "notification_ids": notif_ids} 