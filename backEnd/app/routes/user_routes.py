import os
from typing import List, Optional, Union
from datetime import datetime, timedelta
from difflib import get_close_matches
from fastapi import APIRouter, HTTPException, Request, Body, Query, Depends
from pydantic import BaseModel
from pymongo import MongoClient
from ..recipeAI import get_recipe_recommendations, update_preferences_on_cook, get_user_preferences
from ..mySQLConnection import selectUser, selectAllergy, insertUser, insertHouseHold, insertAllergy, updateUser, generate_unique_house_code, selectHouseHold, is_unique_user, check_user_uniqueness
from bson import ObjectId
import random
import string
import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
import json
from ..notification_utils import create_notification
from apscheduler.schedulers.background import BackgroundScheduler


router = APIRouter(prefix="/user", tags=["User"])

################ User Signup  ################

class UserSignup(BaseModel):
    name: str
    username: str
    password: str
    birthday: str
    email: str
    phone: str
    profile_pic: str = ""
    height: float = None
    weight: float = None
    diet: str = "vegan"
    gender: str = "female"
    house_id: Union[str, int] = ""
    allergy: str = ""

@router.post("/signup")
def signup(user: UserSignup):
    print("Received signup data:", user)
    # Always convert house_id to string
    house_id_str = str(user.house_id) if user.house_id is not None else ""
    # Uniqueness check
    if not is_unique_user(user.username, user.email, user.phone):
        raise HTTPException(status_code=400, detail="Username, email, or phone already exists.")
    # Insert user into the database
    user_id = insertUser(
        user_Name=user.name,
        username=user.username,
        user_password=user.password,
        user_birthday=user.birthday,
        user_email=user.email,
        user_phone=user.phone,
        user_profilePic=user.profile_pic,
        user_Height=user.height,
        user_weight=user.weight,
        user_diet=user.diet,
        user_gender=user.gender,
        house_Id=house_id_str
    )
    if not user_id:
        raise HTTPException(status_code=500, detail="Signup failed")
    # Insert allergies
    allergies = user.allergy.split(",") if user.allergy else []
    for a in allergies:
        if a.strip():
            insertAllergy(allergy_name=a.strip(), user_Id=user_id)
    return {"message": "User signed up successfully", "user_id": user_id}





################ user login ################

class UserLogin(BaseModel):
    username: str
    password: str



@router.post("/login")
async def login(user: UserLogin):
    try:
        result = selectUser(query={"username": user.username, "user_password": user.password})
        if result:
            user_id = result[0]["_id"]
            house_id = result[0].get("house_Id", "")
            return {"status": "success", "user_id": user_id, "house_Id": house_id}
        else:
            raise HTTPException(status_code=401, detail="Invalid username or password")
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


################ Create Household ################

class HouseHold(BaseModel):
    name: str
    pic: str
    address: str
    user_id: str



@router.post("/household/create")
async def create_household(data: HouseHold):
    # 1. Generate unique join code
    join_code = generate_unique_house_code()
    # 2. Insert the household and get the new house_id
    house_id = insertHouseHold(data.name, data.pic, data.address, join_code=join_code)
    if not house_id:
        raise HTTPException(status_code=500, detail="Failed to create household")

    # 3. Update the user's house_Id with the new house_id
    user_result = selectUser(query={"_id": data.user_id})
    if not user_result:
        raise HTTPException(status_code=404, detail="User not found")
    user_id = user_result[0]["_id"]
    # Assign admin role to the creator
    updateUser(user_id, {"house_Id": house_id, "user_role": "admin"})

    return {"message": "Household created", "house_id": house_id, "join_code": join_code}




################ Inventory Management ################


EXPIRY_KEYWORDS = {
    "frozen_meat": {
        "keywords": [
            "chicken", "beef", "steak", "meat", "turkey", "pork", "lamb", 
            "duck", "goat", "venison", "bacon", "sausage", "ham", "ground beef"
        ],
        "days": 180
    },
    "seafood": {
        "keywords": [
            "fish", "shrimp", "salmon", "crab", "lobster", "tilapia", "cod", 
            "mackerel", "tuna", "squid", "octopus", "scallops", "anchovy"
        ],
        "days": 180
    },
    "dairy": {
        "keywords": [
            "milk", "cheese", "yogurt", "butter", "cream", "curd", "ghee", 
            "sour cream", "cream cheese", "paneer", "custard"
        ],
        "days": 7
    },
    "bread": {
        "keywords": [
            "bread", "bun", "toast", "bagel", "roll", "brioche", "naan", 
            "pita", "sourdough", "rye bread", "ciabatta"
        ],
        "days": 4
    },
    "eggs": {
        "keywords": [
            "egg", "eggs", "boiled egg", "scrambled egg", "omelette"
        ],
        "days": 21
    },
    "fruits": {
        "keywords": [
            "apple", "banana", "grape", "mango", "fruit", "pear", "orange", 
            "kiwi", "pineapple", "watermelon", "strawberry", "blueberry", 
            "peach", "plum", "cherry", "apricot", "pomegranate", "melon"
        ],
        "days": 7
    },
    "vegetables": {
        "keywords": [
            "lettuce", "spinach", "broccoli", "carrot", "cucumber", 
            "vegetable", "tomato", "pepper", "onion", "garlic", "zucchini", 
            "cauliflower", "potato", "cabbage", "kale", "beet", "radish", 
            "eggplant", "sweet potato"
        ],
        "days": 5
    },
    "pantry": {
        "keywords": [
            "rice", "pasta", "noodles", "flour", "sugar", "salt", "cereal", 
            "lentils", "oats", "quinoa", "barley", "cornmeal", "spaghetti", 
            "macaroni", "breadcrumbs", "wheat"
        ],
        "days": 180
    },
    "snacks": {
        "keywords": [
            "chips", "cookies", "cracker", "snack", "popcorn", "candy", 
            "pretzels", "granola bar", "trail mix", "nuts", "biscuits"
        ],
        "days": 60
    },
    "canned": {
        "keywords": [
            "canned", "beans", "corn", "soup", "tuna", "peas", "tomato paste", 
            "canned fruit", "canned vegetables", "spam", "canned chicken", 
            "evaporated milk"
        ],
        "days": 365
    },
    "frozen": {
        "keywords": [
            "frozen", "ice cream", "frozen pizza", "frozen vegetables", 
            "frozen fruit", "frozen meals", "frozen dumplings", "frozen berries"
        ],
        "days": 365
    },
    "condiments": {
        "keywords": [
            "ketchup", "mustard", "mayonnaise", "soy sauce", "vinegar", 
            "salad dressing", "hot sauce", "barbecue sauce", "salsa", 
            "relish", "honey", "jam", "jelly", "maple syrup"
        ],
        "days": 180
    },
    "beverages": {
        "keywords": [
            "juice", "soda", "cola", "coffee", "tea", "milkshake", 
            "smoothie", "energy drink", "iced tea", "bottled water"
        ],
        "days": 30
    },
    "baked_goods": {
        "keywords": [
            "cake", "muffin", "pastry", "pie", "croissant", "donut", 
            "brownie", "cupcake", "tart"
        ],
        "days": 5
    },
    "leftovers": {
        "keywords": [
            "leftover", "cooked", "meal prep", "leftover chicken", 
            "leftover rice", "leftover pasta", "cooked beef"
        ],
        "days": 3
    }
}


