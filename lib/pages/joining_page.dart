import 'package:flutter/material.dart';

class JoiningPage extends StatelessWidget {
  const JoiningPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      backgroundColor: const Color(0xFFF2F2F2),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(14.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 350,
                height: 200,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(color: const Color(0xFFF2F2F2)),
                child: Stack(
                  children: [
                    Positioned(
                      // left: 10,
                      top: 100,
                      child: Text(
                        'Scan the QR code',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: const Color(0xFF213555),
                          fontSize: 40,
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w400,
                          height: 1.20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Align(
                alignment: Alignment.center,
                child: IconButton(
                  icon: Icon(
                    Icons.camera_alt,
                    size: 30,
                    color: Color(0xFF1D2345),
                  ),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder:
                          (ctx) => AlertDialog(
                            title: Text('Scanning'),
                            content: Text('Scanning the QR code...'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(ctx).pop(),
                                child: Text('OK'),
                              ),
                            ],
                          ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/homepage');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF3E5879),

                  // const Color(0xFF3E5879)
                  minimumSize: Size(315, 55),
                  shape: RoundedRectangleBorder(
                    side: BorderSide(width: 1),
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                child: Text(
                  'Join House',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
