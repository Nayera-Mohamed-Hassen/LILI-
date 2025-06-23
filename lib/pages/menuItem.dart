import 'package:flutter/material.dart';

class MenuItem extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          SizedBox(height: 100),
          GestureDetector(
            onTap: () {
              //Navigator.pushNamed(context, '/menu');
            },
            child: Container(
              width: 330,
              height: 91,
              decoration: ShapeDecoration(
                color: const Color(0xFF3E5879),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: Stack(
                clipBehavior: Clip.none, // ✅ Important fix
                children: [
                  Positioned(
                    left: 8,
                    top: 36,
                    child: SizedBox(
                      width: 313,
                      child: Text(
                        'View Task',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: const Color(0xFFF2F2F2),
                          fontSize: 20,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 251,
                    top: 46,
                    child: Container(
                      width: 70,
                      height: 70,
                      decoration: ShapeDecoration(
                        color: const Color(0xFFF2F2F2),
                        shape: RoundedRectangleBorder(
                          side: BorderSide(
                            width: 3,
                            strokeAlign: BorderSide.strokeAlignCenter,
                            color: const Color(0xFF213555),
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: Stack(),
                    ),
                  ),
                  Positioned(
                    left: 8,
                    top: -19,
                    child: Container(
                      width: 69,
                      height: 69,
                      decoration: ShapeDecoration(
                        color: const Color(0xFFF2F2F2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            left: 0,
                            top: 0,
                            child: Container(
                              width: 70,
                              height: 70,
                              decoration: ShapeDecoration(
                                image: DecorationImage(
                                  image: AssetImage(
                                    'assets/images/LILI_logo.png',
                                  ),
                                  fit: BoxFit.contain,
                                ),
                                shape: RoundedRectangleBorder(
                                  side: BorderSide(
                                    width: 3,
                                    color: const Color(0xFF213555),
                                  ),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
