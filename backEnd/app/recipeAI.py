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
import re
from functools import lru_cache
import logging

# Cache for processed recipes
_recipe_cache = None
_processed_ingredients_cache = {}

# Ingredients to ignore in matching
IGNORED_INGREDIENTS = {'water', 'ice', 'ice water', 'hot water', 'cold water', 'warm water', 'tap water'}

# Ingredient variations mapping
INGREDIENT_VARIATIONS = {
    # Chicken variations
    'chicken wings': ['chicken wingettes', 'wingettes', 'chicken wing', 'wings', 'wing'],
    'chicken breast': ['chicken breasts', 'chicken breast fillet', 'chicken fillet', 'chicken fillets'],
    'chicken thigh': ['chicken thighs', 'thigh', 'thighs'],
    'chicken drumstick': ['chicken drumsticks', 'drumstick', 'drumsticks'],
    
    # Basic ingredients
    'sugar': ['white sugar', 'granulated sugar', 'caster sugar', 'regular sugar'],
    'brown sugar': ['dark brown sugar', 'light brown sugar', 'demerara sugar'],
    'vinegar': ['white vinegar', 'distilled vinegar', 'rice vinegar', 'balsamic vinegar', 'red wine vinegar'],
    'soy sauce': ['light soy sauce', 'dark soy sauce', 'soya sauce'],
    
    # Common meat variations
    'beef': ['ground beef', 'minced beef', 'beef mince'],
    'pork': ['ground pork', 'minced pork', 'pork mince'],
    'lamb': ['ground lamb', 'minced lamb', 'lamb mince'],
    
    # Common vegetables
    'onion': ['onions', 'brown onion', 'yellow onion', 'white onion'],
    'garlic': ['garlic cloves', 'garlic clove', 'fresh garlic'],
    'tomato': ['tomatoes', 'fresh tomato', 'fresh tomatoes'],
    'potato': ['potatoes', 'white potato', 'yellow potato'],
    'carrot': ['carrots', 'fresh carrot', 'fresh carrots'],
    
    # Common pantry items
    'flour': ['all purpose flour', 'plain flour', 'all-purpose flour'],
    'oil': ['vegetable oil', 'cooking oil', 'canola oil', 'olive oil'],
    'salt': ['table salt', 'sea salt', 'kosher salt'],
    'pepper': ['black pepper', 'ground pepper', 'ground black pepper'],
    
    # Dairy and alternatives
    'milk': ['whole milk', 'full cream milk', 'dairy milk'],
    'cream': ['heavy cream', 'whipping cream', 'thickened cream'],
    'butter': ['unsalted butter', 'salted butter'],
    'cheese': ['cheddar cheese', 'grated cheese', 'shredded cheese']
}

# Create reverse mapping for faster lookup
INGREDIENT_MAPPING = {}
for standard, variations in INGREDIENT_VARIATIONS.items():
    for variant in variations:
        INGREDIENT_MAPPING[variant] = standard
    INGREDIENT_MAPPING[standard] = standard

@lru_cache(maxsize=1000)
def clean_ingredient(ingredient):
    """Clean ingredient text with caching for better performance."""
    # Convert to lowercase
    ingredient = ingredient.lower()
    
    # Remove fractional measurements (e.g., 1/2, 3/4)
    ingredient = re.sub(r'\d+/\d+', '', ingredient)
    ingredient = re.sub(r'\d*\.?\d+', '', ingredient)
    ingredient = re.sub(r'\b\d+\b', '', ingredient)

    # Use pre-compiled regex patterns for better performance
    patterns = {
        'measurements': r'\b(cup|cups|tablespoon|tablespoons|teaspoon|teaspoons|tsp|tbsp|pound|pounds|ounce|ounces|gram|grams|lb|oz|g|kg|slice|slices|piece|pieces|whole|half|quarter|package|can|bottle|jar|container|bunch|pinch|dash|splash|inch|inches|cm|mm|ml|quart|gallon|stick|sticks)\b',
        'descriptive': r'\b(large|small|medium|fresh|dried|ground|powdered|room temperature|chilled|frozen|melted|softened|chopped|diced|minced|crushed|grated|shredded|peeled|seeded|cored|stemmed|hulled|ripe|unripe|mature|young|baby|cooked|raw|prepared|processed|optional|to taste|or more|if desired|if needed|as needed|plus|extra|additional|more|rated|scant|ly|by|crumbled|shaved|sliced|diced|unsalted|salted|sweet|sour|bitter|thawed|frozen|chilled|heated)\b',
        'instructions': r'rinsed and drained|coarse stems discarded|including juice|halved|quartered|sliced|divided|separated|at room temperature|for garnish|for serving|if',
        'prepositions': r'\b(and|or|with|without|for|to|from|in|on|at)\b',
        'phrases': r'about|approximately|around|roughly|plus more for|plus extra for|such as|like|similar to',
        'packaging': r'\b(pack|packet|box|tin|carton|fluid|fl|solid|net)\b',
        'single_letters': r'\s+[a-zA-Z]\s+'
    }
    
    # Apply all patterns in a single pass
    combined_pattern = '|'.join(patterns.values())
    ingredient = re.sub(combined_pattern, ' ', ingredient)
    
    # Final cleanup
    ingredient = re.sub(r'[^\w\s-]', '', ingredient)
    ingredient = ' '.join(word for word in ingredient.split() if len(word) > 1)
    ingredient = ingredient.strip()
    
    # Standardize ingredient name using the mapping
    return INGREDIENT_MAPPING.get(ingredient, ingredient)

