import os
from typing import List, Optional, Union
from datetime import datetime, timedelta
from difflib import get_close_matches
from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from pymongo import MongoClient
from ..recipeAI import get_recipe_recommendations
from ..mySQLConnection import selectUser, selectAllergy, insertUser, insertHouseHold, insertAllergy, updateUser
from bson import ObjectId
import random
import string
import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart


router = APIRouter(prefix="/user", tags=["User"])

################ User Signup  ################

class UserSignup(BaseModel):
    name: str
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
    # Insert user into the database
    user_id = insertUser(
        user_Name=user.name,
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
    email: str
    password: str



@router.post("/login")
async def login(user: UserLogin):
    try:
        query = 'SELECT * FROM user_tbl WHERE user_email = "'+user.email + '"AND user_password = "'+ user.password + '"'
        result = selectUser(query={"user_email": user.email, "user_password": user.password})

        if result:
            user_id = result[0]["_id"]
            house_id = result[0].get("house_Id", "")
            return {"status": "success", "user_id": user_id, "house_Id": house_id}
        else:
            raise HTTPException(status_code=401, detail="Invalid email or password")
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
    # 1. Insert the household and get the new house_id
    house_id = insertHouseHold(data.name, data.pic, data.address)
    if not house_id:
        raise HTTPException(status_code=500, detail="Failed to create household")

    # 2. Update the user's house_Id with the new house_id
    user_result = selectUser(query={"_id": data.user_id})
    if not user_result:
        raise HTTPException(status_code=404, detail="User not found")
    user_id = user_result[0]["_id"]
    updateUser(user_id, {"house_Id": house_id})

    return {"message": "Household created", "house_id": house_id}




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


def estimate_expiry_date(item_name: str) -> dict:
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
    #image: Optional[str]
    user_id: str  # Added user_id here


@router.post("/inventory/add")
async def add_item(item: InventoryItem):
    try:
        expiry_info, name = estimate_expiry_date(item.name)

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
            "user_id": item.user_id,
            "expiry_date": expiry_info,
            "house_id": house_id
        }
        inventory_collection.insert_one(item_dict)
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
    expiry: str

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

        print(data.expiry)
        # Delete inventory items that match name and house_id
        delete_result = inventory_collection.delete_many({
            "house_id": house_id,
            "name": data.name,
            "expiry_date": data.expiry  # Assuming expiry is a string in the format "YYYY-MM-DD"
        })

        if delete_result.deleted_count == 0:
            return {"status": "not_found", "message": "No matching items found to delete"}

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

        # Update the quantity of the matching item
        update_result = inventory_collection.update_one(
            {"house_id": house_id, "name": data.name},
            {"$set": {"quantity": data.quantity}}
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
        
        # Insert task into MongoDB
        result = tasks_collection.insert_one(task_dict)
        
        if not result.inserted_id:
            raise HTTPException(status_code=500, detail="Failed to create task")

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

        # Get all tasks for the user
        tasks = list(tasks_collection.find({"user_id": user_id}))
        
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
        # Initialize MongoDB connection
        client = MongoClient(os.getenv("MONGO_URI"))
        db = client["lili"]
        tasks_collection = db["tasks"]

        # Convert string ID to ObjectId
        object_id = ObjectId(data.task_id)

        # Update task status
        result = tasks_collection.update_one(
            {"_id": object_id},
            {"$set": {"is_completed": data.is_completed}}
        )

        if result.matched_count == 0:
            raise HTTPException(status_code=404, detail="Task not found")

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
    email: str
    code: str
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
        # Verify code again
        token = reset_tokens_collection.find_one({
            "email": request.email,
            "code": request.code,
            "expires_at": {"$gt": datetime.utcnow()}
        })
        
        if not token:
            raise HTTPException(status_code=400, detail="Invalid or expired code")
        
        # Update password in database
        update_fields_dict = {"user_password": request.new_password}
        updateUser(request.email, update_fields_dict)
        
        # Delete used token
        reset_tokens_collection.delete_many({"email": request.email})
        
        return {"message": "Password updated successfully"}
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

