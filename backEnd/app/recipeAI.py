import os
import json
from datetime import datetime, timedelta
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
from typing import List, Dict, Any

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
    """Get recipe recommendations with optimized performance and user preferences."""
    try:
        # ---------- CONFIGURATION ----------
        load_dotenv()
        MONGO_URI = os.getenv("MONGO_URI")
        
        SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
        RECIPES_JSON = os.path.join(SCRIPT_DIR, "..", "data", "recipes.json")

        # ---------- LOAD USER PREFERENCES ----------
        user_preferences = get_user_preferences_for_recommendations(user_id)
        has_preferences = user_preferences.get("has_preferences", False)

        # ---------- LOAD USER ALLERGIES ----------
        user_allergies = selectAllergy(query={"user_Id": str(user_id)})
        allergy_names = [a["allergy_name"] for a in user_allergies]
        cleaned_allergies = set(clean_ingredient(a) for a in allergy_names if a)

        # ---------- LOAD INVENTORY FROM MONGODB ----------
        mongo_client = MongoClient(MONGO_URI)
        inventory_col = mongo_client["lili"]["inventory"]

        try:
            user_result = selectUser(id=str(user_id))
            if not user_result:
                raise HTTPException(status_code=404, detail="House ID not found for user")
            house_id = user_result[0]["house_Id"]
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
                    
                    # Allergy filtering: skip recipes containing any allergy ingredient
                    if any(allergy in cleaned_ingredients for allergy in cleaned_allergies):
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
            
            # Calculate base recipe score
            recipes_df["recipe_score"] = recipes_df.apply(calculate_recipe_score, axis=1)
            
            # Calculate preference boost if user has preferences
            if has_preferences:
                recipes_df["preference_boost"] = recipes_df["ingredients"].apply(
                    lambda ingredients: calculate_preference_boost(ingredients, user_preferences)
                )
                
                # Calculate meal type preference boost
                meal_type_prefs = user_preferences.get("meal_type_preferences", {})
                recipes_df["meal_type_boost"] = recipes_df["meal_type"].apply(
                    lambda meal_type: meal_type_prefs.get(meal_type.lower(), 0) / 10.0 if meal_type else 0.0
                )
                
                # Calculate cooking time preference boost
                cooking_time_prefs = user_preferences.get("cooking_time_preferences", {})
                recipes_df["cooking_time_boost"] = recipes_df["cooking_time"].apply(
                    lambda cooking_time: _calculate_time_preference_boost(cooking_time, cooking_time_prefs)
                )
                
                # Combine all scores with preference weighting
                preference_weight = 0.4  # 40% weight for preferences
                base_weight = 0.6       # 60% weight for base score
                
                recipes_df["final_score"] = (
                    base_weight * recipes_df["recipe_score"] +
                    preference_weight * (
                        recipes_df["preference_boost"] * 0.6 +
                        recipes_df["meal_type_boost"] * 0.2 +
                        recipes_df["cooking_time_boost"] * 0.2
                    )
                )
                
                # Sort by final score (preferences + base score)
                recipes_df = recipes_df.sort_values("final_score", ascending=False)
                
                logging.info(f"User {user_id} has preferences - using personalized recommendations")
            else:
                # No preferences - use base score only
                recipes_df["final_score"] = recipes_df["recipe_score"]
                recipes_df = recipes_df.sort_values("final_score", ascending=False)
                logging.info(f"User {user_id} has no preferences - using base recommendations")
            
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

                    recommendation = {
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
                    }
                    
                    # Add preference information if available
                    if has_preferences:
                        recommendation["preference_score"] = round(row["preference_boost"], 2)
                        recommendation["meal_type_match"] = round(row["meal_type_boost"], 2)
                        recommendation["cooking_time_match"] = round(row["cooking_time_boost"], 2)
                        recommendation["final_score"] = round(row["final_score"], 2)
                        recommendation["personalized"] = True
                    else:
                        recommendation["personalized"] = False

                    recommendations.append(recommendation)
                    
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

