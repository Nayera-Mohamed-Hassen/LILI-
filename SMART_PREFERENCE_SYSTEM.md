# Smart User Preference System

## Overview

The Smart User Preference System automatically learns and updates user preferences when recipes are cooked. This system makes recipe recommendations more personalized and intelligent over time. **User preferences now directly affect recipe recommendations**, making them more relevant to individual users.

## Features

### 🧠 Smart Preference Learning
- **Ingredient Preferences**: Tracks which ingredients users prefer based on cooking history
- **Meal Type Preferences**: Learns preferred meal types (breakfast, lunch, dinner, etc.)
- **Cooking Time Preferences**: Understands user's preferred cooking time ranges
- **Ingredient Combinations**: Tracks frequently used ingredient pairs and combinations

### 🎯 Intelligent Boosting System
- **Complexity Boost**: Complex recipes (more ingredients) get higher preference boosts
- **Main Ingredient Boost**: First 3 ingredients in a recipe get higher boosts
- **Protein Boost**: Protein-rich ingredients get additional preference weight
- **Fresh Ingredient Boost**: Fresh vegetables and herbs get preference boosts
- **Diminishing Returns**: Prevents preferences from becoming too extreme

### 📊 Preference Analysis
- **Preference Scoring**: Calculates preference match scores for new recipes
- **Combination Analysis**: Identifies frequently used ingredient combinations
- **Cooking History**: Maintains detailed cooking session history
- **Trend Analysis**: Tracks preference changes over time

### 🎯 **Recipe Recommendation Integration**
- **Personalized Rankings**: Recipe recommendations now consider user preferences
- **Preference Weighting**: 40% preference score + 60% base recipe score
- **Multi-factor Scoring**: Ingredient preferences (60%), meal types (20%), cooking times (20%)
- **Dynamic Adaptation**: Recommendations improve as users cook more recipes

## Implementation Details

### Backend Components

#### 1. `update_preferences_on_cook()` Function
**Location**: `backEnd/app/recipeAI.py`

**Parameters**:
- `user_id`: User's unique identifier
- `recipe_ingredients`: List of ingredients used in the recipe
- `recipe_name`: Name of the recipe (for logging)
- `meal_type`: Type of meal (breakfast, lunch, dinner, etc.)
- `cooking_time`: Time taken to cook the recipe

**Smart Features**:
- Ingredient cleaning and standardization
- Multi-factor preference boosting
- Meal type and cooking time tracking
- Ingredient combination analysis
- Cooking history logging

#### 2. `get_user_preferences()` Function
**Location**: `backEnd/app/recipeAI.py`

**Returns**: Complete user preference data including:
- Ingredient preferences with scores (1-10)
- Meal type preferences
- Cooking time preferences
- Ingredient combinations
- Cooking history

#### 3. `calculate_preference_boost()` Function
**Location**: `backEnd/app/recipeAI.py`

**Purpose**: Calculate preference match score for recipe recommendations

**Returns**: Float (0.0-1.0) representing preference match strength

#### 4. **Enhanced `get_recipe_recommendations()` Function**
**Location**: `backEnd/app/recipeAI.py`

**New Features**:
- **Preference Integration**: Loads and applies user preferences to recipe scoring
- **Multi-factor Scoring**: Combines base recipe score with preference scores
- **Personalized Rankings**: Sorts recipes by final personalized score
- **Preference Metadata**: Returns preference scores and match information

**Scoring Algorithm**:
```
Final Score = (0.6 × Base Recipe Score) + (0.4 × Preference Score)
Preference Score = (0.6 × Ingredient Match) + (0.2 × Meal Type Match) + (0.2 × Cooking Time Match)
```

### API Endpoints

#### POST `/user/preferences/update-on-cook`
Updates user preferences when a recipe is cooked.

**Request Body**:
```json
{
  "user_id": "string",
  "recipe_name": "string",
  "ingredients": ["string"],
  "meal_type": "string",
  "cooking_time": "string"
}
```

**Response**:
```json
{
  "status": "success",
  "message": "Preferences updated for X ingredients",
  "updated_ingredients": ["string"],
  "meal_type_updated": true,
  "cooking_time_updated": true
}
```

#### GET `/user/preferences/{user_id}`
Retrieves user preferences and cooking history.

#### **Enhanced Recipe Recommendations**
The existing recipe recommendation endpoint now returns personalized results:

**Response includes**:
```json
{
  "name": "Recipe Name",
  "cusine": "Italian",
  "mealType": "dinner",
  "ingredients": ["ingredient1", "ingredient2"],
  "available_ingredients": ["ingredient1"],
  "missing_ingredients": ["ingredient2"],
  "steps": ["step1", "step2"],
  "timeTaken": "30 minutes",
  "difficulty": "Medium",
  "image": "recipe.jpg",
  "personalized": true,
  "preference_score": 0.85,
  "meal_type_match": 0.8,
  "cooking_time_match": 0.9,
  "final_score": 0.78
}
```

### Frontend Integration

#### CookingStepsPage Updates
**Location**: `lib/pages/CookingStepsPage.dart`

**New Features**:
- Accepts recipe name, ingredients, meal type, and cooking time
- Calls preference update API when "Finish Cooking" is pressed
- Shows success/error messages to user
- Loading state during preference update

