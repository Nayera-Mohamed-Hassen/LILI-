# Terminology Update: Expense Goals → Spending Limits

This document outlines the terminology changes made to clarify that expense goals are spending limits for specific categories, not income targets.

## Problem Identified

The user clarified that when setting a "goal" in the expenses page, they want to set a spending limit for a category (e.g., don't exceed $500 on groceries this month), not a total income target. The previous terminology was confusing and could be misinterpreted.

## Changes Made

### 1. **Expense Goals Page**
**File**: `lib/pages/expense_goals_page.dart`

#### **App Bar Title**
- **Before**: "Expense Goals"
- **After**: "Spending Limits"

#### **Empty State Messages**
- **Before**: "No expense goals yet" / "Tap the + button to add your first goal"
- **After**: "No spending limits yet" / "Set spending limits for categories to track your budget"

#### **Dialog Titles**
- **Before**: "Add Expense Goal" / "Edit Expense Goal"
- **After**: "Add Spending Limit" / "Edit Spending Limit"

#### **Form Labels**
- **Before**: "Target Amount ($)"
- **After**: "Spending Limit ($)"

#### **Validation Messages**
- **Before**: "Please enter target amount" / "Amount must be greater than 0"
- **After**: "Please enter spending limit" / "Spending limit must be greater than 0"

#### **Button Text**
- **Before**: "Add Goal" / "Update Goal"
- **After**: "Add Limit" / "Update Limit"

#### **Card Labels**
- **Before**: "Target: $X" / "Current: $Y"
- **After**: "Limit: $X" / "Spent: $Y"

#### **Delete Confirmation**
- **Before**: "Delete Goal" / "Are you sure you want to delete the goal for [category]?"
- **After**: "Delete Spending Limit" / "Are you sure you want to delete the spending limit for [category]?"

### 2. **Dashboard Page**
**File**: `lib/pages/dash_board_page.dart`

#### **Modal Title**
- **Before**: "Budget Overview"
- **After**: "Spending Limits Analysis"

#### **Chart Title**
- **Before**: "Spending vs Goals"
- **After**: "Spending vs Limits"

#### **Breakdown Title**
- **Before**: "Goals Breakdown"
- **After**: "Spending Limits Breakdown"

#### **Empty State Messages**
- **Before**: "No expense goals found" / "Create some goals to see your spending analysis!"
- **After**: "No spending limits found" / "Create spending limits to see your budget analysis!"

#### **Counter Text**
- **Before**: "X active goals"
- **After**: "X active limits"

#### **Chart Tooltips**
- **Before**: "Target: $X" / "Over by: $Y" / "Remaining: $Z"
- **After**: "Limit: $X" / "Over limit by: $Y" / "Under limit by: $Z"

#### **Legend Text**
- **Before**: "Under Budget" / "Over Budget"
- **After**: "Under Limit" / "Over Limit"

#### **Breakdown Details**
- **Before**: "Target: $X" / "Over by: $Y" / "Remaining: $Z"
- **After**: "Limit: $X" / "Over limit by: $Y" / "Under limit by: $Z"

## User Experience Improvements

### **Clarity**
- **Before**: Users might think they're setting income targets
- **After**: Clear that these are spending limits for categories

### **Consistency**
- **Before**: Mixed terminology (goals, targets, amounts)
- **After**: Consistent "spending limit" terminology throughout

### **Purpose**
- **Before**: Ambiguous purpose of the feature
- **After**: Clear purpose: set spending limits to avoid overspending

## Examples of Usage

### **Setting a Spending Limit**
1. User wants to limit grocery spending to $500/month
2. Creates a "Spending Limit" for "Grocery" category
3. Sets limit to $500
4. App tracks spending against this limit

### **Monitoring Progress**
- **Under Limit**: Green indicators, "Under limit by: $X"
- **Over Limit**: Red indicators, "Over limit by: $X"
- **Progress**: Shows percentage of limit used

### **Dashboard View**
- **Chart**: Visual comparison of spending vs limits
- **Breakdown**: Individual limit status with progress bars
- **Summary**: Total spent vs total limits across all categories

## Benefits

### **For Users**
- **Clear Understanding**: Know exactly what they're setting (spending limits)
- **Better Budgeting**: Focus on controlling spending, not earning targets
- **Reduced Confusion**: No ambiguity about the feature's purpose

### **For Budget Management**
- **Proactive Control**: Set limits before overspending
- **Category Focus**: Control spending in specific areas
- **Visual Feedback**: Clear indicators of limit status

### **For App Usability**
- **Intuitive Interface**: Terminology matches user expectations
- **Consistent Experience**: Same terminology throughout the app
- **Clear Purpose**: Users understand the feature's intent

## Technical Implementation

### **No Backend Changes**
- All terminology changes are frontend-only
- Database structure remains the same
- API endpoints unchanged
- Only UI text and labels updated

### **Maintained Functionality**
- All existing features work exactly the same
- Progress calculation unchanged
- Over/under budget logic preserved
- Chart and visualization functionality intact

## Future Considerations

### **Potential Enhancements**
- **Limit Notifications**: Alert when approaching spending limits
- **Limit Suggestions**: AI-powered limit recommendations
- **Limit History**: Track limit changes over time
- **Limit Sharing**: Share limits with household members

### **Additional Terminology**
- Consider updating related features to use consistent terminology
- Review other parts of the app for similar clarifications
- Ensure new features use "spending limit" terminology

The terminology update makes the feature much clearer and aligns with user expectations for budget management! 