def _calculate_time_preference_boost(cooking_time: str, cooking_time_prefs: Dict[str, int]) -> float:
    """
    Calculate cooking time preference boost for a recipe.
    
    Args:
        cooking_time: Cooking time string (e.g., "30 minutes")
        cooking_time_prefs: User's cooking time preferences
        
    Returns:
        Float representing the time preference boost (0.0 to 1.0)
    """
    try:
        if not cooking_time or not cooking_time_prefs:
            return 0.0
        
        # Extract time value from cooking time string
        time_value = 0
        if 'min' in cooking_time.lower():
            time_value = int(''.join(filter(str.isdigit, cooking_time)))
        
        if time_value > 0:
            if time_value <= 15:
                time_category = "quick"
            elif time_value <= 30:
                time_category = "medium"
            else:
                time_category = "long"
            
            # Get preference score for this time category
            preference_score = cooking_time_prefs.get(time_category, 0)
            return min(preference_score / 10.0, 1.0)  # Normalize to 0-1
        
        return 0.0
        
    except Exception as e:
        logging.error(f"Error calculating time preference boost: {e}")
        return 0.0

def update_preferences_on_cook(user_id: str, recipe_ingredients: List[str], recipe_name: str = "", meal_type: str = "", cooking_time: str = ""):
    """
    Update user preferences when a recipe is cooked.
    This function intelligently updates user preferences based on the ingredients used.
    
    Args:
        user_id: The user's ID
        recipe_ingredients: List of ingredients used in the recipe
        recipe_name: Name of the recipe (optional, for logging)
        meal_type: Type of meal (breakfast, lunch, dinner, etc.)
        cooking_time: Time taken to cook the recipe
    """
    try:
        # Load current preferences
        preferences_file = os.path.join(os.path.dirname(__file__), "..", "data", "user_preferences.json")
        
        # Create file if it doesn't exist
        if not os.path.exists(preferences_file):
            with open(preferences_file, 'w') as f:
                json.dump({}, f)
        
        with open(preferences_file, 'r') as f:
            try:
                all_preferences = json.load(f)
            except json.JSONDecodeError:
                all_preferences = {}
        
        # Get or create user preferences
        if user_id not in all_preferences:
            all_preferences[user_id] = {
                "preferences": {},
                "meal_type_preferences": {},
                "cooking_time_preferences": {},
                "ingredient_combinations": {},
                "updated_at": datetime.now().isoformat(),
                "cooking_history": []
            }
        
        user_prefs = all_preferences[user_id]
        current_prefs = user_prefs.get("preferences", {})
        meal_type_prefs = user_prefs.get("meal_type_preferences", {})
        cooking_time_prefs = user_prefs.get("cooking_time_preferences", {})
        ingredient_combinations = user_prefs.get("ingredient_combinations", {})
        
        # Clean and standardize ingredients
        cleaned_ingredients = []
        for ingredient in recipe_ingredients:
            cleaned = clean_ingredient(ingredient)
            if cleaned and cleaned not in IGNORED_INGREDIENTS:
                cleaned_ingredients.append(cleaned)
        
        # Smart preference update logic
        for ingredient in cleaned_ingredients:
            # Get base preference value (default to 1 if new)
            current_value = current_prefs.get(ingredient, 1)
            
            # Calculate preference boost based on recipe complexity and ingredient importance
            base_boost = 1
            
            # Boost for complex recipes (more ingredients = more effort)
            complexity_boost = min(len(cleaned_ingredients) / 5, 2.0)  # Max 2x boost for complex recipes
            
            # Boost for main ingredients (first 3 ingredients are usually main)
            main_ingredient_boost = 1.5 if cleaned_ingredients.index(ingredient) < 3 else 1.0
            
            # Boost for protein ingredients (important for nutrition)
            protein_ingredients = ['chicken', 'beef', 'pork', 'fish', 'shrimp', 'tofu', 'eggs', 'beans', 'lentils', 'salmon', 'tuna']
            protein_boost = 1.3 if any(protein in ingredient.lower() for protein in protein_ingredients) else 1.0
            
            # Boost for fresh ingredients (indicates healthy cooking)
            fresh_ingredients = ['tomato', 'onion', 'garlic', 'cilantro', 'basil', 'spinach', 'lettuce', 'cucumber', 'bell pepper']
            fresh_boost = 1.2 if any(fresh in ingredient.lower() for fresh in fresh_ingredients) else 1.0
            
            # Calculate total boost
            total_boost = base_boost * complexity_boost * main_ingredient_boost * protein_boost * fresh_boost
            
            # Update preference (with diminishing returns for very high values)
            new_value = current_value + total_boost
            if new_value > 10:  # Cap at 10
                new_value = 10
            
            current_prefs[ingredient] = round(new_value, 1)
        
        # Update meal type preferences
        if meal_type:
            meal_type_lower = meal_type.lower()
            current_meal_pref = meal_type_prefs.get(meal_type_lower, 1)
            meal_type_prefs[meal_type_lower] = min(current_meal_pref + 1, 10)
        
        # Update cooking time preferences
        if cooking_time:
            # Extract time value from cooking time string
            time_value = 0
            if 'min' in cooking_time.lower():
                time_value = int(''.join(filter(str.isdigit, cooking_time)))
            
            if time_value > 0:
                if time_value <= 15:
                    time_category = "quick"
                elif time_value <= 30:
                    time_category = "medium"
                else:
                    time_category = "long"
                
                current_time_pref = cooking_time_prefs.get(time_category, 1)
                cooking_time_prefs[time_category] = min(current_time_pref + 1, 10)
        
        # Update ingredient combinations (track frequently used combinations)
        if len(cleaned_ingredients) >= 2:
            # Create combinations of 2-3 ingredients
            for i in range(len(cleaned_ingredients)):
                for j in range(i + 1, min(i + 3, len(cleaned_ingredients))):
                    combo = f"{cleaned_ingredients[i]}+{cleaned_ingredients[j]}"
                    current_combo_count = ingredient_combinations.get(combo, 0)
                    ingredient_combinations[combo] = current_combo_count + 1
        
        # Add to cooking history
        cooking_history = user_prefs.get("cooking_history", [])
        cooking_history.append({
            "recipe_name": recipe_name,
            "ingredients": cleaned_ingredients,
            "meal_type": meal_type,
            "cooking_time": cooking_time,
            "cooked_at": datetime.now().isoformat(),
            "preference_boosts": {ing: current_prefs[ing] for ing in cleaned_ingredients}
        })
        
        # Keep only last 50 cooking sessions
        if len(cooking_history) > 50:
            cooking_history = cooking_history[-50:]
        
        # Update user preferences
        user_prefs["preferences"] = current_prefs
        user_prefs["meal_type_preferences"] = meal_type_prefs
        user_prefs["cooking_time_preferences"] = cooking_time_prefs
        user_prefs["ingredient_combinations"] = ingredient_combinations
        user_prefs["updated_at"] = datetime.now().isoformat()
        user_prefs["cooking_history"] = cooking_history
        
        # Save back to file
        with open(preferences_file, 'w') as f:
            json.dump(all_preferences, f, indent=2)
        
        logging.info(f"Updated preferences for user {user_id} after cooking {recipe_name}")
        return {
            "status": "success",
            "message": f"Preferences updated for {len(cleaned_ingredients)} ingredients",
            "updated_ingredients": cleaned_ingredients,
            "meal_type_updated": bool(meal_type),
            "cooking_time_updated": bool(cooking_time)
        }
        
    except Exception as e:
        logging.error(f"Error updating preferences for user {user_id}: {e}")
        raise HTTPException(status_code=500, detail=f"Failed to update preferences: {str(e)}")

