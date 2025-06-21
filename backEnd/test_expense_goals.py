#!/usr/bin/env python3
"""
Test script for Expense Goals functionality
"""

import requests
import json
from datetime import datetime, timedelta

def test_expense_goals():
    """Test the expense goals endpoints"""
    
    base_url = "http://localhost:8000"
    test_user_id = "test_user_123"
    
    print("=== Testing Expense Goals Functionality ===")
    print()
    
    # Test 1: Add a new expense goal
    print("1. Testing Add Expense Goal...")
    goal_data = {
        "id": "test_goal_1",
        "user_id": test_user_id,
        "category": "Grocery",
        "target_amount": 500.0,
        "current_amount": 0.0,
        "period": "monthly",
        "start_date": datetime.now().isoformat(),
        "end_date": (datetime.now() + timedelta(days=30)).isoformat(),
        "is_active": True
    }
    
    try:
        response = requests.post(
            f"{base_url}/user/expense-goals/add",
            json=goal_data
        )
        
        if response.status_code == 200:
            result = response.json()
            print(f"   ✓ Goal added successfully: {result['message']}")
            goal_id = result.get('goal_id', 'test_goal_1')
        else:
            print(f"   ✗ Failed to add goal: {response.status_code} - {response.text}")
            goal_id = 'test_goal_1'
    except Exception as e:
        print(f"   ✗ Error adding goal: {e}")
        goal_id = 'test_goal_1'
    
    print()
    
    # Test 2: Get expense goals
    print("2. Testing Get Expense Goals...")
    try:
        response = requests.post(
            f"{base_url}/user/expense-goals/get",
            json={"user_id": test_user_id}
        )
        
        if response.status_code == 200:
            result = response.json()
            goals = result.get('goals', [])
            print(f"   ✓ Retrieved {len(goals)} goals")
            for goal in goals:
                print(f"      - {goal['category']}: ${goal['target_amount']} ({goal['period']})")
        else:
            print(f"   ✗ Failed to get goals: {response.status_code} - {response.text}")
    except Exception as e:
        print(f"   ✗ Error getting goals: {e}")
    
    print()
    
    # Test 3: Get expense goals with progress
    print("3. Testing Get Expense Goals with Progress...")
    try:
        response = requests.post(
            f"{base_url}/user/expense-goals/get-with-progress",
            json={"user_id": test_user_id}
        )
        
        if response.status_code == 200:
            result = response.json()
            goals = result.get('goals', [])
            print(f"   ✓ Retrieved {len(goals)} goals with progress")
            for goal in goals:
                progress = (goal['current_amount'] / goal['target_amount'] * 100) if goal['target_amount'] > 0 else 0
                print(f"      - {goal['category']}: ${goal['current_amount']:.2f}/${goal['target_amount']:.2f} ({progress:.1f}%)")
        else:
            print(f"   ✗ Failed to get goals with progress: {response.status_code} - {response.text}")
    except Exception as e:
        print(f"   ✗ Error getting goals with progress: {e}")
    
    print()
    
    # Test 4: Update goal progress
    print("4. Testing Update Goal Progress...")
    try:
        response = requests.put(
            f"{base_url}/user/expense-goals/update-progress",
            json={
                "goal_id": goal_id,
                "current_amount": 150.0
            }
        )
        
        if response.status_code == 200:
            result = response.json()
            print(f"   ✓ Progress updated successfully: {result['message']}")
        else:
            print(f"   ✗ Failed to update progress: {response.status_code} - {response.text}")
    except Exception as e:
        print(f"   ✗ Error updating progress: {e}")
    
    print()
    
    # Test 5: Delete expense goal
    print("5. Testing Delete Expense Goal...")
    try:
        response = requests.delete(
            f"{base_url}/user/expense-goals/delete",
            json={"goal_id": goal_id}
        )
        
        if response.status_code == 200:
            result = response.json()
            print(f"   ✓ Goal deleted successfully: {result['message']}")
        else:
            print(f"   ✗ Failed to delete goal: {response.status_code} - {response.text}")
    except Exception as e:
        print(f"   ✗ Error deleting goal: {e}")
    
    print()
    print("=== Expense Goals Testing Completed ===")
    print()
    print("To use this in your Flutter app:")
    print("1. Start the backend server: python -m uvicorn app.main:app --reload")
    print("2. Run the Flutter app")
    print("3. Navigate to Expenses page")
    print("4. Tap the flag icon next to 'Recent Expenses'")

if __name__ == "__main__":
    test_expense_goals() 