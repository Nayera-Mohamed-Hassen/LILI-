from fastapi import APIRouter, HTTPException, Body, Request
from pydantic import BaseModel, Field
from typing import List, Optional, Dict, Any
from datetime import datetime
from pymongo import MongoClient
from bson import ObjectId
import os
from dotenv import load_dotenv
from ..notification_utils import create_notification
from ..mySQLConnection import selectUser

load_dotenv()
MONGO_URI = os.getenv("MONGO_URI")
client = MongoClient(MONGO_URI)
db = client["lili"]
emergency_col = db["emergency_alerts"]

router = APIRouter(prefix="/emergency", tags=["Emergency"])

class EmergencyAlertModel(BaseModel):
    id: Optional[str] = Field(default=None, alias="_id")
    senderId: str
    senderName: str
    houseId: str
    type: str
    message: str
    timestamp: datetime
    status: str = "active"
    acknowledgedBy: List[str] = []
    additionalInfo: Dict[str, Any] = {}

    class Config:
        allow_population_by_field_name = True
        arbitrary_types_allowed = True
        json_encoders = {ObjectId: str}

def alert_to_dict(alert):
    alert = dict(alert)
    # Defensive: skip if _id is None
    if alert.get('_id') is None:
        return None
    alert['id'] = str(alert['_id'])
    del alert['_id']
    return alert

@router.post("/send", response_model=EmergencyAlertModel)
def send_emergency_alert(alert: EmergencyAlertModel):
    alert_dict = alert.dict(by_alias=True)
    alert_dict["timestamp"] = alert.timestamp or datetime.utcnow()
    # Remove _id if None so MongoDB can auto-generate it
    if alert_dict.get("_id") is None:
        alert_dict.pop("_id", None)
    result = emergency_col.insert_one(alert_dict)
    alert_dict["_id"] = result.inserted_id
    # Notify all household members
    users_in_house = selectUser(query={"house_Id": alert.houseId})
    for u in users_in_house:
        uid = u["_id"]
        create_notification(
            user_id=uid,
            notif_type="emergency",
            title="Emergency Alert",
            body=f"{alert.senderName} sent an emergency: {alert.message}",
            data={"alert_id": str(result.inserted_id)},
            icon="warning"
        )
    ret = alert_to_dict(alert_dict)
    return ret

@router.get("/all", response_model=List[EmergencyAlertModel])
def get_all_alerts():
    alerts = list(emergency_col.find().sort("timestamp", -1))
    result = [a for a in (alert_to_dict(x) for x in alerts) if a is not None]
    return result

@router.get("/{user_id}", response_model=List[EmergencyAlertModel])
def get_user_alerts(user_id: str):
    alerts = list(emergency_col.find({"senderId": user_id}).sort("timestamp", -1))
    result = [a for a in (alert_to_dict(x) for x in alerts) if a is not None]
    return result

@router.get("/house/{house_id}", response_model=List[EmergencyAlertModel])
def get_house_alerts(house_id: str):
    alerts = list(emergency_col.find({"houseId": house_id}).sort("timestamp", -1))
    result = [a for a in (alert_to_dict(x) for x in alerts) if a is not None]
    return result

@router.post("/acknowledge/{alert_id}")
def acknowledge_alert(alert_id: str, user_id: str = Body(...)):
    result = emergency_col.update_one({"_id": ObjectId(alert_id)}, {"$addToSet": {"acknowledgedBy": user_id}, "$set": {"status": "acknowledged"}})
    if result.modified_count == 0:
        raise HTTPException(status_code=404, detail="Alert not found or already acknowledged")
    return {"status": "acknowledged"}

@router.post("/resolve/{alert_id}")
def resolve_alert(alert_id: str):
    result = emergency_col.update_one({"_id": ObjectId(alert_id)}, {"$set": {"status": "resolved"}})
    if result.modified_count == 0:
        raise HTTPException(status_code=404, detail="Alert not found or already resolved")
    return {"status": "resolved"} 