**Enhanced UI**:
- Recipe name displayed in header
- Progress indicator for preference update
- Success/error feedback via SnackBar

## Data Structure

### User Preferences JSON Structure
```json
{
  "user_id": {
    "preferences": {
      "chicken": 4.2,
      "garlic": 6.1,
      "onion": 5.3
    },
    "meal_type_preferences": {
      "dinner": 3,
      "breakfast": 2
    },
    "cooking_time_preferences": {
      "quick": 2,
      "medium": 3,
      "long": 1
    },
    "ingredient_combinations": {
      "garlic+onion": 5,
      "chicken+soy sauce": 3
    },
    "cooking_history": [
      {
        "recipe_name": "Chicken Stir Fry",
        "ingredients": ["chicken", "garlic", "onion"],
        "meal_type": "dinner",
        "cooking_time": "20 minutes",
        "cooked_at": "2025-06-21T10:30:00",
        "preference_boosts": {
          "chicken": 4.2,
          "garlic": 6.1,
          "onion": 5.3
        }
      }
    ],
    "updated_at": "2025-06-21T10:30:00"
  }
}
```

## Smart Boosting Algorithm

### Ingredient Preference Boost Calculation
```
Base Boost = 1.0
Complexity Boost = min(ingredients_count / 5, 2.0)
Main Ingredient Boost = 1.5 (if ingredient is in first 3) else 1.0
Protein Boost = 1.3 (if ingredient contains protein) else 1.0
Fresh Boost = 1.2 (if ingredient is fresh) else 1.0

Total Boost = Base × Complexity × Main × Protein × Fresh
New Preference = min(Current + Total Boost, 10.0)
```

### Preference Match Score Calculation
```
Ingredient Score = average(preference_scores) / 10.0
Combination Score = min(combination_count / 10.0, 0.5)
Total Score = min(Ingredient + Combination, 1.0)
```

### **Recipe Recommendation Scoring**
```
Base Recipe Score = (0.4 × Complexity) + (0.6 × Coverage)
Preference Score = (0.6 × Ingredient Match) + (0.2 × Meal Type Match) + (0.2 × Cooking Time Match)
Final Score = (0.6 × Base Recipe Score) + (0.4 × Preference Score)
```

## Usage Examples

### 1. Cooking a Recipe
When user completes cooking steps:
1. Frontend calls `/user/preferences/update-on-cook`
2. Backend processes ingredients and updates preferences
3. User receives confirmation message
4. Preferences are saved for future recommendations

### 2. **Recipe Recommendations (Now Personalized)**
For new recipe suggestions:
1. Get user preferences via `/user/preferences/{user_id}`
2. Calculate preference boost for each candidate recipe
3. **Combine base recipe score with preference score**
4. **Sort recipes by final personalized score**
5. Present personalized recommendations with preference metadata

### 3. Preference Analysis
To understand user cooking patterns:
1. Retrieve cooking history
2. Analyze ingredient combinations
3. Identify meal type preferences
4. Track cooking time patterns

## Benefits

### For Users
- **Personalized Recommendations**: Recipes match cooking preferences
- **Learning System**: App gets smarter with each cooking session
- **Cooking Insights**: Understand own cooking patterns
- **Better Suggestions**: More relevant recipe recommendations
- **🎯 Dynamic Adaptation**: Recommendations improve over time

### For Developers
- **Extensible System**: Easy to add new preference types
- **Data-Driven**: Rich analytics on user behavior
- **Scalable**: Efficient preference storage and retrieval
- **Maintainable**: Clean, well-documented code structure
- **🎯 Integrated Scoring**: Seamless preference integration in recommendations

## Future Enhancements

### Potential Improvements
1. **Seasonal Preferences**: Track seasonal ingredient preferences
2. **Dietary Restrictions**: Learn dietary preferences and restrictions
3. **Cuisine Preferences**: Track preferred cuisines and styles
4. **Cooking Skill Level**: Adapt to user's cooking expertise
5. **Social Preferences**: Learn from household cooking patterns
6. **Health Preferences**: Track healthy vs. indulgent preferences

### Integration Opportunities
1. **Recipe Recommendations**: ✅ **Already implemented** - Use preferences for better recipe suggestions
2. **Shopping Lists**: Suggest ingredients based on preferences
3. **Meal Planning**: Create meal plans matching preferences
4. **Nutrition Tracking**: Align with dietary goals
5. **Social Features**: Share preferences with household members

## Testing

### Basic Preference System Test
Run the test script to see the system in action:
```bash
cd backEnd
python test_preferences.py
```

### **Preference Impact on Recommendations Test**
Test how preferences affect recipe recommendations:
```bash
cd backEnd
python test_preference_recommendations.py
```

This will demonstrate:
- Initial recommendations (no preferences)
- Building user preferences by cooking recipes
- Personalized recommendations with preferences
- Comparison of recommendation changes
- Preference scoring and ranking

## Conclusion

The Smart User Preference System provides a foundation for highly personalized recipe recommendations. **User preferences now directly influence recipe rankings**, making the app more intelligent and user-friendly. By learning from user behavior, the system continuously improves its understanding of individual preferences, leading to better user experience and more relevant content suggestions.

### **Key Achievement**
✅ **User preferences now affect recipe recommendations** - The system has been successfully integrated to provide personalized recipe suggestions based on individual cooking history and preferences. 