import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:LILI/services/task_service.dart';
import 'package:LILI/models/task.dart';
import 'package:LILI/models/expense_goal.dart';
import 'package:LILI/services/expense_goal_service.dart';
import 'package:LILI/services/transaction_service.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:fl_chart/fl_chart.dart';

class ReportDashboard extends StatefulWidget {
  final String userId;

  const ReportDashboard({super.key, required this.userId});

  @override
  _ReportDashboardState createState() => _ReportDashboardState();
}

class _ReportDashboardState extends State<ReportDashboard> {
  List<ExpenseGoal> goals = [];
  Map<String, double> categorySpending = {};
  bool _isLoading = true;
  double totalSpent = 0.0;
  double totalBudget = 0.0;

  @override
  void initState() {
    super.initState();
    _loadBudgetData();
  }

  Future<void> _loadBudgetData() async {
    setState(() => _isLoading = true);
    try {
      // Load expense goals
      final loadedGoals = await ExpenseGoalService.getExpenseGoalsWithProgress(widget.userId);
      
      // Load recent transactions to calculate current spending
      final transactions = await TransactionService.getTransactions(widget.userId);
      
      // Calculate spending by category
      Map<String, double> spending = {};
      double total = 0.0;
      
      for (var transaction in transactions) {
        if (transaction['transaction_type'] == 'expense') {
          final category = transaction['category'];
          final amount = transaction['amount'];
          spending[category] = (spending[category] ?? 0.0) + amount;
          total += amount;
        }
      }
      
      setState(() {
        goals = loadedGoals;
        categorySpending = spending;
        totalSpent = total;
        totalBudget = goals.fold(0.0, (sum, goal) => sum + goal.targetAmount);
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading budget data: $e');
      setState(() {
        goals = [];
        categorySpending = {};
        totalSpent = 0.0;
        totalBudget = 0.0;
        _isLoading = false;
      });
    }
  }

  Widget buildCard(
    String title,
    IconData icon,
    Color color,
    String value,
    String subtitle, {
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: SizedBox(
        width: 162,
        height: 190,
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 4,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: color.withOpacity(0.6),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, size: 30, color: color),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 12, color: Colors.black),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void showDetailSheet(
    BuildContext context,
    String title,
    List<String> details, {
    bool showCheckboxes = false,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        List<bool> checked = List.generate(details.length, (index) => false);

        return StatefulBuilder(
          builder:
              (context, setState) => Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ...List.generate(details.length, (index) {
                      return showCheckboxes
                          ? CheckboxListTile(
                            value: checked[index],
                            title: Text(details[index]),
                            controlAffinity: ListTileControlAffinity.leading,
                            onChanged: (val) {
                              setState(() {
                                checked[index] = val!;
                              });
                            },
                          )
                          : ListTile(
                            leading: const Icon(Icons.arrow_right),
                            title: Text(details[index]),
                          );
                    }),
                  ],
                ),
              ),
        );
      },
    );
  }

  void showBudgetAnalysis(BuildContext context) async {
    // Refresh data before showing the modal
    await _loadBudgetData();
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (_) => Padding(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Spending Limits Analysis",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  
                  // Summary cards
                  Row(
                    children: [
                      Expanded(
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              children: [
                                Text(
                                  "\$${totalSpent.toStringAsFixed(0)}",
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red,
                                  ),
                                ),
                                const Text("Total Spent", style: TextStyle(fontSize: 12)),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              children: [
                                Text(
                                  "\$${totalBudget.toStringAsFixed(0)}",
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                                const Text("Total Budget", style: TextStyle(fontSize: 12)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Goals vs Spending Chart
                  buildGoalsVsSpendingChart(),
                  
                  const SizedBox(height: 16),
                  
                  // Goals breakdown
                  buildGoalsBreakdown(),
                ],
              ),
            ),
          ),
    );
  }

  Widget buildGoalsVsSpendingChart() {
    if (goals.isEmpty) {
      return Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Spending vs Limits",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              const Center(
                child: Column(
                  children: [
                    Icon(Icons.bar_chart, size: 48, color: Colors.grey),
                    SizedBox(height: 8),
                    Text(
                      "No spending limits found",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "Create spending limits to see your budget analysis!",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    final categories = goals.map((goal) => goal.category).toList();
    final targets = goals.map((goal) => goal.targetAmount).toList();
    final current = goals.map((goal) => goal.currentAmount).toList();
    
    final maxValue = targets.reduce((a, b) => a > b ? a : b);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Spending vs Limits",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 300,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: maxValue + 50,
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      tooltipBgColor: Colors.blueGrey,
                      tooltipRoundedRadius: 8,
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        if (group.x >= categories.length) return null;
                        final category = categories[group.x];
                        final target = targets[group.x];
                        final spent = current[group.x];
                        final isOver = spent > target;
                        final remaining = target - spent;
                        
                        return BarTooltipItem(
                          '$category\n',
                          const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                          children: [
                            TextSpan(
                              text: 'Limit: \$${target.toStringAsFixed(0)}\n',
                              style: const TextStyle(color: Colors.white, fontSize: 12),
                            ),
                            TextSpan(
                              text: 'Spent: \$${spent.toStringAsFixed(0)}\n',
                              style: TextStyle(
                                color: isOver ? Colors.red : Colors.green,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                            TextSpan(
                              text: isOver 
                                ? 'Over limit by: \$${(spent - target).toStringAsFixed(0)}'
                                : 'Under limit by: \$${remaining.toStringAsFixed(0)}',
                              style: TextStyle(
                                color: isOver ? Colors.red : Colors.green,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() >= categories.length) return const Text('');
                          final label = categories[value.toInt()];
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              label,
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 50,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            '\$${value.toInt()}',
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                      ),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  gridData: FlGridData(
                    show: true,
                    horizontalInterval: maxValue / 5,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: Colors.grey.withOpacity(0.3),
                        strokeWidth: 1,
                      );
                    },
                  ),
                  barGroups: List.generate(categories.length, (index) {
                    final target = targets[index];
                    final spent = current[index];
                    final isOver = spent > target;
                    
                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: spent,
                          color: isOver ? Colors.red : Colors.green,
                          borderRadius: BorderRadius.circular(6),
                          width: 25,
                        ),
                      ],
                    );
                  }),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Legend
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 6),
                const Text("Under Limit", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                const SizedBox(width: 20),
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 6),
                const Text("Over Limit", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
              ],
            ),
            const SizedBox(height: 16),
            // Target indicators
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: List.generate(categories.length, (index) {
                final target = targets[index];
                final spent = current[index];
                final isOver = spent > target;
                final percentage = (spent / target * 100).clamp(0.0, 999.9);
                
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: isOver ? Colors.red.withOpacity(0.1) : Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isOver ? Colors.red : Colors.green,
                      width: 1.5,
                    ),
                  ),
                  child: Text(
                    '${categories[index]}: ${percentage.toStringAsFixed(0)}%',
                    style: TextStyle(
                      fontSize: 11,
                      color: isOver ? Colors.red : Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildGoalsBreakdown() {
    if (goals.isEmpty) {
      return Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Spending Limits Breakdown",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              const Center(
                child: Column(
                  children: [
                    Icon(Icons.analytics, size: 48, color: Colors.grey),
                    SizedBox(height: 8),
                    Text(
                      "No limits to display",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "Create spending limits to track your budget!",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Spending Limits Breakdown",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    "${goals.length} limits",
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.blue,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...goals.map((goal) {
              final progress = goal.progressPercentage;
              final isOver = goal.isOverBudget;
              final remaining = goal.targetAmount - goal.currentAmount;
              
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isOver ? Colors.red.withOpacity(0.05) : Colors.green.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isOver ? Colors.red.withOpacity(0.3) : Colors.green.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(
                          isOver ? Icons.warning : Icons.check_circle,
                          color: isOver ? Colors.red : Colors.green,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            goal.category,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: isOver ? Colors.red.withOpacity(0.1) : Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            "${progress.toStringAsFixed(0)}%",
                            style: TextStyle(
                              color: isOver ? Colors.red : Colors.green,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Limit: \$${goal.targetAmount.toStringAsFixed(0)}",
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            Text(
                              "Spent: \$${goal.currentAmount.toStringAsFixed(0)}",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: isOver ? Colors.red : Colors.green,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              isOver 
                                ? "Over limit by: \$${(goal.currentAmount - goal.targetAmount).toStringAsFixed(0)}"
                                : "Under limit by: \$${remaining.toStringAsFixed(0)}",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: isOver ? Colors.red : Colors.green,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 6,
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: (progress / 100).clamp(0.0, 1.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: isOver ? Colors.red : Colors.green,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
            ),
          ),
    );
  }

  Widget buildBudgetMeter(double spent, double budget) {
    double percent = budget > 0 ? (spent / budget).clamp(0.0, 1.0) : 0.0;
    String level = getLevel(percent);
    Color levelColor = getLevelColor(level);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 4,
      child: Container(
        width: 340,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: levelColor.withOpacity(0.6),
        ),
        child: Column(
          children: [
            const Text(
              "Budget Overview 💰",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            CircularPercentIndicator(
              radius: 80,
              lineWidth: 14,
              percent: percent,
              animation: true,
              animationDuration: 1200,
              circularStrokeCap: CircularStrokeCap.round,
              progressColor: levelColor,
              backgroundColor: Colors.grey.shade200,
              center: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "\$${spent.toStringAsFixed(0)}",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: levelColor,
                    ),
                  ),
                  const Text("Spent"),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: levelColor.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      level,
                      style: TextStyle(
                        color: levelColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "Budget: \$${budget.toStringAsFixed(0)}",
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: Colors.black54,
              ),
            ),
            if (goals.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                "${goals.length} active limits",
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.black54,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String getLevel(double percent) {
    if (percent < 0.5) return "On Track";
    if (percent < 0.8) return "Caution";
    return "Over Budget";
  }

  Color getLevelColor(String level) {
    switch (level) {
      case "On Track":
        return const Color(0xFF6BCB77);
      case "Caution":
        return const Color(0xFF3E5879);
      default:
        return const Color(0xFFE26D5A);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [const Color(0xFF1F3354), const Color(0xFF3E5879)],
            ),
          ),
          child: const Center(
            child: CircularProgressIndicator(color: Colors.white),
          ),
        ),
      );
    }

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [const Color(0xFF1F3354), const Color(0xFF3E5879)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(35),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 16,
                    runSpacing: 16,
                    children: [
                      buildCard(
                        'Low Inventory',
                        Icons.inventory_2,
                        Colors.white,
                        '6 items',
                        'Check milk, rice, oil...',
                        onTap:
                            () => showDetailSheet(context, 'Low Inventory', [
                              'Milk - 1 day left',
                              'Rice - Running low',
                              'Cooking Oil - Refill soon',
                            ]),
                      ),
                      buildCard(
                        "Today's Tasks",
                        Icons.check_circle,
                        Colors.white,
                        '5 tasks',
                        '2 overdue',
                        onTap:
                            () => showDetailSheet(context, "Today's Tasks", [
                              'Clean kitchen',
                              'Buy groceries',
                              'Water plants',
                              'Do laundry',
                              'Call plumber',
                            ], showCheckboxes: true),
                      ),
                      buildCard(
                        'Meal Suggestions',
                        Icons.restaurant,
                        Colors.white,
                        '3 meals',
                        'Based on fridge items',
                        onTap:
                            () => showDetailSheet(context, 'Suggested Meals', [
                              'Pasta with tomato sauce',
                              'Vegetable stir-fry',
                              'Egg & toast breakfast',
                            ]),
                      ),
                      buildCard(
                        'Home Workout',
                        Icons.fitness_center,
                        Colors.white,
                        '3 exercises',
                        '15 min, Cardio, Stretch',
                        onTap:
                            () => showDetailSheet(context, 'Home Workout', [
                              '15 min Full Body Workout',
                              '10 min Cardio Blast',
                              '5 min Guided Stretch',
                            ]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () => showBudgetAnalysis(context),
                    child: buildBudgetMeter(totalSpent, totalBudget),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
