import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:LILI/services/task_service.dart';
import 'package:LILI/models/task.dart';
import 'package:LILI/models/expense_goal.dart';
import 'package:LILI/services/expense_goal_service.dart';
import 'package:LILI/services/transaction_service.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
  List<dynamic> lowInventoryItems = [];

  @override
  void initState() {
    super.initState();
    _loadBudgetData();
    _fetchLowInventory();
  }

  Future<void> _loadBudgetData() async {
    setState(() => _isLoading = true);
    try {
      // Load expense goals
      final loadedGoals = await ExpenseGoalService.getExpenseGoalsWithProgress(
        widget.userId,
      );

      // Load recent transactions to calculate current spending
      final transactions = await TransactionService.getTransactions(
        widget.userId,
      );

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
      setState(() {
        goals = [];
        categorySpending = {};
        totalSpent = 0.0;
        totalBudget = 0.0;
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchLowInventory() async {
    final userId = widget.userId;
    if (userId == null || userId.isEmpty) return;
    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:8000/user/inventory/get-items'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"user_id": userId}),
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final List<dynamic> lowItems =
            data.where((item) {
          // Use the same low stock logic as inventory_page.dart
          final String category = item['category'] ?? '';
          final int quantity = item['quantity'] ?? 0;
          final double amount = (item['amount'] ?? 1.0).toDouble();
          final String unit = (item['unit'] ?? 'pieces').toLowerCase();
          if (category != 'Food') return false;
          switch (unit) {
            case 'kg':
            case 'kilograms':
              return quantity * amount < 0.5;
            case 'l':
            case 'liters':
            case 'litres':
              return quantity * amount < 0.5;
            case 'g':
            case 'grams':
              return quantity * amount < 100;
            case 'ml':
            case 'milliliters':
              return quantity * amount < 100;
            case 'pieces':
            case 'pcs':
            case 'units':
              return quantity <= 1;
            case 'packets':
            case 'packs':
              return quantity <= 1;
            case 'bottles':
            case 'cans':
              return quantity <= 1;
            default:
              return quantity <= 1;
          }
        }).toList();
        setState(() {
          lowInventoryItems = lowItems;
        });
      }
    } catch (e) {
      print('Error fetching inventory: $e');
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
      borderRadius: BorderRadius.circular(24),
      child: SizedBox(
        width: 340,
        height: 300,
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          elevation: 10,
          shadowColor: color.withOpacity(0.18),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(0.95),
                  color.withOpacity(0.08),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.10),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Icon(icon, size: 38, color: color),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1F3354),
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 13, color: Colors.black54),
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
      backgroundColor: Colors.white,
      builder: (context) {
        List<bool> checked = List.generate(details.length, (index) => false);
        return Padding(
          padding: const EdgeInsets.only(top: 0, left: 0, right: 0, bottom: 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
              Container(
                decoration: const BoxDecoration(
                  color: Color(0xFF3E5879),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
                child: Row(
                  children: const [
                    Icon(Icons.inventory_2, color: Colors.white, size: 28),
                    SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        'Low Inventory',
                        style: TextStyle(
                          color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: details.isEmpty || (details.length == 1 && details[0].contains('No low inventory'))
                    ? const Center(
                        child: Text(
                          'No low inventory items!',
                          style: TextStyle(fontSize: 16, color: Color(0xFF1F3354)),
                        ),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ...List.generate(details.length, (index) {
                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                              decoration: BoxDecoration(
                                color: const Color(0xFF3E5879).withOpacity(0.07),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.arrow_right, color: Color(0xFF3E5879)),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      details[index],
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: Color(0xFF1F3354),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                          );
                    }),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3E5879),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Close', style: TextStyle(fontSize: 16, color: Colors.white)),
                ),
              ),
            ],
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
      backgroundColor: const Color(0xFF1F3354),
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
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        "Spending Limits Analysis",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Summary cards
                  Row(
                    children: [
                      Expanded(
                        child: Card(
                          color: const Color(0xFF3E5879),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
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
                                const Text(
                                  "Total Spent",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Card(
                          color: const Color(0xFF3E5879),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
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
                                const Text(
                                  "Total Budget",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.white,
                                  ),
                                ),
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
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
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
                          const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                          children: [
                            TextSpan(
                              text: 'Limit: \$${target.toStringAsFixed(0)}\n',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
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
                              text:
                                  isOver
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
                          if (value.toInt() >= categories.length)
                            return const Text('');
                          final label = categories[value.toInt()];
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              label,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
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
                const Text(
                  "Under Limit",
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                ),
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
                const Text(
                  "Over Limit",
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                ),
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color:
                        isOver
                            ? Colors.red.withOpacity(0.1)
                            : Colors.green.withOpacity(0.1),
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
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
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
                  color:
                      isOver
                          ? Colors.red.withOpacity(0.05)
                          : Colors.green.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color:
                        isOver
                            ? Colors.red.withOpacity(0.3)
                            : Colors.green.withOpacity(0.3),
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
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color:
                                isOver
                                    ? Colors.red.withOpacity(0.1)
                                    : Colors.green.withOpacity(0.1),
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
                style: const TextStyle(fontSize: 12, color: Colors.black54),
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
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF1F3354), Color(0xFF3E5879)],
            ),
          ),
          child: const Center(
            child: CircularProgressIndicator(color: Colors.white),
          ),
        ),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
                colors: [Color(0xFF1F3354), Color(0xFF3E5879)],
          ),
        ),
          ),
          SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(35),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),
                  Column(
                    children: [
                      buildCard(
                        'Low Inventory',
                        Icons.inventory_2,
                        const Color(0xFF3E5879),
                        '${lowInventoryItems.length} items',
                        lowInventoryItems.isNotEmpty
                            ? 'Check: ${lowInventoryItems.take(3).map((item) => item['name']).join(', ')}${lowInventoryItems.length > 3 ? ', ...' : ''}'
                            : 'All good!',
                        onTap: () => showDetailSheet(
                          context,
                          'Low Inventory',
                          lowInventoryItems.isNotEmpty
                                ? lowInventoryItems
                                    .map<String>((item) => item['name'])
                                    .toList()
                              : ['No low inventory items!'],
                        ),
                      ),
                        const SizedBox(height: 30),
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
        ],
      ),
    );
  }
}