def get_user_preferences(user_id: str) -> Dict[str, Any]:
    """
    Get user preferences and cooking history.
    
    Args:
        user_id: The user's ID
        
    Returns:
        Dictionary containing preferences and cooking history
    """
    try:
        preferences_file = os.path.join(os.path.dirname(__file__), "..", "data", "user_preferences.json")
        
        if not os.path.exists(preferences_file):
            return {
                "preferences": {},
                "cooking_history": [],
                "updated_at": None
            }
        
        with open(preferences_file, 'r') as f:
            try:
                all_preferences = json.load(f)
            except json.JSONDecodeError:
                all_preferences = {}
        
        user_prefs = all_preferences.get(user_id, {
            "preferences": {},
            "cooking_history": [],
            "updated_at": None
        })
        
        return user_prefs
        
    except Exception as e:
        logging.error(f"Error getting preferences for user {user_id}: {e}")
        raise HTTPException(status_code=500, detail=f"Failed to get preferences: {str(e)}")

def get_user_preferences_for_recommendations(user_id: str) -> Dict[str, Any]:
    """
    Get user preferences formatted for recipe recommendations.
    This function returns preferences in a format that can be used
    to boost recipe scores based on user's cooking history.
    
    Args:
        user_id: The user's ID
        
    Returns:
        Dictionary containing formatted preferences for recommendations
    """
    try:
        user_prefs = get_user_preferences(user_id)
        
        # Extract ingredient preferences
        ingredient_prefs = user_prefs.get("preferences", {})
        
        # Extract meal type preferences
        meal_type_prefs = user_prefs.get("meal_type_preferences", {})
        
        # Extract cooking time preferences
        cooking_time_prefs = user_prefs.get("cooking_time_preferences", {})
        
        # Extract ingredient combinations
        ingredient_combinations = user_prefs.get("ingredient_combinations", {})
        
        return {
            "ingredient_preferences": ingredient_prefs,
            "meal_type_preferences": meal_type_prefs,
            "cooking_time_preferences": cooking_time_prefs,
            "ingredient_combinations": ingredient_combinations,
            "has_preferences": len(ingredient_prefs) > 0
        }
        
    except Exception as e:
        logging.error(f"Error getting preferences for recommendations for user {user_id}: {e}")
        return {
            "ingredient_preferences": {},
            "meal_type_preferences": {},
            "cooking_time_preferences": {},
            "ingredient_combinations": {},
            "has_preferences": False
        }

