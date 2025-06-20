import os
from datetime import datetime
from dotenv import load_dotenv
from pymongo import MongoClient
import uuid

load_dotenv()

MONGO_URI = os.getenv("MONGO_URI")
client = MongoClient(MONGO_URI)
db = client["lili"]

def generate_id():
    return str(uuid.uuid4())

# Household CRUD

def insertHouseHold(name: str, pic: str, address: str) -> str:
    doc = {
        "_id": generate_id(),
        "house_Name": name,
        "house_pic": pic,
        "house_address": address
    }
    db["household_tbl"].insert_one(doc)
    return doc["_id"]

def selectHouseHold(query: dict = None) -> list:
    if query is None:
        query = {}
    return list(db["household_tbl"].find(query))

# User CRUD

def insertUser(user_Name: str, user_password: str, user_birthday: str, user_profilePic: str = None, user_email: str = "", user_phone: str = "", user_Height: float = None, user_weight: float = None, user_diet: str = "", user_gender: str = "", house_Id: str = None) -> str:
    doc = {
        "_id": generate_id(),
        "user_Name": user_Name,
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
    db["user_tbl"].insert_one(doc)
    return doc["_id"]

def selectUser(query: dict = None, id: str = None) -> list:
    if query is not None:
        return list(db["user_tbl"].find(query))
    elif id is not None:
        return list(db["user_tbl"].find({"_id": id}))
    else:
        return list(db["user_tbl"].find())

def updateUser(user_id: str, update_fields: dict) -> bool:
    result = db["user_tbl"].update_one({"_id": user_id}, {"$set": update_fields})
    return result.modified_count > 0

# Notification CRUD

def insert_notification(title: str, body: str, user_id: str, is_read: bool = False) -> bool:
    doc = {
        "_id": generate_id(),
        "not_title": title,
        "not_body": body,
        "not_isRead": is_read,
        "not_timeStamp": datetime.now().strftime('%H:%M:%S'),
        "user_Id": user_id
    }
    db["notification_tbl"].insert_one(doc)
    return True

def selectNotifications(query: dict = None, id: str = None) -> list:
    if query is not None:
        return list(db["notification_tbl"].find(query))
    elif id is not None:
        return list(db["notification_tbl"].find({"user_Id": id}))
    else:
        return list(db["notification_tbl"].find())

# Task CRUD

def insert_task(title: str, description: str, status: str, deadline: str, assigner_id: str, assigned_to_id: str) -> str:
    doc = {
        "_id": generate_id(),
        "task_title": title,
        "task_description": description,
        "task_status": status,
        "task_deadline": deadline,
        "assigner_Id": assigner_id,
        "assignedTo_Id": assigned_to_id
    }
    db["task_tbl"].insert_one(doc)
    return doc["_id"]

def selectTasks(query: dict = None, id: str = None) -> list:
    if query is not None:
        return list(db["task_tbl"].find(query))
    elif id is not None:
        return list(db["task_tbl"].find({"assignedTo_Id": id}))
    else:
        return list(db["task_tbl"].find())

# Allergy CRUD

def insertAllergy(allergy_name: str, user_Id: str) -> bool:
    doc = {
        "_id": generate_id(),
        "allergy_name": allergy_name,
        "user_Id": user_Id
    }
    db["allergy_tbl"].insert_one(doc)
    return True

def selectAllergy(query: dict = None, id: str = None) -> list:
    if query is not None:
        return list(db["allergy_tbl"].find(query))
    elif id is not None:
        return list(db["allergy_tbl"].find({"user_Id": id}))
    else:
        return list(db["allergy_tbl"].find())

if __name__ == '__main__':
    #print(insertUser("hana","AppAdminstrator","1234","2003-06-24","sss","hanabassem@gmail.com","01111111",'169',"60","vegan","female","2"))
    #print(selectUser("select * from user_tbl where user_Id = 2"))
    #print(insert_task("end","total end","done","2025-07-01","1","2"))
    #print(selectTasks(id=2))
    print(insertAllergy("chocolate","2"))
    print(selectAllergy(id = 1))
    #print(selectNotifications())