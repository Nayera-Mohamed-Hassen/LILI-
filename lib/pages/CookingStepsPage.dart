import 'package:flutter/material.dart';
import 'package:untitled4/pages/navbar.dart';
import 'wave2.dart';
import 'navbar.dart';

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

  @override
  void initState() {
    super.initState();
    stepChecked = List.filled(widget.steps.length, false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: const Color(0xFF1F3354),
        title: const Text(
          'Start Cooking',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Column(
        children: [
          Stack(
            children: [
              ClipPath(
                clipper: WaveClipper(),
                child: Container(height: 200, color: const Color(0xFF1F3354)),
              ),
              Column(
                children: [
                  const SizedBox(height: 80),
                  Center(
                    child: ClipOval(
                      child: Image.asset(
                        widget.image,
                        width: 150,
                        height: 150,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: widget.steps.length,
              itemBuilder: (context, index) {
                final isChecked = stepChecked[index];
                return CheckboxListTile(
                  activeColor: const Color(0xFF1F3354),
                  controlAffinity: ListTileControlAffinity.leading,
                  value: isChecked,
                  onChanged: (value) {
                    setState(() {
                      stepChecked[index] = value!;
                    });
                  },
                  title: AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 200),
                    style: TextStyle(
                      fontSize: 18,
                      color: isChecked ? Colors.grey : Colors.black,
                      decoration: isChecked ? TextDecoration.lineThrough : null,
                    ),
                    child: Text('${index + 1}. ${widget.steps[index]}'),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 20),
          Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1F3354),
                padding: const EdgeInsets.symmetric(
                  horizontal: 52,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Navbar()),
                );
              },
              child: const Text(
                'Done',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}
