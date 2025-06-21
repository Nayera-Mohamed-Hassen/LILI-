import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/expense_goal.dart';

class ExpenseGoalService {
  static const String baseUrl = 'http://10.0.2.2:8000'; // Update with your backend URL

  /// Get all expense goals for a user
  static Future<List<ExpenseGoal>> getExpenseGoals(String userId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/user/expense-goals/get'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'user_id': userId}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          final goals = data['goals'] as List;
          return goals.map((goal) => ExpenseGoal.fromJson(goal)).toList();
        }
      }
      return [];
    } catch (e) {
      throw Exception('Error fetching expense goals: $e');
    }
  }

  /// Add a new expense goal
  static Future<bool> addExpenseGoal(ExpenseGoal goal) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/user/expense-goals/add'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(goal.toJson()),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] == true;
      }
      return false;
    } catch (e) {
      throw Exception('Error adding expense goal: $e');
    }
  }

  /// Update an existing expense goal
  static Future<bool> updateExpenseGoal(ExpenseGoal goal) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/user/expense-goals/update'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(goal.toJson()),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] == true;
      }
      return false;
    } catch (e) {
      throw Exception('Error updating expense goal: $e');
    }
  }

  /// Delete an expense goal
  static Future<bool> deleteExpenseGoal(String goalId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/user/expense-goals/delete'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'goal_id': goalId}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] == true;
      }
      return false;
    } catch (e) {
      throw Exception('Error deleting expense goal: $e');
    }
  }

  /// Update current amount for a goal based on recent expenses
  static Future<bool> updateGoalProgress(String goalId, double currentAmount) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/user/expense-goals/update-progress'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'goal_id': goalId,
          'current_amount': currentAmount,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] == true;
      }
      return false;
    } catch (e) {
      throw Exception('Error updating goal progress: $e');
    }
  }

  /// Get expense goals with current progress calculated
  static Future<List<ExpenseGoal>> getExpenseGoalsWithProgress(String userId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/user/expense-goals/get-with-progress'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'user_id': userId}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          final goals = data['goals'] as List;
          return goals.map((goal) => ExpenseGoal.fromJson(goal)).toList();
        }
      }
      return [];
    } catch (e) {
      throw Exception('Error fetching expense goals with progress: $e');
    }
  }
} 