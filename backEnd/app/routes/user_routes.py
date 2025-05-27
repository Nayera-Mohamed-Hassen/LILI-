import os
from typing import Optional
from datetime import datetime, timedelta
from difflib import get_close_matches
from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from pymongo import MongoClient

from app.mySQLConnection import insertUser, selectUser, insertAllergy, insertHouseHold, executeWriteQuery, selectHouseHold

HouseHold_id = 1  # Default household ID, can be changed as needed
user_id = 1  # Default user ID, can be changed as needed

router = APIRouter(prefix="/user", tags=["User"])

def get_household_id() -> int:
    try:
        HouseHold_id = selectUser("select house_Id from user_tbl where user_Id = " + str(user_id))
        if not HouseHold_id:
            raise HTTPException(status_code=404, detail="Household not found")
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
    if HouseHold_id:
        HouseHold_id = HouseHold_id[0]["house_Id"]
    else:
        raise HTTPException(status_code=404, detail="Household not found")  
    return HouseHold_id

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
    house_id: int = 1
    allergy: str = ""

@router.post("/signup")
def signup(user: UserSignup):
    # Insert user into the database
    success = insertUser(
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
        house_Id=user.house_id
    )

    if not success:
        raise HTTPException(status_code=500, detail="Signup failed")

    # Retrieve user ID based on email
    print(user.email)
    # Assuming selectUser is a function that retrieves user ID based on email
    # Adjust the query to use parameterized queries to prevent SQL injection
    result = selectUser(
        'SELECT user_Id FROM user_tbl WHERE user_email = "' + user.email +'"' # use values or your function's correct arg
    )
    user_id = result[0]["user_Id"]

    if user_id is None:
        raise HTTPException(status_code=500, detail="Failed to retrieve user ID")

    # Insert allergies
    allergies = user.allergy.split(",") if user.allergy else []
    for a in allergies:
        if a.strip():
            insertAllergy(allergy_name=a.strip(), user_Id=user_id)

    return {"message": "User signed up successfully"}





################ user login ################

class UserLogin(BaseModel):
    email: str
    password: str



@router.post("/login")
async def login(user: UserLogin):
    try:
        query = 'SELECT * FROM user_tbl WHERE user_email = "'+user.email + '"AND user_password = "'+ user.password + '"'
        result = selectUser(query=query)

        if result:
            user_id = result[0]["user_Id"]
            return {"status": "success", "user_id": result[0]["user_Id"]}
        else:
            raise HTTPException(status_code=401, detail="Invalid email or password")
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


################ Create Household ################

class HouseHold(BaseModel):
    name: str
    pic: str
    address: str
    email: str



@router.post("/household/create")
async def create_household(data: HouseHold):
    
    # 1. Insert the household
    success = insertHouseHold(data.name, data.pic, data.address)
    if not success:
        raise HTTPException(status_code=500, detail="Failed to create household")

    # 2. Get household id by name (if insertHouseHold doesn't return it)
    house_result = selectUser(query=f'SELECT house_Id FROM household_tbl WHERE house_Name = "{data.name}"')

    if not house_result:
        raise HTTPException(status_code=404, detail="Household not found")

    house_id = house_result[0]["house_Id"]
    print(f"Household ID: {house_id}")

    # 3. Update the user's house_id
    update_query = f'UPDATE user_tbl SET house_Id = {house_id} WHERE user_email = "{data.email}"'

    print(f"Update Query: {update_query}")
    executeWriteQuery(query=update_query)  # run update using existing query function

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
    user_id: int  # Added user_id here


@router.post("/inventory/add")
async def add_item(item: InventoryItem):
    try:
        expiry_info,name = estimate_expiry_date(item.name)

        print(item.user_id)
        house_result = selectUser(f'SELECT house_Id FROM user_tbl WHERE user_Id = "{item.user_id}"')
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
    user_id: int
    name: str
    expiry: str

@router.delete("/inventory/delete")
async def delete_inventory_item(data: DeleteItemRequest):
    try:
        # Get house_id using user_id from MySQL
        house_result = selectUser(f'SELECT house_Id FROM user_tbl WHERE user_Id = "{data.user_id}"')
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
    user_id: int
    name: str
    quantity: int

@router.put("/inventory/update-quantity")
async def update_inventory_quantity(data: UpdateQuantityRequest):
    try:
        # Get house_id using user_id from MySQL
        house_result = selectUser(f'SELECT house_Id FROM user_tbl WHERE user_Id = "{data.user_id}"')
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
    user_id: int

@router.post("/inventory/get-items")
async def get_inventory_items(data: UserRequest):
    try:
        house_result = selectUser(f'SELECT house_Id FROM user_tbl WHERE user_Id = "{data.user_id}"')
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
