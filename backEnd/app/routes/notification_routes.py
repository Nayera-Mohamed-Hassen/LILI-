from fastapi import APIRouter, HTTPException, Body
from pydantic import BaseModel
from ..notification_utils import get_notifications, mark_notification_read, delete_notification

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