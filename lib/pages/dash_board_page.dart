import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:LILI/services/task_service.dart';
import 'package:LILI/models/task.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:fl_chart/fl_chart.dart';

class ReportDashboard extends StatelessWidget {
  const ReportDashboard({super.key});

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

  void showBudgetAnalysis(BuildContext context) {
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
                    "Detailed Budget Analysis",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  const ListTile(
                    leading: Icon(Icons.pie_chart),
                    title: Text("Spent: \$250"),
                    subtitle: Text("You're at 50% of your budget."),
                  ),
                  const ListTile(
                    leading: Icon(Icons.trending_up),
                    title: Text("Spending Trend"),
                    subtitle: Text("This week: +\$50 compared to last week"),
                  ),
                  const ListTile(
                    leading: Icon(Icons.lightbulb),
                    title: Text("Tip"),
                    subtitle: Text("Cut back on non-essential groceries."),
                  ),
                  const SizedBox(height: 16),
                  buildSpendingChart(), // ✅ Add the bar chart here
                ],
              ),
            ),
          ),
    );
  }

  Widget buildBudgetMeter(double spent, double budget) {
    double percent = (spent / budget).clamp(0.0, 1.0);
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
          ],
        ),
      ),
    );
  }

  Widget buildSpendingChart() {
    final categories = {
      'Food': 200.0,
      'Cleaning': 100.0,
      'Utilities': 150.0,
      'Transport': 80.0,
      'Entertainment': 60.0,
    };

    final maxValue = categories.values.reduce((a, b) => a > b ? a : b);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Most Spent Categories",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: maxValue + 50,
                  barTouchData: BarTouchData(enabled: false),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final label = categories.keys.elementAt(
                            value.toInt(),
                          );
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              label,
                              style: const TextStyle(fontSize: 12),
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
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
                  barGroups: List.generate(categories.length, (index) {
                    final category = categories.entries.elementAt(index);
                    final isHighest = category.value == maxValue;
                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: category.value,
                          color: isHighest ? Colors.red : Colors.blueGrey,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ],
                    );
                  }),
                ),
              ),
            ),
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
                    child: buildBudgetMeter(250, 500),
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