def calculate_preference_boost(recipe_ingredients: List[str], user_preferences: Dict[str, Any]) -> float:
    """
    Calculate a preference boost score for a recipe based on user preferences.
    
    Args:
        recipe_ingredients: List of ingredients in the recipe
        user_preferences: User's preference data
        
    Returns:
        Float representing the preference boost (0.0 to 1.0)
    """
    try:
        ingredient_prefs = user_preferences.get("ingredient_preferences", {})
        meal_type_prefs = user_preferences.get("meal_type_preferences", {})
        cooking_time_prefs = user_preferences.get("cooking_time_preferences", {})
        ingredient_combinations = user_preferences.get("ingredient_combinations", {})
        
        if not ingredient_prefs:
            return 0.0
        
        # Calculate ingredient preference score
        total_ingredient_score = 0
        matched_ingredients = 0
        
        for ingredient in recipe_ingredients:
            cleaned_ingredient = clean_ingredient(ingredient)
            if cleaned_ingredient and cleaned_ingredient in ingredient_prefs:
                total_ingredient_score += ingredient_prefs[cleaned_ingredient]
                matched_ingredients += 1
        
        # Normalize ingredient score
        ingredient_boost = 0.0
        if matched_ingredients > 0:
            avg_ingredient_score = total_ingredient_score / matched_ingredients
            ingredient_boost = min(avg_ingredient_score / 10.0, 1.0)  # Normalize to 0-1
        
        # Calculate combination boost
        combination_boost = 0.0
        if len(recipe_ingredients) >= 2:
            combo_matches = 0
            for i in range(len(recipe_ingredients)):
                for j in range(i + 1, len(recipe_ingredients)):
                    combo = f"{clean_ingredient(recipe_ingredients[i])}+{clean_ingredient(recipe_ingredients[j])}"
                    if combo in ingredient_combinations:
                        combo_matches += ingredient_combinations[combo]
            
            if combo_matches > 0:
                combination_boost = min(combo_matches / 10.0, 0.5)  # Max 0.5 boost for combinations
        
        # Total preference boost
        total_boost = ingredient_boost + combination_boost
        return min(total_boost, 1.0)  # Cap at 1.0
        
    except Exception as e:
        logging.error(f"Error calculating preference boost: {e}")
        return 0.0

# Example of how to call the update function
#update_preferences_on_cook(USER_ID, ["chicken", "salt", "pepper"])