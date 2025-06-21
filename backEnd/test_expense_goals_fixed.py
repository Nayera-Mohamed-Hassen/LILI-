import requests
import json
from datetime import datetime, timedelta

# Test configuration
BASE_URL = "http://localhost:8000"
TEST_USER_ID = "test_user_123"

def test_expense_goals_routes():
    print("Testing Expense Goals Routes...")
    
    # Test 1: Add a new expense goal
    print("\n1. Testing ADD expense goal...")
    goal_data = {
        "user_id": TEST_USER_ID,
        "category": "Food",
        "target_amount": 500.0,
        "current_amount": 0.0,
        "period": "monthly",
        "start_date": datetime.now().isoformat(),
        "end_date": (datetime.now() + timedelta(days=30)).isoformat(),
        "is_active": True
    }
    
    try:
        response = requests.post(f"{BASE_URL}/user/expense-goals/add", json=goal_data)
        print(f"Status Code: {response.status_code}")
        print(f"Response: {response.json()}")
        
        if response.status_code == 200:
            goal_id = response.json().get("goal_id")
            print(f"Created goal with ID: {goal_id}")
        else:
            print("Failed to create goal")
            return
            
    except Exception as e:
        print(f"Error adding goal: {e}")
        return
    
    # Test 2: Get expense goals
    print("\n2. Testing GET expense goals...")
    try:
        response = requests.post(f"{BASE_URL}/user/expense-goals/get", 
                               json={"user_id": TEST_USER_ID})
        print(f"Status Code: {response.status_code}")
        print(f"Response: {response.json()}")
    except Exception as e:
        print(f"Error getting goals: {e}")
    
    # Test 3: Update expense goal
    print("\n3. Testing UPDATE expense goal...")
    if goal_id:
        update_data = {
            "id": goal_id,
            "user_id": TEST_USER_ID,
            "category": "Food",
            "target_amount": 600.0,  # Updated amount
            "current_amount": 150.0,
            "period": "monthly",
            "start_date": datetime.now().isoformat(),
            "end_date": (datetime.now() + timedelta(days=30)).isoformat(),
            "is_active": True
        }
        
        try:
            response = requests.put(f"{BASE_URL}/user/expense-goals/update", json=update_data)
            print(f"Status Code: {response.status_code}")
            print(f"Response: {response.json()}")
        except Exception as e:
            print(f"Error updating goal: {e}")
    
    # Test 4: Update goal progress
    print("\n4. Testing UPDATE goal progress...")
    if goal_id:
        try:
            response = requests.put(f"{BASE_URL}/user/expense-goals/update-progress", 
                                  json={"goal_id": goal_id, "current_amount": 200.0})
            print(f"Status Code: {response.status_code}")
            print(f"Response: {response.json()}")
        except Exception as e:
            print(f"Error updating progress: {e}")
    
    # Test 5: Get goals with progress
    print("\n5. Testing GET goals with progress...")
    try:
        response = requests.post(f"{BASE_URL}/user/expense-goals/get-with-progress", 
                               json={"user_id": TEST_USER_ID})
        print(f"Status Code: {response.status_code}")
        print(f"Response: {response.json()}")
    except Exception as e:
        print(f"Error getting goals with progress: {e}")
    
    # Test 6: Delete expense goal
    print("\n6. Testing DELETE expense goal...")
    if goal_id:
        try:
            response = requests.delete(f"{BASE_URL}/user/expense-goals/delete", 
                                     json={"goal_id": goal_id})
            print(f"Status Code: {response.status_code}")
            print(f"Response: {response.json()}")
        except Exception as e:
            print(f"Error deleting goal: {e}")

if __name__ == "__main__":
    test_expense_goals_routes() 