def are_ingredients_similar(ing1, ing2):
    """Check if two ingredients are similar or variations of each other."""
    # Clean both ingredients
    clean_ing1 = clean_ingredient(ing1)
    clean_ing2 = clean_ingredient(ing2)
    
    # Direct match after cleaning
    if clean_ing1 == clean_ing2:
        return True
    
    # Check if they map to the same standard ingredient
    standard1 = INGREDIENT_MAPPING.get(clean_ing1)
    standard2 = INGREDIENT_MAPPING.get(clean_ing2)
    
    if standard1 and standard2 and standard1 == standard2:
        return True
    
    return False

def calculate_recipe_score(row):
    """Calculate a weighted score for recipe ranking."""
    # Get the number of ingredients (excluding ignored ones)
    total_ingredients = len([ing for ing in row["ingredients"] if ing not in IGNORED_INGREDIENTS])
    
    # Calculate the coverage score (excluding ignored ingredients)
    available = len([ing for ing in row["available_ingredients"] if ing not in IGNORED_INGREDIENTS])
    coverage_score = available / total_ingredients if total_ingredients > 0 else 0
    
    # Weight factors
    complexity_weight = 0.4  # Favor more complex recipes
    coverage_weight = 0.6    # Still consider available ingredients
    
    # Complexity score (normalized by typical recipe size)
    complexity_score = min(total_ingredients / 5, 1.0)  # Normalize against a 5-ingredient baseline
    
    # Combined score
    return (complexity_weight * complexity_score) + (coverage_weight * coverage_score)

