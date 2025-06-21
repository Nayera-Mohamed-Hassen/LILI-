#!/usr/bin/env python3
"""
Test script for favorite recipes functionality
"""

import sys
import os
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from app.routes.user_routes import add_favorite_recipe, remove_favorite_recipe, get_favorite_recipes, check_favorite_status
from app.routes.user_routes import FavoriteRecipeRequest, RemoveFavoriteRequest
import asyncio

async def test_favorites():
    print("Testing Favorite Recipes API...")
    
    # Test data
    test_user_id = "test_user_123"
    test_recipe = {
        "name": "Test Recipe",
        "cusine": "Italian",
        "mealType": "Dinner",
        "ingredients": ["pasta", "tomato", "cheese"],
        "available_ingredients": ["pasta", "tomato"],
        "missing_ingredients": ["cheese"],
        "ingredients_coverage": "67%",
        "steps": ["Step 1", "Step 2"],
        "timeTaken": "30 minutes",
        "difficulty": "Easy",
        "image": "test_recipe.jpg",
        "shared": False
    }
    
    try:
        # Test 1: Add favorite recipe
        print("\n1. Testing add favorite recipe...")
        add_request = FavoriteRecipeRequest(user_id=test_user_id, recipe=test_recipe)
        result = await add_favorite_recipe(add_request)
        print(f"✅ Add favorite result: {result}")
        
        # Test 2: Check if recipe is favorite
        print("\n2. Testing check favorite status...")
        check_result = await check_favorite_status(test_user_id, test_recipe["name"])
        print(f"✅ Check favorite result: {check_result}")
        
        # Test 3: Get all favorites
        print("\n3. Testing get favorite recipes...")
        favorites = await get_favorite_recipes(test_user_id)
        print(f"✅ Get favorites result: {len(favorites)} recipes found")
        
        # Test 4: Remove favorite recipe
        print("\n4. Testing remove favorite recipe...")
        remove_request = RemoveFavoriteRequest(user_id=test_user_id, recipe_name=test_recipe["name"])
        remove_result = await remove_favorite_recipe(remove_request)
        print(f"✅ Remove favorite result: {remove_result}")
        
        # Test 5: Check if recipe is no longer favorite
        print("\n5. Testing check favorite status after removal...")
        check_result_after = await check_favorite_status(test_user_id, test_recipe["name"])
        print(f"✅ Check favorite after removal: {check_result_after}")
        
        print("\n🎉 All tests passed!")
        
    except Exception as e:
        print(f"❌ Test failed: {e}")
        import traceback
        traceback.print_exc()

if __name__ == "__main__":
    asyncio.run(test_favorites()) 