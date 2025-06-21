#!/usr/bin/env python3
"""
Test script to demonstrate the smart user preference system.
This script shows how user preferences are updated when recipes are cooked.
"""

import sys
import os
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from app.recipeAI import update_preferences_on_cook, get_user_preferences, get_user_preferences_for_recommendations, calculate_preference_boost

def test_preference_system():
    """Test the smart preference system with sample data."""
    
    # Test user ID
    user_id = "test_user_123"
    
    print("🍳 Testing Smart User Preference System")
    print("=" * 50)
    
    # Test 1: Cook a simple recipe
    print("\n1. Cooking a simple recipe: 'Chicken Stir Fry'")
    simple_recipe = {
        "name": "Chicken Stir Fry",
        "ingredients": ["chicken breast", "soy sauce", "garlic", "onion", "bell pepper"],
        "meal_type": "dinner",
        "cooking_time": "20 minutes"
    }
    
    result = update_preferences_on_cook(
        user_id=user_id,
        recipe_ingredients=simple_recipe["ingredients"],
        recipe_name=simple_recipe["name"],
        meal_type=simple_recipe["meal_type"],
        cooking_time=simple_recipe["cooking_time"]
    )
    
    print(f"✅ Result: {result['message']}")
    print(f"   Updated ingredients: {result['updated_ingredients']}")
    
    # Test 2: Cook a complex recipe
    print("\n2. Cooking a complex recipe: 'Beef Wellington'")
    complex_recipe = {
        "name": "Beef Wellington",
        "ingredients": ["beef tenderloin", "puff pastry", "mushrooms", "garlic", "onion", "thyme", "dijon mustard", "prosciutto"],
        "meal_type": "dinner",
        "cooking_time": "90 minutes"
    }
    
    result = update_preferences_on_cook(
        user_id=user_id,
        recipe_ingredients=complex_recipe["ingredients"],
        recipe_name=complex_recipe["name"],
        meal_type=complex_recipe["meal_type"],
        cooking_time=complex_recipe["cooking_time"]
    )
    
    print(f"✅ Result: {result['message']}")
    print(f"   Updated ingredients: {result['updated_ingredients']}")
    
    # Test 3: Cook a breakfast recipe
    print("\n3. Cooking a breakfast recipe: 'Avocado Toast'")
    breakfast_recipe = {
        "name": "Avocado Toast",
        "ingredients": ["bread", "avocado", "eggs", "salt", "pepper", "red pepper flakes"],
        "meal_type": "breakfast",
        "cooking_time": "10 minutes"
    }
    
    result = update_preferences_on_cook(
        user_id=user_id,
        recipe_ingredients=breakfast_recipe["ingredients"],
        recipe_name=breakfast_recipe["name"],
        meal_type=breakfast_recipe["meal_type"],
        cooking_time=breakfast_recipe["cooking_time"]
    )
    
    print(f"✅ Result: {result['message']}")
    print(f"   Updated ingredients: {result['updated_ingredients']}")
    
    # Test 4: View user preferences
    print("\n4. Current User Preferences:")
    preferences = get_user_preferences(user_id)
    
    print(f"   📊 Ingredient Preferences:")
    for ingredient, score in preferences.get("preferences", {}).items():
        print(f"      {ingredient}: {score}/10")
    
    print(f"\n   🍽️ Meal Type Preferences:")
    for meal_type, score in preferences.get("meal_type_preferences", {}).items():
        print(f"      {meal_type}: {score}/10")
    
    print(f"\n   ⏱️ Cooking Time Preferences:")
    for time_category, score in preferences.get("cooking_time_preferences", {}).items():
        print(f"      {time_category}: {score}/10")
    
    print(f"\n   🔗 Top Ingredient Combinations:")
    combinations = preferences.get("ingredient_combinations", {})
    sorted_combinations = sorted(combinations.items(), key=lambda x: x[1], reverse=True)[:5]
    for combo, count in sorted_combinations:
        print(f"      {combo}: {count} times")
    
    # Test 5: Calculate preference boost for a new recipe
    print("\n5. Testing Preference Boost for New Recipe:")
    new_recipe_ingredients = ["chicken breast", "garlic", "onion", "bell pepper", "soy sauce"]
    
    user_prefs = get_user_preferences_for_recommendations(user_id)
    boost_score = calculate_preference_boost(new_recipe_ingredients, user_prefs)
    
    print(f"   Recipe: 'Chicken Stir Fry 2.0'")
    print(f"   Ingredients: {new_recipe_ingredients}")
    print(f"   Preference Boost Score: {boost_score:.2f}/1.0")
    
    if boost_score > 0.5:
        print("   🎯 High preference match! User would likely enjoy this recipe.")
    elif boost_score > 0.2:
        print("   👍 Moderate preference match.")
    else:
        print("   🤔 Low preference match - might want to suggest alternatives.")
    
    # Test 6: Cooking history
    print("\n6. Recent Cooking History:")
    cooking_history = preferences.get("cooking_history", [])
    for i, session in enumerate(cooking_history[-3:], 1):  # Show last 3 sessions
        print(f"   {i}. {session['recipe_name']} ({session['cooked_at'][:10]})")
        print(f"      Ingredients: {', '.join(session['ingredients'][:3])}...")
    
    print("\n" + "=" * 50)
    print("🎉 Smart Preference System Test Complete!")
    print("\nKey Features Demonstrated:")
    print("• Ingredient preference tracking with smart boosting")
    print("• Meal type preference learning")
    print("• Cooking time preference analysis")
    print("• Ingredient combination tracking")
    print("• Preference-based recipe scoring")
    print("• Cooking history tracking")

if __name__ == "__main__":
    test_preference_system() 