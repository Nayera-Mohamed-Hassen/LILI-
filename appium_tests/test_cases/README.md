# Appium Test Cases for LILI Project

This folder contains automated UI test cases for the LILI mobile application, written using Appium.

## Test Case List

### 1. Authentication & User Management
- **test_login.py**: Test login with valid and invalid credentials
- **test_logout.py**: Test logout functionality

### 2. Navigation & UI
- **test_navigation.py**: Test navigation between all main screens
- **test_back_button.py**: Test back button behavior

### 3. Calendar & Events
- **test_add_event.py**: Add calendar events
- **test_delete_event.py**: Delete calendar events

### 4. Emergency Features
- **test_trigger_emergency.py**: Test emergency alert triggering

### 5. Inventory Management
- **test_add_inventory_item.py**: Add inventory items
- **test_low_stock_alert.py**: Test low stock alerts in dashboard

### 6. Budget & Expenses
- **test_add_expense.py**: Add new expenses
- **test_budget_summary.py**: View budget summary

### 7. Notifications
- **test_receive_notification.py**: Receive notifications
- **test_notification_navigation.py**: Navigate from notifications

### 8. Preferences & Recommendations
- **test_set_preferences.py**: Set user preferences
- **test_recommendations.py**: Get recommendations based on preferences

### 9. Recipes
- **test_browse_recipes.py**: Browse available recipes
- **test_add_favorite_recipe.py**: Add recipes to favorites

---

## How to Use
- Each test case is implemented in a separate Python file
- Update the desired capabilities in each test file to match your device/emulator and app path
- Run tests using `python <test_file.py>` or integrate with a test runner like `pytest` or `unittest`

---

Note: This test suite is configured for the "first android" emulator and requires the LILI APK path to be set in the test configuration. 