def estimate_expiry_date(item_name: str, category: str = "Food") -> dict:
    # Only apply text correction and expiry date for food category
    if category != "Food":
        return "", item_name
    
    item_name_lower = item_name.lower()
    all_keywords = []
    keyword_to_category = {}

    for category, data in EXPIRY_KEYWORDS.items():
        for keyword in data["keywords"]:
            all_keywords.append(keyword)
            keyword_to_category[keyword] = category

    close_matches = get_close_matches(item_name_lower, all_keywords, n=1, cutoff=0.6)

    if close_matches:
        matched_keyword = close_matches[0]
        matched_category = keyword_to_category[matched_keyword]
        expiry_days = EXPIRY_KEYWORDS[matched_category]["days"]
    else:
        matched_category = "default"
        expiry_days = 14

    expiry_date = datetime.now() + timedelta(days=expiry_days)

    return expiry_date.strftime("%Y-%m-%d"), close_matches[0] if close_matches else item_name

     
    


################ Inventory Routes ################

MONGO_URI = os.getenv("MONGO_URI")
client = MongoClient(MONGO_URI)
db = client["lili"]
inventory_collection = db["inventory"]


class InventoryItem(BaseModel):
    name: str
    category: str
    quantity: int
    unit: str = "pieces"  # Default unit
    amount: float = 1.0   # Default amount
    #image: Optional[str]
    user_id: str  # Added user_id here


