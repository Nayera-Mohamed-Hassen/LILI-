import 'package:flutter/material.dart';
// import 'pages/signing_page.dart';

class SigningPage extends StatelessWidget {
  const SigningPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: ListView(children: [Signing()]));
  }
}

class Signing extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 390,
          height: 824,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(color: const Color(0xFFF2F2F2)),
          child: Stack(
            children: [
              Positioned(
                left: 20,
                top: 198,
                child: Text(
                  'LILI',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: const Color(0xFF213555),
                    fontSize: 64,
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w400,
                    height: 1.20,
                  ),
                ),
              ),
              Positioned(
                left: 38,
                top: 357,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  spacing: 8,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/signup');
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
                        'Sign Up',
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                left: 38,
                top: 435,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  spacing: 8,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/login');
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
                        'Log in',
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
