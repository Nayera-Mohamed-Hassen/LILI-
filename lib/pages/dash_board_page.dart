import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';

class ReportDashboard extends StatelessWidget {
  const ReportDashboard({super.key});

  Widget buildCard(
    String title,
    IconData icon,
    Color color,
    String value,
    String subtitle,
  ) {
    return SizedBox(
      width: 160,
      height: 160, // 👈 Set a fixed height too!
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 4,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: color.withOpacity(0.4),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween, // 👈 Even spacing
            children: [
              Icon(icon, size: 28, color: color),
              Text(
                value,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
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

  String getLevel(double percent) {
    if (percent < 0.5) return "On Track";
    if (percent < 0.8) return "Caution";
    return "Over Budget";
  }

  Color getLevelColor(String level) {
    switch (level) {
      case "On Track":
        return const Color(0xFF6BCB77); // Green
      case "Caution":
        return const Color(0xFF3E5879); // Yellow
      default:
        return const Color(0xFFE26D5A); // Red
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox.expand(
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                'assets/backgrounds/homepage.png',
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: EdgeInsets.all(36),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 40),
                    Wrap(
                      alignment:
                          WrapAlignment
                              .center, // 👈 This centers the items horizontally

                      spacing: 16,
                      runSpacing: 16,
                      children: [
                        buildCard(
                          'Low Inventory',
                          Icons.inventory_2,
                          Color(0xFF3E5879),
                          '6 items',
                          'Check milk, rice, oil...',
                        ),
                        buildCard(
                          'Today\'s Tasks',
                          Icons.check_circle,
                          Color(0xFF3E5879),
                          '5 tasks',
                          '2 overdue',
                        ),
                        buildCard(
                          'Meal Suggestions',
                          Icons.restaurant,
                          Color(0xFF3E5879),
                          '3 meals',
                          'Based on fridge items',
                        ),
                        buildCard(
                          'Workout Progress',
                          Icons.fitness_center,
                          Color(0xFF3E5879),
                          '70%',
                          '3/5 completed',
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    buildBudgetMeter(
                      250,
                      500,
                    ), // ← 👈 budget visualization here
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
