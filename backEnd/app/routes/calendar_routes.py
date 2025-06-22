from fastapi import APIRouter, HTTPException, Body
from pydantic import BaseModel, Field
from typing import List, Optional
from bson import ObjectId
from datetime import datetime
import os
from ..mangoDBConnection import db

router = APIRouter(prefix="/calendar/events", tags=["Calendar Events"])

class EventModel(BaseModel):
    title: str
    description: Optional[str] = ""
    start_time: datetime
    end_time: datetime
    type: str = "general"
    location: Optional[str] = ""
    participants: Optional[List[str]] = []
    creator_id: str
    house_id: Optional[str] = None
    privacy: str = Field("private", pattern="^(private|public)$")
    created_at: Optional[datetime] = None
    updated_at: Optional[datetime] = None

class UpdateEventModel(BaseModel):
    title: Optional[str]
    description: Optional[str]
    start_time: Optional[datetime]
    end_time: Optional[datetime]
    type: Optional[str]
    location: Optional[str]
    participants: Optional[List[str]]
    privacy: Optional[str]
    updated_at: Optional[datetime] = None

@router.post("", response_model=dict)
def add_event(event: EventModel):
    event_dict = event.dict()
    event_dict["created_at"] = datetime.utcnow()
    event_dict["updated_at"] = datetime.utcnow()
    print("[DEBUG] Inserting event:", event_dict)
    result = db["events"].insert_one(event_dict)
    print("[DEBUG] Inserted event ID:", result.inserted_id)
    if result.inserted_id:
        return {"status": "success", "event_id": str(result.inserted_id)}
    raise HTTPException(status_code=500, detail="Failed to add event")

@router.get("", response_model=List[dict])
def get_events(user_id: str, house_id: Optional[str] = None):
    # Show private events for user, and public events for household
    query = {"$or": [
        {"creator_id": user_id, "privacy": "private"},
    ]}
    if house_id:
        query["$or"].append({"house_id": house_id, "privacy": "public"})
    events = list(db["events"].find(query))
    for e in events:
        e["_id"] = str(e["_id"])
    return events

@router.put("/{event_id}", response_model=dict)
def update_event(event_id: str, event: UpdateEventModel):
    update_data = {k: v for k, v in event.dict().items() if v is not None}
    update_data["updated_at"] = datetime.utcnow()
    result = db["events"].update_one({"_id": ObjectId(event_id)}, {"$set": update_data})
    if result.modified_count:
        return {"status": "success"}
    raise HTTPException(status_code=404, detail="Event not found or not updated")

@router.delete("/{event_id}", response_model=dict)
def delete_event(event_id: str):
    result = db["events"].delete_one({"_id": ObjectId(event_id)})
    if result.deleted_count:
        return {"status": "success"}
    raise HTTPException(status_code=404, detail="Event not found") 