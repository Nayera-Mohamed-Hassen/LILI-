import 'package:flutter/material.dart';
import '../models/expense_goal.dart';
import '../services/expense_goal_service.dart';
import 'dart:ui';

class ExpenseGoalsPage extends StatefulWidget {
  final String userId;

  const ExpenseGoalsPage({Key? key, required this.userId}) : super(key: key);

  @override
  _ExpenseGoalsPageState createState() => _ExpenseGoalsPageState();
}

class _ExpenseGoalsPageState extends State<ExpenseGoalsPage> {
  List<ExpenseGoal> goals = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadGoals();
  }

  Future<void> _loadGoals() async {
    setState(() => _isLoading = true);
    try {
      final loadedGoals = await ExpenseGoalService.getExpenseGoalsWithProgress(widget.userId);
      setState(() {
        goals = loadedGoals;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading goals: $e')),
      );
    }
  }

  Future<void> _addGoal() async {
    final result = await showDialog<ExpenseGoal>(
      context: context,
      builder: (context) => AddEditGoalDialog(userId: widget.userId),
    );

    if (result != null) {
      setState(() => _isLoading = true);
      try {
        final success = await ExpenseGoalService.addExpenseGoal(result);
        if (success) {
          await _loadGoals();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Spending limit added successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to add spending limit'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding spending limit: $e'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _editGoal(ExpenseGoal goal) async {
    final result = await showDialog<ExpenseGoal>(
      context: context,
      builder: (context) => AddEditGoalDialog(userId: widget.userId, goal: goal),
    );

    if (result != null) {
      setState(() => _isLoading = true);
      try {
        final success = await ExpenseGoalService.updateExpenseGoal(result);
        if (success) {
          await _loadGoals();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Spending limit updated successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to update spending limit'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating spending limit: $e'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _deleteGoal(ExpenseGoal goal) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xFF1F3354),
        title: Text('Delete Spending Limit', style: TextStyle(color: Colors.white)),
        content: Text(
          'Are you sure you want to delete the spending limit for ${goal.category}?',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            style: TextButton.styleFrom(
              backgroundColor: Color(0xFF1F3354),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text('Cancel', style: TextStyle(color: Colors.white)),
          ),
          SizedBox(width: 8),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF1F3354),
              side: BorderSide(color: Colors.red, width: 2),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => _isLoading = true);
      try {
        final success = await ExpenseGoalService.deleteExpenseGoal(goal.id);
        if (success) {
          // Remove the goal from the local list immediately for better UX
          setState(() {
            goals.removeWhere((g) => g.id == goal.id);
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Spending limit deleted successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete spending limit'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting spending limit: $e'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  Color _getProgressColor(double percentage) {
    if (percentage >= 100) return Colors.red;
    if (percentage >= 80) return Colors.orange;
    if (percentage >= 60) return Colors.yellow;
    return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        backgroundColor: const Color(0xFF1F3354),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Spending Limits',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: Colors.white),
            onPressed: _addGoal,
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [const Color(0xFF1F3354), const Color(0xFF3E5879)],
          ),
        ),
        child: _isLoading
            ? Center(
                child: CircularProgressIndicator(color: Colors.white),
              )
            : goals.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.flag_outlined,
                          size: 80,
                          color: Colors.white54,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No spending limits yet',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 18,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Set spending limits for categories to track your budget',
                          style: TextStyle(
                            color: Colors.white54,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  )
                : Stack(
                    children: [
                      RefreshIndicator(
                        onRefresh: _loadGoals,
                        color: Colors.white,
                        backgroundColor: Color(0xFF1F3354),
                        child: ListView.builder(
                          padding: EdgeInsets.all(16),
                          itemCount: goals.length,
                          itemBuilder: (context, index) {
                            final goal = goals[index];
                            final progressColor = _getProgressColor(goal.progressPercentage);
                            
                            return Card(
                              margin: EdgeInsets.only(bottom: 16),
                              color: Colors.white.withOpacity(0.1),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                                side: BorderSide(color: Colors.white24),
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            goal.category,
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        PopupMenuButton<String>(
                                          icon: Icon(Icons.more_vert, color: Colors.white),
                                          onSelected: (value) {
                                            if (value == 'edit') {
                                              _editGoal(goal);
                                            } else if (value == 'delete') {
                                              _deleteGoal(goal);
                                            }
                                          },
                                          itemBuilder: (context) => [
                                            PopupMenuItem(
                                              value: 'edit',
                                              child: Row(
                                                children: [
                                                  Icon(Icons.edit, color:Color(0xFF1F3354)),
                                                  SizedBox(width: 8),
                                                  Text('Edit', style: TextStyle(color: Color(0xFF1F3354))),
                                                ],
                                              ),
                                            ),
                                            PopupMenuItem(
                                              value: 'delete',
                                              child: Row(
                                                children: [
                                                  Icon(Icons.delete, color: Colors.red),
                                                  SizedBox(width: 8),
                                                  Text('Delete', style: TextStyle(color: Colors.red)),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    
                                    SizedBox(height: 12),
                                    
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Limit: \$${goal.targetAmount.toStringAsFixed(2)}',
                                          style: TextStyle(color: Colors.white70),
                                        ),
                                        Text(
                                          'Spent: \$${goal.currentAmount.toStringAsFixed(2)}',
                                          style: TextStyle(color: Colors.white70),
                                        ),
                                      ],
                                    ),
                                    
                                    SizedBox(height: 8),
                                    
                                    LinearProgressIndicator(
                                      value: goal.progressPercentage / 100,
                                      backgroundColor: Colors.white24,
                                      valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                                      minHeight: 8,
                                    ),
                                    
                                    SizedBox(height: 8),
                                    
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          '${goal.progressPercentage.toStringAsFixed(1)}%',
                                          style: TextStyle(
                                            color: progressColor,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        if (goal.isOverBudget)
                                          Text(
                                            'Over by \$${goal.overBudgetAmount}',
                                            style: TextStyle(
                                              color: Colors.red,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          )
                                        else
                                          Text(
                                            'Remaining: \$${goal.remainingAmount}',
                                            style: TextStyle(
                                              color: Colors.green,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                      ],
                                    ),
                                    
                                    SizedBox(height: 8),
                                    
                                    Text(
                                      'Period: ${goal.period}',
                                      style: TextStyle(
                                        color: Colors.white54,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addGoal,
        backgroundColor: Colors.white,
        child: Icon(Icons.add, color: Color(0xFF1F3354)),
      ),
    );
  }
}

class AddEditGoalDialog extends StatefulWidget {
  final String userId;
  final ExpenseGoal? goal;

  const AddEditGoalDialog({
    Key? key,
    required this.userId,
    this.goal,
  }) : super(key: key);

  @override
  _AddEditGoalDialogState createState() => _AddEditGoalDialogState();
}

class _AddEditGoalDialogState extends State<AddEditGoalDialog> {
  final _formKey = GlobalKey<FormState>();
  final _categoryController = TextEditingController();
  final _amountController = TextEditingController();
  String _selectedPeriod = 'monthly';

  final List<String> categories = [
    'Grocery',
    'Shopping',
    'Transport',
    'Bills',
    'Food',
    'Entertainment',
    'Healthcare',
    'Education',
    'Other',
  ];

  final List<String> periods = ['weekly', 'monthly', 'yearly'];

  @override
  void initState() {
    super.initState();
    if (widget.goal != null) {
      _categoryController.text = widget.goal!.category;
      _amountController.text = widget.goal!.targetAmount.toString();
      _selectedPeriod = widget.goal!.period;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Color(0xFF1F3354),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white24),
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.goal == null ? 'Add Spending Limit' : 'Edit Spending Limit',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              SizedBox(height: 20),
              
              DropdownButtonFormField<String>(
                value: _categoryController.text.isEmpty ? null : _categoryController.text,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Category',
                  labelStyle: TextStyle(color: Colors.white70),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.white24),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.white24),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.white),
                  ),
                  filled: true,
                  fillColor: Colors.white12,
                ),
                dropdownColor: Color(0xFF1F3354),
                items: categories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category, style: TextStyle(color: Colors.white)),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _categoryController.text = value!;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a category';
                  }
                  return null;
                },
              ),
              
              SizedBox(height: 16),
              
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Spending Limit (\$)',
                  labelStyle: TextStyle(color: Colors.white70),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.white24),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.white24),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.white),
                  ),
                  filled: true,
                  fillColor: Colors.white12,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter spending limit';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  if (double.parse(value) <= 0) {
                    return 'Spending limit must be greater than 0';
                  }
                  return null;
                },
              ),
              
              SizedBox(height: 16),
              
              DropdownButtonFormField<String>(
                value: _selectedPeriod,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Period',
                  labelStyle: TextStyle(color: Colors.white70),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.white24),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.white24),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.white),
                  ),
                  filled: true,
                  fillColor: Colors.white12,
                ),
                dropdownColor: Color(0xFF1F3354),
                items: periods.map((period) {
                  return DropdownMenuItem(
                    value: period,
                    child: Text(
                      period.substring(0, 1).toUpperCase() + period.substring(1),
                      style: TextStyle(color: Colors.white),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedPeriod = value!;
                  });
                },
              ),
              
              SizedBox(height: 24),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: TextButton.styleFrom(
                      backgroundColor: Color(0xFF1F3354),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Text('Cancel', style: TextStyle(color: Colors.white)),
                  ),
                  SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        final now = DateTime.now();
                        DateTime endDate;
                        
                        switch (_selectedPeriod) {
                          case 'weekly':
                            endDate = now.add(Duration(days: 7));
                            break;
                          case 'monthly':
                            endDate = DateTime(now.year, now.month + 1, now.day);
                            break;
                          case 'yearly':
                            endDate = DateTime(now.year + 1, now.month, now.day);
                            break;
                          default:
                            endDate = now.add(Duration(days: 30));
                        }
                        
                        final goal = ExpenseGoal(
                          id: widget.goal?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                          userId: widget.userId,
                          category: _categoryController.text,
                          targetAmount: double.parse(_amountController.text),
                          currentAmount: widget.goal?.currentAmount ?? 0.0,
                          period: _selectedPeriod,
                          startDate: widget.goal?.startDate ?? now,
                          endDate: widget.goal?.endDate ?? endDate,
                          isActive: true,
                        );
                        
                        Navigator.of(context).pop(goal);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF1F3354),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(
                      widget.goal == null ? 'Add Limit' : 'Update Limit',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
} 