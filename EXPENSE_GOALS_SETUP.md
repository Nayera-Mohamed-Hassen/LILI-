# Expense Goals Feature Setup Guide

This guide explains how to set up and use the Expense Goals functionality in your LILI Flutter app.

## Features

- **Set Spending Limits**: Create monthly, weekly, or yearly spending goals for different categories
- **Track Progress**: Visual progress bars showing how much you've spent vs. your target
- **Category-based Goals**: Set different limits for Grocery, Shopping, Transport, Bills, etc.
- **Real-time Updates**: Goals automatically update based on your actual expenses
- **Over-budget Alerts**: Visual indicators when you exceed your spending limits

## How to Access

1. Open the LILI app
2. Navigate to the **Expenses** section
3. Look for the **flag icon** (🏁) next to "Recent Expenses"
4. Tap the flag icon to open the Expense Goals page

## Backend Setup

### 1. The backend routes are already added to `user_routes.py`:

- `POST /user/expense-goals/add` - Add a new expense goal
- `POST /user/expense-goals/get` - Get all expense goals for a user
- `POST /user/expense-goals/get-with-progress` - Get goals with current spending progress
- `PUT /user/expense-goals/update` - Update an existing goal
- `DELETE /user/expense-goals/delete` - Delete a goal
- `PUT /user/expense-goals/update-progress` - Update goal progress

### 2. Test the functionality:

```bash
cd backEnd
python test_expense_goals.py
```

## Frontend Files

### New Files Created:
- `lib/models/expense_goal.dart` - Data model for expense goals
- `lib/services/expense_goal_service.dart` - API service for expense goals
- `lib/pages/expense_goals_page.dart` - Main expense goals management page

### Modified Files:
- `lib/pages/expenses_page.dart` - Added flag icon button next to "Recent Expenses"

## How to Use

### 1. Create a New Goal

1. Tap the **flag icon** next to "Recent Expenses"
2. Tap the **+ button** in the top-right corner
3. Select a **category** (Grocery, Shopping, Transport, etc.)
4. Enter your **target amount**
5. Choose a **period** (Weekly, Monthly, Yearly)
6. Tap **"Add Goal"**

### 2. View Your Goals

- All your active goals are displayed with:
  - **Category name**
  - **Target amount** vs **Current spending**
  - **Progress bar** with color coding:
    - 🟢 Green: Under budget
    - 🟡 Yellow: 60-80% of budget
    - 🟠 Orange: 80-100% of budget
    - 🔴 Red: Over budget
  - **Percentage** and **remaining amount**

### 3. Goal Progress

- Goals automatically track your spending based on:
  - **Category matching** with your expense transactions
  - **Time period** (weekly/monthly/yearly)
  - **Real-time updates** when you add new expenses

## Data Structure

### Expense Goal Model:
```dart
class ExpenseGoal {
  final String id;
  final String userId;
  final String category;
  final double targetAmount;
  final double currentAmount;
  final String period; // weekly, monthly, yearly
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;
}
```

### API Response Example:
```json
{
  "success": true,
  "goals": [
    {
      "id": "goal_123",
      "user_id": "user_456",
      "category": "Grocery",
      "target_amount": 500.0,
      "current_amount": 350.0,
      "period": "monthly",
      "start_date": "2024-01-01T00:00:00",
      "end_date": "2024-02-01T00:00:00",
      "is_active": true
    }
  ]
}
```

## Database Collections

The expense goals are stored in MongoDB in the `expenseGoals` collection with the following structure:

```javascript
{
  "_id": ObjectId,
  "id": "string",
  "user_id": "string",
  "category": "string",
  "target_amount": number,
  "current_amount": number,
  "period": "string",
  "start_date": "string",
  "end_date": "string",
  "is_active": boolean,
  "created_at": "string",
  "updated_at": "string"
}
```

## Categories Available

- Grocery
- Shopping
- Transport
- Bills
- Food
- Entertainment
- Healthcare
- Education
- Other

## Periods Available

- **Weekly**: 7-day goals
- **Monthly**: 30-day goals
- **Yearly**: 365-day goals

## Visual Indicators

### Progress Bar Colors:
- **Green**: 0-60% of target (Good progress)
- **Yellow**: 60-80% of target (Approaching limit)
- **Orange**: 80-100% of target (Near limit)
- **Red**: 100%+ of target (Over budget)

### Status Messages:
- **"Remaining: $X.XX"** - When under budget
- **"Over by $X.XX"** - When over budget

## Error Handling

The app includes comprehensive error handling for:
- Network connection issues
- Invalid goal data
- Duplicate goals for the same category
- Goal not found errors
- Database connection issues

## Future Enhancements

Potential improvements for the expense goals feature:
- **Notifications**: Alert when approaching or exceeding goals
- **Goal Templates**: Predefined goal suggestions
- **Goal Sharing**: Share goals with household members
- **Goal History**: Track goal performance over time
- **Smart Suggestions**: AI-powered goal recommendations
- **Goal Categories**: Group goals by priority or type

## Troubleshooting

### Common Issues:

1. **Goals not updating**: Ensure the backend server is running
2. **Progress not calculating**: Check that expenses are being added with correct categories
3. **Goals not appearing**: Verify user authentication and data loading
4. **API errors**: Check network connectivity and server status

### Testing:

Run the test script to verify all functionality:
```bash
cd backEnd
python test_expense_goals.py
```

## Integration with Existing Features

The expense goals feature integrates seamlessly with:
- **Transaction tracking**: Automatically calculates progress from expenses
- **Category system**: Uses existing expense categories
- **User authentication**: Tied to individual user accounts
- **Household system**: Can be extended for household-wide goals

This feature helps users better manage their spending by setting clear targets and tracking their progress in real-time! 