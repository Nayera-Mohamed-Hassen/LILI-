
from pymongo import MongoClient
import os
from dotenv import load_dotenv

load_dotenv()

MONGO_URI = os.getenv("MONGO_URI")
client = MongoClient(MONGO_URI)
db = client["lili"]  # your MongoDB database name, adjust if needed
  # collection to store recipes

def insert_recipe(recipe_data: dict) -> bool:
    collection = db["recipes"]
    try:
        collection.insert_one(recipe_data)
        return True
    except Exception as e:
        print("MongoDB insert error:", e)
        return False


def insert_recipes(recipes):
    collection = db["recipes"]
    """Insert multiple recipes into the recipes collection."""
    result = collection.insert_many(recipes)
    print(f"Inserted recipe IDs: {result.inserted_ids}")

def get_recipes():
    """Retrieve all recipes from the recipes collection."""
    collection = db["recipes"]
    recipes = list(collection.find())
    return recipes


def getInventory(id=0):
    collection = db["inventory"]
    results = collection.find({"house_id": id})
    return results

if __name__ == "__main__":
    for i in getInventory(id=1):
        print(i)