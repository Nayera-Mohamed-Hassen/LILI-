import os
import json
from datetime import datetime
import numpy as np
import pandas as pd
from xgboost import XGBClassifier
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.metrics import accuracy_score
from sklearn.model_selection import train_test_split
from pymongo import MongoClient
from dotenv import load_dotenv
from app.mySQLConnection import selectUser, selectAllergy
from fastapi import HTTPException

def get_recipe_recommendations(user_id,count=1):
    # ---------- CONFIGURATION ----------
    
    load_dotenv()
    MONGO_URI = os.getenv("MONGO_URI")
    MYSQL_CONFIG = {
        "host": os.getenv("MYSQL_HOST"),
        "port": os.getenv("MYSQL_PORT"),
        "user": os.getenv("MYSQL_USER"),
        "password": os.getenv("MYSQL_PASSWORD"),
        "database": os.getenv("MYSQL_DATABASE")
    }

    # Get the directory where this script is located
    SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
    PREFS_FILE = os.path.join(SCRIPT_DIR,"..","data" ,"user_preferences.json")
    RECIPES_JSON = os.path.join(SCRIPT_DIR,"..", "data", "recipes.json")

    # ---------- LOAD INVENTORY FROM MONGODB ----------
    mongo_client = MongoClient(MONGO_URI)
    MONGO_DB = "lili"
    mongo_db = mongo_client[MONGO_DB]
    inventory_col = mongo_db["inventory"]

    try:
        house_result = selectUser(f'SELECT house_Id FROM user_tbl WHERE user_Id = "{user_id}"')
        if not house_result:
            raise HTTPException(status_code=404, detail="House ID not found for user")

        house_id = house_result[0]["house_Id"]

    except Exception as e:
        print(f"Error fetching house ID: {e}")
        raise

    # Fetch household inventory
    household_items = list(inventory_col.find({"house_id": house_id}))
    available_ingredients = []
    for item in household_items:
        expiry = datetime.fromisoformat(item["expiry_date"])
        if expiry >= datetime.now():
            available_ingredients.append(item["name"].lower())

    # ---------- LOAD USER ALLERGIES FROM MYSQL ----------
    user_allergies = selectAllergy(id=user_id)
    if user_allergies is None:
        raise HTTPException(status_code=404, detail="Error fetching allergies for user")
    user_allergies = [a["allergy_name"].lower() for a in user_allergies] if user_allergies else []

    # ---------- USER PREFERENCES FUNCTIONS ----------
    def ensure_prefs_file_exists():
        """Create the preferences file if it doesn't exist"""
        if not os.path.exists(PREFS_FILE):
            os.makedirs(os.path.dirname(PREFS_FILE), exist_ok=True)
            with open(PREFS_FILE, 'w') as f:
                json.dump({}, f)

    def load_user_preferences(user_id):
        """Load user preferences, creating file if needed"""
        ensure_prefs_file_exists()
        try:
            with open(PREFS_FILE, "r") as f:
                data = json.load(f)
            return data.get(str(user_id), {}).get("preferences", {})
        except Exception as e:
            print(f"Error loading preferences: {e}")
            return {}

    # Load initial preferences
    user_prefs = load_user_preferences(user_id)
    for ing in available_ingredients:
        user_prefs.setdefault(ing, 0)

    # ---------- LOAD RECIPES FROM JSON ----------
    try:
        with open(RECIPES_JSON, "r") as f:
            recipes_data = json.load(f)
    except Exception as e:
        print(f"Error loading recipes: {e}")
        raise

    # Transform recipes data into proper format
    recipes_list = []
    for recipe in recipes_data:
        ingredients = []
        if isinstance(recipe["Cleaned_Ingredients"], str):
            ingredients = [ing.strip(" '[]\"") for ing in recipe["Cleaned_Ingredients"].split(",")]
        elif isinstance(recipe["Cleaned_Ingredients"], list):
            ingredients = recipe["Cleaned_Ingredients"]
        
        recipes_list.append({
            "recipe": recipe["Title"],
            "ingredients": ", ".join([ing.lower() for ing in ingredients]),
            "category": recipe.get("Cuisine", "Unclassified"),
            "instructions": recipe["Instructions"],
            "cooking_time": recipe["timeTaken"],
            "servings": None,
            "diet": recipe.get("Diet", ""),
            "difficulty": recipe.get("Difficulty", ""),
            "meal_type": recipe.get("Meal Type", ""),
            "image_name": recipe["Image_Name"]})

    recipes_df = pd.DataFrame(recipes_list)

    # ---------- RECIPE RELEVANCE COMPUTATION ----------
    def compute_recipe_relevance(recipe_ingredients):
        """Compute a relevance score between 0 and 1 for a recipe based on user preferences"""
        ings = [i.strip().lower() for i in recipe_ingredients.split(",")]
        
        score = 0
        total_weight = 0
        
        for ing in ings:
            if ing in user_allergies:
                return 0  # Allergic, not relevant
            
            weight = 1
            if ing in available_ingredients:
                weight += 1
            if ing in user_prefs:
                weight += user_prefs[ing]
            
            score += weight
            total_weight += weight

        if total_weight == 0:
            return 0
        
        normalized_score = score / total_weight
        return normalized_score

    # Generate labels based on relevance
    relevance_scores = recipes_df["ingredients"].apply(compute_recipe_relevance)
    threshold = relevance_scores.quantile(0.75)
    y = (relevance_scores >= threshold).astype(int)

    # Prepare and train model
    vectorizer = TfidfVectorizer()
    X = vectorizer.fit_transform(recipes_df["ingredients"])
    X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)
    model = XGBClassifier(eval_metric="logloss")
    model.fit(X_train, y_train)

    # ---------- RECIPE SCORING FUNCTION ----------
    def recipe_score(ingredients_text):
        ings = [i.strip().lower() for i in ingredients_text.split(",")]
        score = 0
        for ing in ings:
            if ing in available_ingredients:
                score += 3
            if ing in user_prefs:
                score += 2 * user_prefs[ing]
            if ing in user_allergies:
                return -np.inf
        return score

    # ---------- COMPUTE FINAL SCORES & RECOMMEND ----------
    recipes_df["AI_score"] = model.predict_proba(vectorizer.transform(recipes_df["ingredients"]))[:, 1]
    recipes_df["custom_score"] = recipes_df["ingredients"].apply(recipe_score)
    recipes_df["final_score"] = recipes_df["AI_score"] + recipes_df["custom_score"]
    #top_recs = recipes_df.sort_values("final_score", ascending=False).head(10*count)
    top_recs = recipes_df.sort_values("final_score", ascending=False).iloc[(10*count)-10 : 10*count]

    # Format recommendations to match Flutter app expectations
    recommendations = []
    for _, row in top_recs.iterrows():
        # Split ingredients string back into list
        ingredients_list = [ing.strip() for ing in row['ingredients'].split(',')]
        
        # Split instructions into steps if they're not already a list
        if isinstance(row['instructions'], str):
            instructions_list = [step.strip() for step in row['instructions'].split('.') if step.strip()]
        else:
            instructions_list = row['instructions']

        recommendations.append({
            "name": row["recipe"],
            "cusine": row["category"],  # category maps to cusine in the app
            "mealType": row["meal_type"],
            "ingredients": ingredients_list,
            "steps": instructions_list,
            "timeTaken": row["cooking_time"],  # This should be in minutes
            "difficulty": row["difficulty"],
            "image": f"{row['image_name']}.jpg"  # Match the image path format
        })

    # ---------- UPDATE PREFERENCES WHEN USER COOKS ----------
    def update_preferences_on_cook(user_id, cooked_ingredients):
        prefs = load_user_preferences(user_id)
        for ing in [i.strip().lower() for i in cooked_ingredients]:
            prefs[ing] = prefs.get(ing, 0) + 1
        with open(PREFS_FILE, "r+") as f:
            data = json.load(f)
            if str(user_id) not in data:
                data[str(user_id)] = {"preferences": {}}
            data[str(user_id)]["preferences"] = prefs
            f.seek(0)
            json.dump(data, f, indent=2)
            f.truncate()
        print(f"Updated preferences for user {user_id}")

    mongo_client.close()

    print(
        [
        {
            "name": r["name"],
            "timeTaken": r["timeTaken"]
        }
        for r in recommendations
    ]
    )

    return [
        {
            "name": r["name"],
            "cusine": r["cusine"],
            "mealType": r["mealType"],
            "ingredients": r["ingredients"],
            "steps": r.get("steps"),
            "timeTaken": r["timeTaken"] if r["timeTaken"] else "Unknown",
            "difficulty": r["difficulty"],
            "image": r["image"]
        }
        for r in recommendations
    ]


get_recipe_recommendations(1)

# Example of how to call the update function
#update_preferences_on_cook(USER_ID, ["chicken", "salt", "pepper"])