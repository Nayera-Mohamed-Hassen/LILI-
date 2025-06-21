#!/usr/bin/env python3
"""
Test script to demonstrate how user preferences affect recipe recommendations.
This script shows the difference between recommendations with and without preferences.
"""

import sys
import os
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from app.recipeAI import (
    update_preferences_on_cook, 
    get_user_preferences, 
    get_recipe_recommendations,
    calculate_preference_boost
)

def test_preference_impact_on_recommendations():
    """Test how user preferences affect recipe recommendations."""
    
    # Test user ID
    user_id = "test_user_preferences"
    
    print("🍳 Testing User Preferences Impact on Recipe Recommendations")
    print("=" * 70)
    
    # Step 1: Get initial recommendations (no preferences)
    print("\n1. Initial Recommendations (No Preferences):")
    print("-" * 50)
    
    try:
        initial_recommendations = get_recipe_recommendations(user_id, count=1)
        if initial_recommendations:
            print(f"✅ Found {len(initial_recommendations)} initial recommendations")
            for i, recipe in enumerate(initial_recommendations[:3], 1):
                print(f"   {i}. {recipe['name']}")
                print(f"      Cuisine: {recipe['cusine']}")
                print(f"      Meal Type: {recipe['mealType']}")
                print(f"      Cooking Time: {recipe['timeTaken']}")
                print(f"      Personalized: {recipe.get('personalized', False)}")
                if recipe.get('personalized'):
                    print(f"      Preference Score: {recipe.get('preference_score', 'N/A')}")
                    print(f"      Final Score: {recipe.get('final_score', 'N/A')}")
                print()
        else:
            print("❌ No initial recommendations found")
            return
    except Exception as e:
        print(f"❌ Error getting initial recommendations: {e}")
        return
    
    # Step 2: Cook some recipes to build preferences
    print("\n2. Building User Preferences by Cooking Recipes:")
    print("-" * 50)
    
    recipes_to_cook = [
        {
            "name": "Chicken Stir Fry",
            "ingredients": ["chicken breast", "soy sauce", "garlic", "onion", "bell pepper", "ginger"],
            "meal_type": "dinner",
            "cooking_time": "25 minutes"
        },
        {
            "name": "Pasta Carbonara",
            "ingredients": ["pasta", "eggs", "bacon", "parmesan cheese", "garlic", "black pepper"],
            "meal_type": "dinner",
            "cooking_time": "20 minutes"
        },
        {
            "name": "Avocado Toast",
            "ingredients": ["bread", "avocado", "eggs", "salt", "pepper", "red pepper flakes"],
            "meal_type": "breakfast",
            "cooking_time": "10 minutes"
        }
    ]
    
    for recipe in recipes_to_cook:
        print(f"   Cooking: {recipe['name']}")
        try:
            result = update_preferences_on_cook(
                user_id=user_id,
                recipe_ingredients=recipe["ingredients"],
                recipe_name=recipe["name"],
                meal_type=recipe["meal_type"],
                cooking_time=recipe["cooking_time"]
            )
            print(f"   ✅ {result['message']}")
        except Exception as e:
            print(f"   ❌ Error: {e}")
    
    # Step 3: Show current preferences
    print("\n3. Current User Preferences:")
    print("-" * 50)
    
    try:
        preferences = get_user_preferences(user_id)
        
        print("   📊 Top Ingredient Preferences:")
        ingredient_prefs = preferences.get("preferences", {})
        sorted_ingredients = sorted(ingredient_prefs.items(), key=lambda x: x[1], reverse=True)[:5]
        for ingredient, score in sorted_ingredients:
            print(f"      {ingredient}: {score}/10")
        
        print("\n   🍽️ Meal Type Preferences:")
        meal_prefs = preferences.get("meal_type_preferences", {})
        for meal_type, score in meal_prefs.items():
            print(f"      {meal_type}: {score}/10")
        
        print("\n   ⏱️ Cooking Time Preferences:")
        time_prefs = preferences.get("cooking_time_preferences", {})
        for time_category, score in time_prefs.items():
            print(f"      {time_category}: {score}/10")
        
        print("\n   🔗 Top Ingredient Combinations:")
        combinations = preferences.get("ingredient_combinations", {})
        sorted_combinations = sorted(combinations.items(), key=lambda x: x[1], reverse=True)[:3]
        for combo, count in sorted_combinations:
            print(f"      {combo}: {count} times")
            
    except Exception as e:
        print(f"   ❌ Error getting preferences: {e}")
    
    # Step 4: Get recommendations with preferences
    print("\n4. Recommendations with User Preferences:")
    print("-" * 50)
    
    try:
        personalized_recommendations = get_recipe_recommendations(user_id, count=1)
        if personalized_recommendations:
            print(f"✅ Found {len(personalized_recommendations)} personalized recommendations")
            for i, recipe in enumerate(personalized_recommendations[:5], 1):
                print(f"   {i}. {recipe['name']}")
                print(f"      Cuisine: {recipe['cusine']}")
                print(f"      Meal Type: {recipe['mealType']}")
                print(f"      Cooking Time: {recipe['timeTaken']}")
                print(f"      Personalized: {recipe.get('personalized', False)}")
                if recipe.get('personalized'):
                    print(f"      Preference Score: {recipe.get('preference_score', 'N/A')}")
                    print(f"      Meal Type Match: {recipe.get('meal_type_match', 'N/A')}")
                    print(f"      Cooking Time Match: {recipe.get('cooking_time_match', 'N/A')}")
                    print(f"      Final Score: {recipe.get('final_score', 'N/A')}")
                print()
        else:
            print("❌ No personalized recommendations found")
    except Exception as e:
        print(f"❌ Error getting personalized recommendations: {e}")
    
    # Step 5: Compare recommendations
    print("\n5. Comparison Analysis:")
    print("-" * 50)
    
    if initial_recommendations and personalized_recommendations:
        print("   📈 Impact of Preferences:")
        print("   • Initial recommendations were based on inventory coverage and recipe complexity")
        print("   • Personalized recommendations now consider:")
        print("     - User's ingredient preferences (60% of preference weight)")
        print("     - Preferred meal types (20% of preference weight)")
        print("     - Preferred cooking times (20% of preference weight)")
        print("   • Final score combines base recipe score (60%) with preference score (40%)")
        
        # Check if recommendations changed
        initial_names = [r['name'] for r in initial_recommendations[:3]]
        personalized_names = [r['name'] for r in personalized_recommendations[:3]]
        
        if initial_names != personalized_names:
            print("\n   🎯 Recommendations changed due to preferences!")
            print("   Initial top 3:")
            for name in initial_names:
                print(f"     - {name}")
            print("   Personalized top 3:")
            for name in personalized_names:
                print(f"     - {name}")
        else:
            print("\n   🔄 Recommendations remained similar (preferences may not have strong impact yet)")
    
    print("\n" + "=" * 70)
    print("🎉 Preference Impact Test Complete!")
    print("\nKey Insights:")
    print("• User preferences are now integrated into recipe recommendations")
    print("• Recommendations become more personalized as users cook more recipes")
    print("• The system balances inventory availability with user preferences")
    print("• Preference scores help users understand why recipes are recommended")

if __name__ == "__main__":
    test_preference_impact_on_recommendations() 