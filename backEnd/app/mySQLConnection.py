import os
from datetime import datetime
from dotenv import load_dotenv
from pymongo import MongoClient
import uuid
import random
import string

load_dotenv()

MONGO_URI = os.getenv("MONGO_URI")
client = MongoClient(MONGO_URI)
db = client["lili"]

def generate_id() -> str:
    """Generate a unique UUID string."""
    return str(uuid.uuid4())

# Household CRUD

def insertHouseHold(name: str, pic: str, address: str, join_code: str = None) -> str:
    """Insert a new household and return its ID. Returns None on failure."""
    doc = {
        "_id": generate_id(),
        "house_Name": name,
        "house_pic": pic,
        "house_address": address
    }
    if join_code:
        doc["join_code"] = join_code
    try:
        db["household_tbl"].insert_one(doc)
        return doc["_id"]
    except Exception as e:
        print(f"Error inserting household: {e}")
        return None

def selectHouseHold(query: dict = None) -> list:
    """Select households matching the query. Returns all if query is None."""
    if query is None:
        query = {}
    try:
        return list(db["household_tbl"].find(query))
    except Exception as e:
        print(f"Error selecting households: {e}")
        return []

# User CRUD

def is_unique_user(username: str, email: str, phone: str) -> bool:
    """Check if username, email, and phone are unique in the user_tbl."""
    try:
        if db["user_tbl"].find_one({"username": username}):
            return False
        if db["user_tbl"].find_one({"user_email": email}):
            return False
        if db["user_tbl"].find_one({"user_phone": phone}):
            return False
        return True
    except Exception as e:
        print(f"Error checking uniqueness: {e}")
        return False

def insertUser(user_Name: str, username: str, user_password: str, user_birthday: str, user_profilePic: str = None, user_email: str = "", user_phone: str = "", user_Height: float = None, user_weight: float = None, user_diet: str = "", user_gender: str = "", house_Id: str = None) -> str:
    """Insert a new user and return their ID. Returns None on failure."""
    doc = {
        "_id": generate_id(),
        "user_Name": user_Name,
        "username": username,
        "user_role": "user",
        "user_password": user_password,
        "user_birthday": user_birthday,
        "user_profilePic": user_profilePic,
        "user_email": user_email,
        "user_phone": user_phone,
        "user_Height": user_Height,
        "user_weight": user_weight,
        "user_diet": user_diet,
        "user_gender": user_gender,
        "house_Id": house_Id,
        "user_isLoggedIn": True
    }
    try:
        db["user_tbl"].insert_one(doc)
        return doc["_id"]
    except Exception as e:
        print(f"Error inserting user: {e}")
        return None

def selectUser(query: dict = None, id: str = None) -> list:
    """Select users by query or by ID. Returns all if both are None."""
    try:
        if query is not None:
            return list(db["user_tbl"].find(query))
        elif id is not None:
            return list(db["user_tbl"].find({"_id": id}))
        else:
            return list(db["user_tbl"].find())
    except Exception as e:
        print(f"Error selecting users: {e}")
        return []

def updateUser(user_id: str, update_fields: dict) -> bool:
    """Update user fields. Returns True if modified, False otherwise or on error."""
    try:
        result = db["user_tbl"].update_one({"_id": user_id}, {"$set": update_fields})
        return result.modified_count > 0
    except Exception as e:
        print(f"Error updating user: {e}")
        return False

# Notification CRUD

def insert_notification(title: str, body: str, user_id: str, is_read: bool = False) -> bool:
    """Insert a notification for a user. Returns True on success, False on error."""
    doc = {
        "_id": generate_id(),
        "not_title": title,
        "not_body": body,
        "not_isRead": is_read,
        "not_timeStamp": datetime.now().isoformat(),
        "user_Id": user_id
    }
    try:
        db["notification_tbl"].insert_one(doc)
        return True
    except Exception as e:
        print(f"Error inserting notification: {e}")
        return False

def selectNotifications(query: dict = None, id: str = None) -> list:
    """Select notifications by query or user ID. Returns all if both are None."""
    try:
        if query is not None:
            return list(db["notification_tbl"].find(query))
        elif id is not None:
            return list(db["notification_tbl"].find({"user_Id": id}))
        else:
            return list(db["notification_tbl"].find())
    except Exception as e:
        print(f"Error selecting notifications: {e}")
        return []

# Task CRUD

def insert_task(title: str, description: str, status: str, deadline: str, assigner_id: str, assigned_to_id: str) -> str:
    """Insert a new task and return its ID. Returns None on failure."""
    doc = {
        "_id": generate_id(),
        "task_title": title,
        "task_description": description,
        "task_status": status,
        "task_deadline": deadline,
        "assigner_Id": assigner_id,
        "assignedTo_Id": assigned_to_id
    }
    try:
        db["task_tbl"].insert_one(doc)
        return doc["_id"]
    except Exception as e:
        print(f"Error inserting task: {e}")
        return None

def selectTasks(query: dict = None, id: str = None) -> list:
    """Select tasks by query or assigned user ID. Returns all if both are None."""
    try:
        if query is not None:
            return list(db["task_tbl"].find(query))
        elif id is not None:
            return list(db["task_tbl"].find({"assignedTo_Id": id}))
        else:
            return list(db["task_tbl"].find())
    except Exception as e:
        print(f"Error selecting tasks: {e}")
        return []

# Allergy CRUD

def insertAllergy(allergy_name: str, user_Id: str) -> bool:
    """Insert an allergy for a user. Returns True on success, False on error."""
    doc = {
        "_id": generate_id(),
        "allergy_name": allergy_name,
        "user_Id": user_Id
    }
    try:
        db["allergy_tbl"].insert_one(doc)
        return True
    except Exception as e:
        print(f"Error inserting allergy: {e}")
        return False

def selectAllergy(query: dict = None, id: str = None) -> list:
    """Select allergies by query or user ID. Returns all if both are None."""
    try:
        if query is not None:
            return list(db["allergy_tbl"].find(query))
        elif id is not None:
            return list(db["allergy_tbl"].find({"user_Id": id}))
        else:
            return list(db["allergy_tbl"].find())
    except Exception as e:
        print(f"Error selecting allergies: {e}")
        return []

def generate_unique_house_code() -> str:
    """Generate a unique 6-character alphanumeric join code for a household."""
    chars = string.ascii_uppercase + string.digits
    while True:
        code = ''.join(random.choices(chars, k=6))
        try:
            if not db["household_tbl"].find_one({"join_code": code}):
                return code
        except Exception as e:
            print(f"Error generating unique house code: {e}")
            return None

def check_user_uniqueness(username: str, email: str, phone: str) -> str:
    """Return which field is not unique: 'username', 'email', 'phone', or 'ok' if all unique."""
    try:
        if db["user_tbl"].find_one({"username": username}):
            return "username"
        if db["user_tbl"].find_one({"user_email": email}):
            return "email"
        if db["user_tbl"].find_one({"user_phone": phone}):
            return "phone"
        return "ok"
    except Exception as e:
        print(f"Error checking uniqueness: {e}")
        return "error"

# For production, comment out or remove the test block below
# if __name__ == '__main__':
#     print(insertAllergy("chocolate","2"))
#     print(selectAllergy(id = 1))