def get_recipe_recommendations(user_id, count=1):
    """Get recipe recommendations with optimized performance."""
    try:
        # ---------- CONFIGURATION ----------
        load_dotenv()
        MONGO_URI = os.getenv("MONGO_URI")
        
        SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
        RECIPES_JSON = os.path.join(SCRIPT_DIR, "..", "data", "recipes.json")

        # ---------- LOAD INVENTORY FROM MONGODB ----------
        mongo_client = MongoClient(MONGO_URI)
        inventory_col = mongo_client["lili"]["inventory"]

        try:
            house_result = selectUser(f'SELECT house_Id FROM user_tbl WHERE user_Id = "{user_id}"')
            if not house_result:
                raise HTTPException(status_code=404, detail="House ID not found for user")
            house_id = house_result[0]["house_Id"]
        except Exception as e:
            logging.error(f"Error fetching house ID: {e}")
            raise

        # Fetch and clean household inventory items
        household_items = list(inventory_col.find({"house_id": house_id}))
        available_ingredients = set()  # Using set for O(1) lookups
        
        for item in household_items:
            try:
                expiry = datetime.fromisoformat(item["expiry_date"])
                if expiry >= datetime.now():
                    cleaned_item = clean_ingredient(item["name"])
                    if cleaned_item and cleaned_item not in IGNORED_INGREDIENTS:
                        available_ingredients.add(cleaned_item)
                        # Add standard form if it exists
                        if cleaned_item in INGREDIENT_MAPPING:
                            available_ingredients.add(INGREDIENT_MAPPING[cleaned_item])
            except Exception as e:
                logging.error(f"Error processing inventory item: {e}")
                continue

        # ---------- LOAD RECIPES ----------
        try:
            with open(RECIPES_JSON, "r") as f:
                recipes_data = json.load(f)

            if not recipes_data:
                return []  # Return empty list if no recipes found

            recipes_list = []
            for recipe in recipes_data:
                try:
                    # Process ingredients
                    raw_ingredients = []
                    if isinstance(recipe["Cleaned_Ingredients"], str):
                        raw_ingredients = [ing.strip(" '[]\"") for ing in recipe["Cleaned_Ingredients"].split(",")]
                    elif isinstance(recipe["Cleaned_Ingredients"], list):
                        raw_ingredients = recipe["Cleaned_Ingredients"]
                    
                    # Clean ingredients and handle variations
                    cleaned_ingredients = set()
                    for raw_ing in raw_ingredients:
                        if raw_ing:
                            cleaned_ing = clean_ingredient(raw_ing)
                            if cleaned_ing and cleaned_ing not in IGNORED_INGREDIENTS:
                                cleaned_ingredients.add(cleaned_ing)
                                # Add standard form if it exists
                                if cleaned_ing in INGREDIENT_MAPPING:
                                    cleaned_ingredients.add(INGREDIENT_MAPPING[cleaned_ing])
                    
                    if not cleaned_ingredients:
                        continue
                    
                    # Calculate available and missing ingredients using similarity matching
                    available_recipe_ingredients = set()
                    missing_ingredients = set()
                    
                    for recipe_ing in cleaned_ingredients:
                        found = False
                        for inventory_ing in available_ingredients:
                            if are_ingredients_similar(recipe_ing, inventory_ing):
                                available_recipe_ingredients.add(recipe_ing)
                                found = True
                                break
                        if not found:
                            missing_ingredients.add(recipe_ing)
                    
                    # Calculate coverage
                    ingredients_coverage = len(available_recipe_ingredients) / len(cleaned_ingredients)
                    
                    recipes_list.append({
                        "recipe": recipe["Title"],
                        "ingredients": list(cleaned_ingredients),
                        "available_ingredients": list(available_recipe_ingredients),
                        "missing_ingredients": list(missing_ingredients),
                        "ingredients_coverage": ingredients_coverage,
                        "category": recipe.get("Cuisine", "Unclassified"),
                        "instructions": recipe["Instructions"],
                        "cooking_time": recipe["timeTaken"],
                        "servings": None,
                        "diet": recipe.get("Diet", ""),
                        "difficulty": recipe.get("Difficulty", ""),
                        "meal_type": recipe.get("Meal Type", ""),
                        "image_name": recipe["Image_Name"]
                    })
                    
                except Exception as e:
                    logging.error(f"Error processing recipe {recipe.get('Title', 'Unknown')}: {e}")
                    continue
            
            # Create DataFrame and calculate scores
            if not recipes_list:
                return []  # Return empty list if no valid recipes found
                
            recipes_df = pd.DataFrame(recipes_list)
            recipes_df["recipe_score"] = recipes_df.apply(calculate_recipe_score, axis=1)
            
            # Sort by the new recipe score
            recipes_df = recipes_df.sort_values("recipe_score", ascending=False)
            
            # Get recommendations
            start_idx = (count - 1) * 10
            end_idx = min(start_idx + 10, len(recipes_df))
            
            recommendations = []
            for _, row in recipes_df.iloc[start_idx:end_idx].iterrows():
                try:
                    # Format ingredients lists
                    available_ingredients_list = row["available_ingredients"]
                    missing_ingredients_list = row["missing_ingredients"]
                    all_ingredients = available_ingredients_list + missing_ingredients_list

                    recommendations.append({
                        "name": str(row["recipe"]),
                        "cusine": str(row["category"]),
                        "mealType": str(row["meal_type"]),
                        "ingredients": all_ingredients,
                        "available_ingredients": available_ingredients_list,
                        "missing_ingredients": missing_ingredients_list,
                        "steps": row["instructions"].split(".") if isinstance(row["instructions"], str) else row["instructions"],
                        "timeTaken": str(row["cooking_time"]),
                        "difficulty": str(row["difficulty"]),
                        "image": f"{row['image_name']}.jpg"
                    })
                except Exception as e:
                    logging.error(f"Error formatting recipe {row.get('recipe', 'Unknown')}: {e}")
                    continue

            mongo_client.close()
            return recommendations
            
        except Exception as e:
            logging.error(f"Error loading recipes: {e}")
            raise
            
    except Exception as e:
        logging.error(f"Error in recipe recommendations: {e}")
        raise

# Example of how to call the update function
#update_preferences_on_cook(USER_ID, ["chicken", "salt", "pepper"])