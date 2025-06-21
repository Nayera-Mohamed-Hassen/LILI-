from pymongo import MongoClient
from datetime import datetime
import os
from dotenv import load_dotenv
from bson import ObjectId

load_dotenv()
MONGO_URI = os.getenv("MONGO_URI")
client = MongoClient(MONGO_URI)
db = client["lili"]
notifications_col = db["notifications"]

def create_notification(user_id, notif_type, title, body, data=None, icon=None):
    notif = {
        "user_id": str(user_id),
        "type": notif_type,
        "title": title,
        "body": body,
        "data": data or {},
        "icon": icon or "",
        "is_read": False,
        "created_at": datetime.utcnow()
    }
    result = notifications_col.insert_one(notif)
    return str(result.inserted_id)

def get_notifications(user_id, unread_only=False):
    query = {"user_id": str(user_id)}
    if unread_only:
        query["is_read"] = False
    notifs = list(notifications_col.find(query).sort("created_at", -1))
    for n in notifs:
        n["_id"] = str(n["_id"])
    return notifs

def mark_notification_read(notification_id):
    result = notifications_col.update_one({"_id": ObjectId(notification_id)}, {"$set": {"is_read": True}})
    return result.modified_count > 0

def delete_notification(notification_id):
    result = notifications_col.delete_one({"_id": ObjectId(notification_id)})
    return result.deleted_count > 0 