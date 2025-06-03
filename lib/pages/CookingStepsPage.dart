import 'package:flutter/material.dart';
import 'package:LILI/pages/navbar.dart';
import 'wave2.dart';

class CookingStepsPage extends StatefulWidget {
  final String image;
  final List<String> steps;

  const CookingStepsPage({required this.image, required this.steps, Key? key})
    : super(key: key);

  @override
  _CookingStepsPageState createState() => _CookingStepsPageState();
}

class _CookingStepsPageState extends State<CookingStepsPage> {
  late List<bool> stepChecked;
  int currentStep = 0;

  @override
  void initState() {
    super.initState();
    stepChecked = List.filled(widget.steps.length, false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: const Color(0xFF1F3354),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    'https://raw.githubusercontent.com/Nayera-Mohamed-Hassen/LILI-/main/FoodImages/${Uri.encodeComponent(widget.image)}',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                  const Positioned(
                    bottom: 16,
                    left: 16,
                    child: Text(
                      'Let\'s Start Cooking!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Progress indicator
                  LinearProgressIndicator(
                    value: stepChecked.where((checked) => checked).length / widget.steps.length,
                    backgroundColor: Colors.grey[200],
                    color: const Color(0xFF1F3354),
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${stepChecked.where((checked) => checked).length}/${widget.steps.length} steps completed',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Steps list
                  ...widget.steps.asMap().entries.map((entry) {
                    final index = entry.key;
                    final step = entry.value;
                    final isChecked = stepChecked[index];
                    
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      elevation: isChecked ? 1 : 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: isChecked ? Colors.green : const Color(0xFF1F3354),
                          width: 1,
                        ),
                      ),
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            stepChecked[index] = !stepChecked[index];
                          });
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: isChecked ? Colors.green : const Color(0xFF1F3354),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: isChecked
                                      ? const Icon(Icons.check, color: Colors.white, size: 20)
                                      : Text(
                                          '${index + 1}',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  step,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: isChecked ? Colors.grey : Colors.black,
                                    decoration: isChecked ? TextDecoration.lineThrough : null,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                stepChecked.every((checked) => checked)
                    ? 'All steps completed! 🎉'
                    : '${widget.steps.length - stepChecked.where((checked) => checked).length} steps remaining',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1F3354),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => Navbar()),
                  (route) => false,
                );
              },
              child: const Text(
                'Finish Cooking',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