@router.post("/inventory/add")
async def add_item(item: InventoryItem):
    try:
        # Only apply text correction and expiry date for food category
        if item.category == "Food":
            expiry_info, name = estimate_expiry_date(item.name, item.category)
        else:
            # For non-food items, no text correction or expiry date
            expiry_info = ""
            name = item.name

        print(item.user_id)
        house_result = selectUser(query={"_id": item.user_id})
        if not house_result:
            raise HTTPException(status_code=404, detail="House ID not found for user")

        house_id = house_result[0]["house_Id"]
        print(f"Household ID: {house_id}")

        item_dict = item.dict()
        item_dict = {
            "name": name,
            "category": item.category,
            "quantity": item.quantity,
            "unit": item.unit,
            "amount": item.amount,
            "user_id": item.user_id,
            "expiry_date": expiry_info,
            "house_id": house_id
        }
        
        inventory_collection.insert_one(item_dict)
        
        # Notify all household members
        users_in_house = selectUser(query={"house_Id": house_id})
        for u in users_in_house:
            uid = u["_id"]
            create_notification(
                user_id=uid,
                notif_type="inventory",
                title="Item Added",
                body=f"{item.name} was added to your inventory.",
                data={"item_name": item.name},
                icon="inventory"
            )
        
        return {
            "status": "success",
            "message": "Item added successfully",
            "expiry_date": expiry_info,
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


class DeleteItemRequest(BaseModel):
    user_id: str
    name: str
    expiry: Optional[str] = None

@router.delete("/inventory/delete")
async def delete_inventory_item(data: DeleteItemRequest):
    try:
        house_result = selectUser(query={"_id": data.user_id})
        if not house_result:
            raise HTTPException(status_code=404, detail="House ID not found for user")
        house_id = house_result[0]["house_Id"]

        MONGO_URI = os.getenv("MONGO_URI")
        client = MongoClient(MONGO_URI)
        db = client["lili"]
        inventory_collection = db["inventory"]

        # Build delete query based on whether expiry is provided
        delete_query = {
            "house_id": house_id,
            "name": data.name
        }
        
        # Only include expiry_date in query if it's provided
        if data.expiry:
            delete_query["expiry_date"] = data.expiry

        print(f"Delete query: {delete_query}")
        # Delete inventory items that match name and house_id
        delete_result = inventory_collection.delete_many(delete_query)

        if delete_result.deleted_count == 0:
            return {"status": "not_found", "message": "No matching items found to delete"}

        create_notification(
            user_id=data.user_id,
            notif_type="inventory",
            title="Item Removed",
            body=f"{data.name} was removed from your inventory.",
            data={"item_name": data.name},
            icon="inventory"
        )

        return {
            "status": "success",
            "deleted_count": delete_result.deleted_count,
            "message": "Matching items deleted successfully"
        }

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
    

class UpdateQuantityRequest(BaseModel):
    user_id: str
    name: str
    quantity: int
    unit: str = "pieces"
    amount: float = 1.0

@router.put("/inventory/update-quantity")
async def update_inventory_quantity(data: UpdateQuantityRequest):
    try:
        house_result = selectUser(query={"_id": data.user_id})
        if not house_result:
            raise HTTPException(status_code=404, detail="House ID not found for user")
        house_id = house_result[0]["house_Id"]

        MONGO_URI = os.getenv("MONGO_URI")
        client = MongoClient(MONGO_URI)
        db = client["lili"]
        inventory_collection = db["inventory"]

        # If quantity is 0, delete the item
        if data.quantity <= 0:
            delete_result = inventory_collection.delete_one({
                "house_id": house_id,
                "name": data.name
            })
            
            if delete_result.deleted_count == 0:
                return {"status": "not_found", "message": "No matching item found to delete"}
            
            return {
                "status": "deleted",
                "message": "Item deleted successfully (quantity reached 0)"
            }

        # Update the quantity, unit, and amount of the matching item
        update_result = inventory_collection.update_one(
            {"house_id": house_id, "name": data.name},
            {"$set": {
                "quantity": data.quantity,
                "unit": data.unit,
                "amount": data.amount
            }}
        )

        if update_result.matched_count == 0:
            return {"status": "not_found", "message": "No matching item found to update"}

        return {
            "status": "success",
            "message": "Quantity updated successfully"
        }

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
    


class UserRequest(BaseModel):
    user_id: str

@router.post("/inventory/get-items")
async def get_inventory_items(data: UserRequest):
    try:
        house_result = selectUser(query={"_id": data.user_id})
        if not house_result:
            raise HTTPException(status_code=404, detail="House ID not found for user")
        house_id = house_result[0]["house_Id"]
        
        print(f"Household ID: {house_id}")

        client = MongoClient(os.getenv("MONGO_URI"))
        db = client["lili"]
        inventory_collection = db["inventory"]

        items = list(inventory_collection.find({"house_id": house_id}))
        for item in items:
            item["_id"] = str(item["_id"])
        return items

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


class RecipeItem(BaseModel):
    name: str
    cusine: str
    mealType: str
    ingredients: list[str]
    steps: Optional[list[str]] = None
    timeTaken: str  # store duration as minutes (int)
    difficulty: str
    image: str

recipes = [
    {
        "name": "Spaghetti Carbonara",
        "cusine": "Italian",
        "mealType": "Dinner",
        "ingredients": ["Spaghetti", "Eggs", "Parmesan cheese", "Bacon"],
        "timeTaken": 30,
        "difficulty": "Intermediate",
        "image": "Spaghetti Carbonara.jpg"
    },
    {
        "name": "Sushi Rolls",
        "cusine": "Japanese",
        "mealType": "Dinner",
        "ingredients": ["Sushi rice", "Nori", "Salmon", "Avocado", "Soy sauce"],
        "timeTaken": 45,
        "difficulty": "Advanced/Gourmet",
        "image": "Sushi Rolls.jpg"
    },
    {
        "name": "Tacos",
        "cusine": "Mexican",
        "mealType": "Lunch",
        "ingredients": ["Taco shells", "Ground beef", "Lettuce", "Cheese", "Sour cream"],
        "timeTaken": 25,
        "difficulty": "Quick & Easy (under 30 mins)",
        "image": "tacos.jpg"
    },
    {
        "name": "Vegan Buddha Bowl",
        "cusine": "Vegan",
        "mealType": "Lunch",
        "ingredients": ["Quinoa", "Chickpeas", "Avocado", "Spinach", "Tahini"],
        "timeTaken": 30,
        "difficulty": "Intermediate",
        "image": "Vegan Buddha Bowl.jpg"
    },
    {
        "name": "Chicken Alfredo",
        "cusine": "Italian",
        "mealType": "Dinner",
        "ingredients": ["Fettuccine", "Chicken breast", "Heavy cream", "Parmesan cheese", "Garlic"],
        "timeTaken": 40,
        "difficulty": "Intermediate",
        "image": "Chicken Alfredo.jpg"
    },
    {
        "name": "Pad Thai",
        "cusine": "Thai",
        "mealType": "Dinner",
        "ingredients": ["Rice noodles", "Shrimp", "Egg", "Peanuts", "Bean sprouts"],
        "timeTaken": 30,
        "difficulty": "Intermediate",
        "image": "Pad Thai.jpg"
    },
    {
        "name": "Beef Wellington",
        "cusine": "English",
        "mealType": "Dinner",
        "ingredients": ["Beef tenderloin", "Puff pastry", "Mushrooms", "Egg yolk"],
        "timeTaken": 120,
        "difficulty": "Advanced/Gourmet",
        "image": "Beef Wellington.jpg"
    },
    {
        "name": "Falafel",
        "cusine": "Middle Eastern",
        "mealType": "Lunch",
        "ingredients": ["Chickpeas", "Garlic", "Cumin", "Parsley", "Tahini"],
        "timeTaken": 45,
        "difficulty": "Intermediate",
        "image": "Falafel.jpg"
    },
    {
        "name": "Fish Tacos",
        "cusine": "Mexican",
        "mealType": "Lunch",
        "ingredients": ["Fish fillets", "Taco shells", "Cabbage", "Lime", "Cilantro"],
        "timeTaken": 20,
        "difficulty": "Quick & Easy (under 30 mins)",
        "image": "Fish Tacos.jpg"
    },
    {
        "name": "Chicken Tikka Masala",
        "cusine": "Indian",
        "mealType": "Dinner",
        "ingredients": ["Chicken", "Yogurt", "Tomato sauce", "Garam masala", "Cream"],
        "timeTaken": 60,
        "difficulty": "Intermediate",
        "image": "Chicken Tikka Masala.jpg"
    }
]


class UserRequest(BaseModel):
    user_id: str
    recipeCount: int


@router.post("/recipes", response_model=List[RecipeItem])
async def get_recipes(request: UserRequest):
    try:
        user_id = request.user_id
        count = request.recipeCount
        print(f"User ID: {user_id}, Recipe Count: {count}")
        if count <= 0:
            raise HTTPException(status_code=400, detail="Recipe count must be a positive integer")
        recommended = get_recipe_recommendations(user_id,count)
        return recommended
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


class UpdateProfilePicture(BaseModel):
    user_id: str
    profile_pic: str

@router.put("/update-profile-picture")
async def update_profile_picture(data: UpdateProfilePicture):
    try:
        update_fields_dict = {"user_profilePic": data.profile_pic}
        updateUser(data.user_id, update_fields_dict)
        
        return {"message": "Profile picture updated successfully"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/profile/{user_id}")
async def get_user_profile(user_id: str):
    try:
        result = selectUser(query={"_id": user_id})
        if not result:
            raise HTTPException(status_code=404, detail="User not found")
        user_data = result[0]
        return {
            "user_id": user_data["_id"],
            "name": user_data["user_Name"],
            "email": user_data["user_email"],
            "phone": user_data["user_phone"],
            "profile_pic": user_data["user_profilePic"],
            "height": user_data["user_Height"],
            "weight": user_data["user_weight"],
            "diet": user_data["user_diet"],
            "gender": user_data["user_gender"],
            "user_birthday": user_data["user_birthday"],
            "house_Id": user_data.get("house_Id", "")
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

class Task(BaseModel):
    title: str
    description: str
    due_date: str
    assigned_to: str
    category: str
    user_id: str
    is_completed: bool = False
    assignerId: str
    assigneeId: str
    priority: str = 'Medium'

@router.post("/tasks/create")
async def create_task(task: Task):
    try:
        # Initialize MongoDB connection
        client = MongoClient(os.getenv("MONGO_URI"))
        db = client["lili"]
        tasks_collection = db["tasks"]

        # Create task document
        task_dict = task.dict()
        task_dict["created_at"] = datetime.now().isoformat()
        # Store assignerId and assigneeId
        task_dict["assignerId"] = task.assignerId
        task_dict["assigneeId"] = task.assigneeId
        # Insert task into MongoDB
        result = tasks_collection.insert_one(task_dict)
        if not result.inserted_id:
            raise HTTPException(status_code=500, detail="Failed to create task")
        # After task creation, send notification to assignee
        create_notification(
            user_id=task.assigneeId,
            notif_type="task",
            title="New Task Assigned",
            body=f"You have been assigned a new task: {task.title}",
            data={"task_id": str(result.inserted_id)},
            icon="task"
        )
        return {
            "status": "success",
            "message": "Task created successfully",
            "task_id": str(result.inserted_id)
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/tasks/{user_id}")
async def get_tasks(user_id: str):
    try:
        # Initialize MongoDB connection
        client = MongoClient(os.getenv("MONGO_URI"))
        db = client["lili"]
        tasks_collection = db["tasks"]
        # Get all tasks where user is assigner or assignee
        tasks = list(tasks_collection.find({
            "$or": [
                {"assignerId": user_id},
                {"assigneeId": user_id},
                {"user_id": user_id}  # fallback for old tasks
            ]
        }))
        # Convert ObjectId to string for JSON serialization
        for task in tasks:
            task["_id"] = str(task["_id"])
        return tasks
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

class UpdateTaskStatus(BaseModel):
    task_id: str
    is_completed: bool

@router.post("/tasks/update")
async def update_task_status(data: UpdateTaskStatus):
    try:
        client = MongoClient(os.getenv("MONGO_URI"))
        db = client["lili"]
        tasks_collection = db["tasks"]
        object_id = ObjectId(data.task_id)
        # Update task status
        result = tasks_collection.update_one(
            {"_id": object_id},
            {"$set": {"is_completed": data.is_completed, "completed_at": datetime.utcnow() if data.is_completed else None}}
        )
        if result.matched_count == 0:
            raise HTTPException(status_code=404, detail="Task not found")
        # Fetch task to get assignerId and assigneeId
        task = tasks_collection.find_one({"_id": object_id})
        assigner_id = task.get("assignerId")
        assignee_id = task.get("assigneeId")
        # If task is marked completed, send notification to assigner (if not the same user)
        if data.is_completed and assigner_id and assignee_id and str(assigner_id) != str(assignee_id):
            create_notification(
                user_id=assigner_id,
                notif_type="task",
                title="Task Completed",
                body="A task you assigned has been completed.",
                data={"task_id": data.task_id},
                icon="task"
            )
        # If task is updated (not completed), notify assignee
        elif not data.is_completed and assignee_id:
            create_notification(
                user_id=assignee_id,
                notif_type="task",
                title="Task Updated",
                body="A task assigned to you has been updated.",
                data={"task_id": data.task_id},
                icon="task"
            )
        return {"status": "success", "message": "Task status updated successfully"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.delete("/tasks/{task_id}")
async def delete_task(task_id: str):
    try:
        # Initialize MongoDB connection
        client = MongoClient(os.getenv("MONGO_URI"))
        db = client["lili"]
        tasks_collection = db["tasks"]

        # Convert string ID to ObjectId
        object_id = ObjectId(task_id)

        # Delete the task
        result = tasks_collection.delete_one({"_id": object_id})

        if result.deleted_count == 0:
            raise HTTPException(status_code=404, detail="Task not found")

        return {"status": "success", "message": "Task deleted successfully"}

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

# Initialize MongoDB for storing reset tokens
MONGO_URI = os.getenv("MONGO_URI")
client = MongoClient(MONGO_URI)
db = client["lili"]
reset_tokens_collection = db["reset_tokens"]

# Email configuration
EMAIL_HOST = "smtp.gmail.com"
EMAIL_PORT = 587
EMAIL_USER = os.getenv("EMAIL_USER")  # Your Gmail address
EMAIL_PASSWORD = os.getenv("EMAIL_APP_PASSWORD")  # Your Gmail app password

def send_reset_email(to_email: str, reset_code: str):
    msg = MIMEMultipart()
    msg['From'] = EMAIL_USER
    msg['To'] = to_email
    msg['Subject'] = "Password Reset Code - LILI App"
    
    body = f"""
    Hello,
    
    You have requested to reset your password for the LILI App.
    Your password reset code is: {reset_code}
    
    This code will expire in 15 minutes.
    
    If you did not request this reset, please ignore this email.
    
    Best regards,
    LILI App Team
    """
    
    msg.attach(MIMEText(body, 'plain'))
    
    try:
        server = smtplib.SMTP(EMAIL_HOST, EMAIL_PORT)
        server.starttls()
        server.login(EMAIL_USER, EMAIL_PASSWORD)
        server.send_message(msg)
        server.quit()
        return True
    except Exception as e:
        print(f"Error sending email: {e}")
        return False

def generate_reset_code():
    return ''.join(random.choices(string.ascii_uppercase + string.digits, k=6))

class ForgotPasswordRequest(BaseModel):
    email: str

class VerifyCodeRequest(BaseModel):
    email: str
    code: str

class ResetPasswordRequest(BaseModel):
    user_id: str
    new_password: str

@router.post("/forgot-password")
async def forgot_password(request: ForgotPasswordRequest):
    try:
        # Check if email exists in database
        user_result = selectUser(query={"user_email": request.email})
        if not user_result:
            raise HTTPException(status_code=404, detail="Email not found")
        
        # Generate reset code
        reset_code = generate_reset_code()
        
        # Store reset code in MongoDB with expiration
        reset_tokens_collection.insert_one({
            "email": request.email,
            "code": reset_code,
            "created_at": datetime.utcnow(),
            "expires_at": datetime.utcnow() + timedelta(minutes=15)
        })
        
        # Send reset email
        if not send_reset_email(request.email, reset_code):
            raise HTTPException(status_code=500, detail="Failed to send reset email")
        
        return {"message": "Reset code sent to email"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.post("/verify-reset-code")
async def verify_reset_code(request: VerifyCodeRequest):
    try:
        # Find valid reset token
        token = reset_tokens_collection.find_one({
            "email": request.email,
            "code": request.code,
            "expires_at": {"$gt": datetime.utcnow()}
        })
        
        if not token:
            raise HTTPException(status_code=400, detail="Invalid or expired code")
        
        return {"message": "Code verified successfully"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.post("/reset-password")
async def reset_password(request: ResetPasswordRequest):
    try:
        user_id = request.user_id
        new_password = request.new_password
        updated = updateUser(user_id, {"user_password": new_password})
        if updated:
            return {"message": "Password updated successfully"}
        else:
            raise HTTPException(status_code=404, detail="User not found or password not updated")
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

class UpdateProfileRequest(BaseModel):
    user_id: str
    name: str
    email: str
    phone: str
    height: float = None
    weight: float = None
    diet: str = None
    gender: str = None
    birthday: str = None
    allergies: list[str] = []

@router.put("/update-profile")
async def update_profile(data: UpdateProfileRequest):
    try:
        # Update user data
        update_fields_dict = {
            "user_Name": data.name,
            "user_email": data.email,
            "user_phone": data.phone,
            "user_Height": data.height if data.height is not None else 'NULL',
            "user_weight": data.weight if data.weight is not None else 'NULL',
            "user_diet": data.diet if data.diet is not None else 'NULL',
            "user_gender": data.gender if data.gender is not None else 'NULL',
            "user_birthday": data.birthday if data.birthday is not None else 'NULL'
        }
        
        updateUser(data.user_id, update_fields_dict)

        # Delete existing allergies
        delete_query = f'DELETE FROM allergy_tbl WHERE user_Id = "{data.user_id}"'
        updateUser(data.user_id, {"allergies": []})

        # Insert new allergies
        for allergy in data.allergies:
            if allergy.strip():
                insertAllergy(allergy_name=allergy.strip(), user_Id=data.user_id)

        create_notification(
            user_id=data.user_id,
            notif_type="system",
            title="Profile Updated",
            body="Your profile information was updated.",
            data={},
            icon="person"
        )

        return {"message": "Profile updated successfully"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/allergies/{user_id}")
async def get_user_allergies(user_id: str):
    try:
        result = selectAllergy(query={"user_Id": user_id})
        if not result:
            return {"allergies": []}
            
        allergies = [row["allergy_name"] for row in result]
        return {"allergies": allergies}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

class LogoutRequest(BaseModel):
    user_id: str

@router.post("/logout")
async def logout(request: LogoutRequest):
    try:
        user_id = request.user_id
        updated = updateUser(user_id, {"user_isLoggedIn": False})
        if updated:
            return {"message": "User logged out successfully"}
        else:
            raise HTTPException(status_code=404, detail="User not found or not updated")
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

FEEDBACK_FILE = 'feedbacks.json'

def load_feedbacks():
    try:
        with open(FEEDBACK_FILE, 'r') as f:
            return json.load(f)
    except Exception:
        return {}

def save_feedbacks(feedbacks):
    with open(FEEDBACK_FILE, 'w') as f:
        json.dump(feedbacks, f)

class FeedbackRequest(BaseModel):
    user_id: str
    feedback: str
    rating: int = 0

@router.post("/feedback")
async def submit_feedback(request: FeedbackRequest):
    feedbacks = load_feedbacks()
    feedbacks[request.user_id] = {
        "feedback": request.feedback,
        "rating": request.rating
    }
    save_feedbacks(feedbacks)
    return {"message": "Feedback saved successfully"}

@router.get("/feedback/{user_id}")
async def get_feedback(user_id: str):
    feedbacks = load_feedbacks()
    entry = feedbacks.get(user_id, {})
    return {
        "user_id": user_id,
        "feedback": entry.get("feedback", ""),
        "rating": entry.get("rating", 0)
    }

@router.get("/household/{house_id}")
async def get_household(house_id: str):
    result = selectHouseHold(query={"_id": house_id})
    if not result:
        raise HTTPException(status_code=404, detail="Household not found")
    house = result[0]
    return {
        "house_id": house["_id"],
        "name": house.get("house_Name", ""),
        "address": house.get("house_address", ""),
        "pic": house.get("house_pic", ""),
        "join_code": house.get("join_code", "")
    }

@router.get("/household-by-code/{join_code}")
async def get_household_by_code(join_code: str):
    result = selectHouseHold(query={"join_code": join_code})
    if not result:
        raise HTTPException(status_code=404, detail="No household with this code")
    house = result[0]
    return {
        "house_id": house["_id"],
        "name": house.get("house_Name", ""),
        "address": house.get("house_address", ""),
        "pic": house.get("house_pic", ""),
        "join_code": house.get("join_code", "")
    }

@router.post("/update-house")
async def update_user_house(data: dict):
    user_id = data.get("user_id")
    house_id = data.get("house_id")
    if not user_id or not house_id:
        raise HTTPException(status_code=400, detail="user_id and house_id required")
    # Assign standard user role when joining a house (unless already admin)
    user = selectUser(query={"_id": user_id})
    if user and user[0].get("user_role") != "admin":
        updated = updateUser(user_id, {"house_Id": house_id, "user_role": "user"})
    else:
        updated = updateUser(user_id, {"house_Id": house_id})
    if updated:
        return {"message": "User's household updated"}
    else:
        raise HTTPException(status_code=404, detail="User not found or not updated")

@router.post("/check-uniqueness")
def check_uniqueness(data: dict = Body(...)):
    username = data.get("username", "")
    email = data.get("email", "")
    phone = data.get("phone", "")
    result = check_user_uniqueness(username, email, phone)
    return {"result": result}

@router.get("/household-users/{user_id}")
def get_household_users(user_id: str):
    # Find the user's household
    user_result = selectUser(query={"_id": user_id})
    if not user_result:
        raise HTTPException(status_code=404, detail="User not found")
    house_id = user_result[0].get("house_Id", "")
    if not house_id:
        return []
    # Find all users in the same household
    users = selectUser(query={"house_Id": house_id})
    return [
        {
            "user_id": u["_id"],
            "name": u.get("user_Name", ""),
            "username": u.get("username", ""),
            "email": u.get("user_email", ""),
            "profile_pic": u.get("user_profilePic", ""),
            "user_role": u.get("user_role", "user"),
        }
        for u in users
    ]

@router.post("/remove-from-household")
def remove_from_household(data: dict = Body(...)):
    user_id = data.get("user_id")
    if not user_id:
        raise HTTPException(status_code=400, detail="user_id required")
    updated = updateUser(user_id, {"house_Id": ""})
    if updated:
        return {"message": "User removed from household"}
    else:
        raise HTTPException(status_code=404, detail="User not found or not updated")

class UpdateTaskRequest(BaseModel):
    task_id: str
    title: str
    description: str
    due_date: str
    assigned_to: str
    category: str
    is_completed: bool
    assignerId: str
    assigneeId: str

@router.put("/tasks/update-full")
async def update_task_full(data: UpdateTaskRequest):
    try:
        client = MongoClient(os.getenv("MONGO_URI"))
        db = client["lili"]
        tasks_collection = db["tasks"]
        object_id = ObjectId(data.task_id)
        update_fields = {
            "title": data.title,
            "description": data.description,
            "due_date": data.due_date,
            "assigned_to": data.assigned_to,
            "category": data.category,
            "is_completed": data.is_completed,
            "assignerId": data.assignerId,
            "assigneeId": data.assigneeId,
        }
        result = tasks_collection.update_one(
            {"_id": object_id},
            {"$set": update_fields}
        )
        if result.matched_count == 0:
            raise HTTPException(status_code=404, detail="Task not found")
        return {"status": "success", "message": "Task updated successfully"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

# --- User Recipes Endpoints ---
class UserRecipeRequest(BaseModel):
    user_id: str
    recipe: dict
    shared: bool = False

@router.post("/recipes/save")
async def save_user_recipe(data: UserRecipeRequest):
    try:
        client = MongoClient(os.getenv("MONGO_URI"))
        db = client["lili"]
        recipes_collection = db["usersRecipes"]
        # Add user_id and shared flag to the recipe document
        recipe_doc = data.recipe.copy()
        recipe_doc["user_id"] = data.user_id
        recipe_doc["shared"] = data.shared
        recipe_doc["created_at"] = datetime.now().isoformat()
        result = recipes_collection.insert_one(recipe_doc)
        if not result.inserted_id:
            raise HTTPException(status_code=500, detail="Failed to save recipe")
        return {"status": "success", "message": "Recipe saved", "recipe_id": str(result.inserted_id)}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/recipes/{user_id}")
async def get_user_recipes(user_id: str, shared: bool = Query(False)):
    try:
        client = MongoClient(os.getenv("MONGO_URI"))
        db = client["lili"]
        recipes_collection = db["usersRecipes"]
        if shared:
            # Get the user's household
            user_result = selectUser(query={"_id": user_id})
            if not user_result:
                raise HTTPException(status_code=404, detail="User not found")
            house_id = user_result[0].get("house_Id", "")
            if not house_id:
                return []
            # Find all users in the same household
            users = selectUser(query={"house_Id": house_id})
            user_ids = [u["_id"] for u in users]
            recipes = list(recipes_collection.find({"user_id": {"$in": user_ids}, "shared": True}))
        else:
            recipes = list(recipes_collection.find({"user_id": user_id}))
        for recipe in recipes:
            recipe["_id"] = str(recipe["_id"])
        return recipes
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

class UpdateRecipeSharedRequest(BaseModel):
    recipe_id: str
    shared: bool

@router.put("/recipes/update-shared")
async def update_recipe_shared(data: UpdateRecipeSharedRequest):
    try:
        client = MongoClient(os.getenv("MONGO_URI"))
        db = client["lili"]
        recipes_collection = db["usersRecipes"]
        from bson import ObjectId
        object_id = ObjectId(data.recipe_id)
        result = recipes_collection.update_one(
            {"_id": object_id},
            {"$set": {"shared": data.shared}}
        )
        if result.matched_count == 0:
            raise HTTPException(status_code=404, detail="Recipe not found")
        # If recipe is shared, notify all household users except the sharer
        if data.shared:
            recipe_doc = recipes_collection.find_one({"_id": object_id})
            sharer_id = recipe_doc.get("user_id")
            # Get sharer's household
            user_result = selectUser(query={"_id": sharer_id})
            if user_result:
                house_id = user_result[0].get("house_Id", "")
                if house_id:
                    users = selectUser(query={"house_Id": house_id})
                    for u in users:
                        uid = u["_id"]
                        if str(uid) != str(sharer_id):
                            create_notification(
                                user_id=uid,
                                notif_type="recipe",
                                title="Recipe Shared",
                                body="A new recipe has been shared with your household.",
                                data={"recipe_id": data.recipe_id},
                                icon="recipe"
                            )
        return {"status": "success", "message": "Recipe sharing updated"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

class RecipeCookedRequest(BaseModel):
    user_id: str
    recipe_name: str
    ingredients: List[str]
    meal_type: str = ""
    cooking_time: str = ""

@router.post("/preferences/update-on-cook")
async def update_preferences_on_recipe_cooked(data: RecipeCookedRequest):
    """
    Update user preferences when a recipe is cooked.
    This endpoint is called when the user completes cooking a recipe.
    """
    try:
        result = update_preferences_on_cook(
            user_id=data.user_id,
            recipe_ingredients=data.ingredients,
            recipe_name=data.recipe_name,
            meal_type=data.meal_type,
            cooking_time=data.cooking_time
        )
        return result
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/preferences/{user_id}")
async def get_user_preferences_endpoint(user_id: str):
    """
    Get user preferences and cooking history.
    """
    try:
        preferences = get_user_preferences(user_id)
        return preferences
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

################ Favorite Recipes Management ################

class FavoriteRecipeRequest(BaseModel):
    user_id: str
    recipe: dict

class RemoveFavoriteRequest(BaseModel):
    user_id: str
    recipe_name: str

@router.post("/favorites/add")
async def add_favorite_recipe(data: FavoriteRecipeRequest):
    try:
        client = MongoClient(os.getenv("MONGO_URI"))
        db = client["lili"]
        favorites_collection = db["favoriteRecipes"]
        
        # Check if recipe is already favorited by this user
        existing_favorite = favorites_collection.find_one({
            "user_id": data.user_id,
            "name": data.recipe["name"]
        })
        
        if existing_favorite:
            raise HTTPException(status_code=400, detail="Recipe is already in favorites")
        
        # Add user_id and timestamp to the recipe document
        favorite_doc = data.recipe.copy()
        favorite_doc["user_id"] = data.user_id
        favorite_doc["added_at"] = datetime.now().isoformat()
        
        result = favorites_collection.insert_one(favorite_doc)
        if not result.inserted_id:
            raise HTTPException(status_code=500, detail="Failed to save favorite recipe")
        
        return {"status": "success", "message": "Recipe added to favorites", "favorite_id": str(result.inserted_id)}
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.delete("/favorites/remove")
async def remove_favorite_recipe(data: RemoveFavoriteRequest):
    try:
        client = MongoClient(os.getenv("MONGO_URI"))
        db = client["lili"]
        favorites_collection = db["favoriteRecipes"]
        
        result = favorites_collection.delete_one({
            "user_id": data.user_id,
            "name": data.recipe_name
        })
        
        if result.deleted_count == 0:
            raise HTTPException(status_code=404, detail="Favorite recipe not found")
        
        return {"status": "success", "message": "Recipe removed from favorites"}
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/favorites/{user_id}")
async def get_favorite_recipes(user_id: str):
    try:
        client = MongoClient(os.getenv("MONGO_URI"))
        db = client["lili"]
        favorites_collection = db["favoriteRecipes"]
        
        favorites = list(favorites_collection.find({"user_id": user_id}))
        
        # Convert ObjectId to string for JSON serialization
        for favorite in favorites:
            favorite["_id"] = str(favorite["_id"])
        
        return favorites
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/favorites/{user_id}/check/{recipe_name}")
async def check_favorite_status(user_id: str, recipe_name: str):
    try:
        client = MongoClient(os.getenv("MONGO_URI"))
        db = client["lili"]
        favorites_collection = db["favoriteRecipes"]
        
        favorite = favorites_collection.find_one({
            "user_id": user_id,
            "name": recipe_name
        })
        
        return {"is_favorite": favorite is not None}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

# Scheduled job for near expiry, expired, and low stock (pseudo-code)
def check_inventory_alerts():
    now = datetime.utcnow()
    # items = ... # Fetch all inventory items
    for item in items:
        expiry = datetime.fromisoformat(item['expiry']) if 'expiry' in item else None
        if expiry:
            if expiry < now:
                create_notification(
                    user_id=item['user_id'],
                    notif_type="inventory",
                    title="Item Expired",
                    body=f"{item['name']} has expired!",
                    data={"item_name": item['name']},
                    icon="inventory"
                )
            elif expiry - now < timedelta(days=3):
                create_notification(
                    user_id=item['user_id'],
                    notif_type="inventory",
                    title="Item Near Expiry",
                    body=f"{item['name']} will expire soon.",
                    data={"item_name": item['name']},
                    icon="inventory"
                )
        if item['quantity'] < 2:  # Example threshold
            create_notification(
                user_id=item['user_id'],
                notif_type="inventory",
                title="Low Stock Alert",
                body=f"{item['name']} is running low.",
                data={"item_name": item['name']},
                icon="inventory"
            )

# Scheduled job to delete completed tasks after 1 day
def delete_old_completed_tasks():
    client = MongoClient(os.getenv("MONGO_URI"))
    db = client["lili"]
    tasks_collection = db["tasks"]
    cutoff = datetime.utcnow() - timedelta(days=1)
    result = tasks_collection.delete_many({"is_completed": True, "completed_at": {"$lt": cutoff}})
    print(f"Deleted {result.deleted_count} completed tasks older than 1 day.")

################ Expense Goals Management ################

class ExpenseGoal(BaseModel):
    id: Optional[str] = None
    user_id: str
    category: str
    target_amount: float
    current_amount: float = 0.0
    period: str  # weekly, monthly, yearly
    start_date: str
    end_date: str
    is_active: bool = True

class ExpenseGoalRequest(BaseModel):
    user_id: str

class UpdateGoalProgressRequest(BaseModel):
    goal_id: str
    current_amount: float

@router.post("/expense-goals/add")
async def add_expense_goal(goal: ExpenseGoal):
    try:
        client = MongoClient(os.getenv("MONGO_URI"))
        db = client["lili"]
        goals_collection = db["expenseGoals"]
        
        # Check if user already has a goal for this category
        existing_goal = goals_collection.find_one({
            "user_id": goal.user_id,
            "category": goal.category,
            "is_active": True
        })
        
        if existing_goal:
            raise HTTPException(status_code=400, detail="Goal already exists for this category")
        
        goal_dict = goal.dict()
        # Remove the id field since MongoDB will generate _id
        goal_dict.pop("id", None)
        goal_dict["created_at"] = datetime.utcnow().isoformat()
        goal_dict["updated_at"] = datetime.utcnow().isoformat()
        
        result = goals_collection.insert_one(goal_dict)
        if not result.inserted_id:
            raise HTTPException(status_code=500, detail="Failed to create expense goal")
        
        return {"success": True, "message": "Expense goal created successfully", "goal_id": str(result.inserted_id)}
    except HTTPException:
        raise
    except Exception as e:
        print(f"Error adding expense goal: {str(e)}")
        raise HTTPException(status_code=500, detail=str(e))

@router.post("/expense-goals/get")
async def get_expense_goals(data: ExpenseGoalRequest):
    try:
        client = MongoClient(os.getenv("MONGO_URI"))
        db = client["lili"]
        goals_collection = db["expenseGoals"]
        
        goals = list(goals_collection.find({
            "user_id": data.user_id,
            "is_active": True
        }))
        
        # Convert ObjectId to string and map _id to id for Flutter compatibility
        for goal in goals:
            goal["id"] = str(goal["_id"])
            goal.pop("_id", None)
        
        return {"success": True, "goals": goals}
    except Exception as e:
        print(f"Error getting expense goals: {str(e)}")
        raise HTTPException(status_code=500, detail=str(e))

@router.post("/expense-goals/get-with-progress")
async def get_expense_goals_with_progress(data: ExpenseGoalRequest):
    try:
        client = MongoClient(os.getenv("MONGO_URI"))
        db = client["lili"]
        goals_collection = db["expenseGoals"]
        transactions_collection = db["transactions"]
        
        goals = list(goals_collection.find({
            "user_id": data.user_id,
            "is_active": True
        }))
        
        # Calculate current progress for each goal
        for goal in goals:
            # Get transactions for this category within the goal period
            start_date = datetime.fromisoformat(goal["start_date"])
            end_date = datetime.fromisoformat(goal["end_date"])
            # For monthly goals, always use the 1st to last day of the month
            if goal["period"].lower() == "monthly":
                month_start = start_date.replace(day=1)
                if start_date.month == 12:
                    next_month = start_date.replace(year=start_date.year+1, month=1, day=1)
                else:
                    next_month = start_date.replace(month=start_date.month+1, day=1)
                month_end = next_month - timedelta(days=1)
                query_start = month_start.isoformat()
                query_end = month_end.isoformat()
            else:
                query_start = start_date.isoformat()
                query_end = end_date.isoformat()

            transactions = list(transactions_collection.find({
                "user_id": data.user_id,
                "category": goal["category"],
                "transaction_type": "expense",
                "date": {
                    "$gte": query_start,
                    "$lte": query_end
                }
            }))
            
            # Calculate total spent in this category
            current_amount = sum(t["amount"] for t in transactions)
            goal["current_amount"] = current_amount
            
            # Convert ObjectId to string and map _id to id for Flutter compatibility
            goal["id"] = str(goal["_id"])
            goal.pop("_id", None)
        
        return {"success": True, "goals": goals}
    except Exception as e:
        print(f"Error getting expense goals with progress: {str(e)}")
        raise HTTPException(status_code=500, detail=str(e))

@router.put("/expense-goals/update")
async def update_expense_goal(goal: ExpenseGoal):
    try:
        client = MongoClient(os.getenv("MONGO_URI"))
        db = client["lili"]
        goals_collection = db["expenseGoals"]
        
        # Validate ObjectId format
        try:
            goal_id = ObjectId(goal.id)
        except Exception:
            raise HTTPException(status_code=400, detail="Invalid goal ID format")
        
        goal_dict = goal.dict()
        goal_dict["updated_at"] = datetime.utcnow().isoformat()
        
        # Remove the id field from the update data since it's the query parameter
        goal_dict.pop("id", None)
        
        result = goals_collection.update_one(
            {"_id": goal_id},
            {"$set": goal_dict}
        )
        
        if result.matched_count == 0:
            raise HTTPException(status_code=404, detail="Expense goal not found")
        
        return {"success": True, "message": "Expense goal updated successfully"}
    except HTTPException:
        raise
    except Exception as e:
        print(f"Error updating expense goal: {str(e)}")
        raise HTTPException(status_code=500, detail=str(e))

@router.delete("/expense-goals/delete")
async def delete_expense_goal(data: dict):
    try:
        client = MongoClient(os.getenv("MONGO_URI"))
        db = client["lili"]
        goals_collection = db["expenseGoals"]
        
        goal_id = data.get("goal_id")
        if not goal_id:
            raise HTTPException(status_code=400, detail="goal_id is required")
        
        # Validate ObjectId format
        try:
            object_id = ObjectId(goal_id)
        except Exception:
            raise HTTPException(status_code=400, detail="Invalid goal ID format")
        
        result = goals_collection.delete_one({"_id": object_id})
        
        if result.deleted_count == 0:
            raise HTTPException(status_code=404, detail="Expense goal not found")
        
        return {"success": True, "message": "Expense goal deleted successfully"}
    except HTTPException:
        raise
    except Exception as e:
        print(f"Error deleting expense goal: {str(e)}")
        raise HTTPException(status_code=500, detail=str(e))

@router.put("/expense-goals/update-progress")
async def update_goal_progress(data: UpdateGoalProgressRequest):
    try:
        client = MongoClient(os.getenv("MONGO_URI"))
        db = client["lili"]
        goals_collection = db["expenseGoals"]
        
        # Validate ObjectId format
        try:
            goal_id = ObjectId(data.goal_id)
        except Exception:
            raise HTTPException(status_code=400, detail="Invalid goal ID format")
        
        result = goals_collection.update_one(
            {"_id": goal_id},
            {
                "$set": {
                    "current_amount": data.current_amount,
                    "updated_at": datetime.utcnow().isoformat()
                }
            }
        )
        
        if result.matched_count == 0:
            raise HTTPException(status_code=404, detail="Expense goal not found")
        
        return {"success": True, "message": "Goal progress updated successfully"}
    except HTTPException:
        raise
    except Exception as e:
        print(f"Error updating goal progress: {str(e)}")
        raise HTTPException(status_code=500, detail=str(e))

from fastapi import Depends
class UpdateUserRoleRequest(BaseModel):
    user_id: str
    new_role: str  # 'admin' or 'user'
    house_id: str

@router.post("/update-user-role")
def update_user_role(req: UpdateUserRoleRequest):
    # Only allow admin to change roles
    requesting_user_id = req.user_id
    new_role = req.new_role
    target_user_id = req.user_id
    house_id = req.house_id
    # Find all users in the household
    users = selectUser(query={"house_Id": house_id})
    # Count current admins
    admin_count = sum(1 for u in users if u.get("user_role") == "admin")
    # Prevent demoting the last admin
    if new_role == "user":
        if admin_count <= 1:
            raise HTTPException(status_code=400, detail="Cannot demote the last admin in the household.")
    # Update the user's role
    updated = updateUser(target_user_id, {"user_role": new_role})
    if updated:
        return {"message": f"User role updated to {new_role}"}
    else:
        raise HTTPException(status_code=404, detail="User not found or not updated")

# --- Category Management ---
class CategoryModel(BaseModel):
    user_id: str
    name: str
    description: str = ""

@router.post("/category/add")
def add_category(category: CategoryModel):
    client = MongoClient(os.getenv("MONGO_URI"))
    db = client["lili"]
    categories_collection = db["categories"]
    # Prevent duplicates for the same user
    if categories_collection.find_one({"user_id": category.user_id, "name": category.name}):
        raise HTTPException(status_code=400, detail="Category already exists for this user")
    categories_collection.insert_one(category.dict())
    return {"status": "success", "message": "Category added"}

@router.get("/categories/{user_id}")
def get_categories(user_id: str):
    client = MongoClient(os.getenv("MONGO_URI"))
    db = client["lili"]
    categories_collection = db["categories"]
    categories = list(categories_collection.find({"user_id": user_id}))
    for c in categories:
        c["id"] = str(c["_id"])
        c.pop("_id", None)
    return {"categories": categories}

@router.delete("/category/delete")
def delete_category(user_id: str = Query(...), name: str = Query(...)):
    client = MongoClient(os.getenv("MONGO_URI"))
    db = client["lili"]
    categories_collection = db["categories"]
    result = categories_collection.delete_one({"user_id": user_id, "name": name})
    if result.deleted_count == 0:
        raise HTTPException(status_code=404, detail="Category not found for this user")
    return {"status": "success", "message": "Category deleted"}

