import 'package:flutter/material.dart';
import 'package:flutter_onboarding_slider/flutter_onboarding_slider.dart';

class OnBoarding extends StatelessWidget {
  const OnBoarding({super.key});

  @override
  Widget build(BuildContext context) {
    return OnBoardingSlider(
      headerBackgroundColor: Colors.white,
      pageBackgroundColor: Color(0xFFF2F2F2),
      finishButtonText: 'lets get started',
      finishButtonStyle: FinishButtonStyle(
        backgroundColor: Color(0xFF3E5879),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
          side: BorderSide(width: 1),
        ),
        foregroundColor: Colors.white,
        elevation: 5,
      ),
      onFinish: () {
        Navigator.pushNamed(
          context,
          '/signing',
        ); // or whatever your route name is
      },
      controllerColor: Color(0xFF3E5879), // Active dot color
      // indicatorColor: Colors.grey, // Inactive dot color
      skipTextButton: const Text(
        'Skip',
        style: TextStyle(color: Colors.grey, fontSize: 20),
      ),

      // trailing: const Text(
      //   'Login',
      //   style: TextStyle(
      //     color: Color(0xFF1D2345),
      //     fontWeight: FontWeight.bold,
      //     fontSize: 20,
      //   ),
      // ),
      background: [
        Center(
          child: SizedBox(
            height: 490,
            width: 430,
            child: Image.asset(
              'assets/images/LILI_logo.png',
              fit: BoxFit.contain,
            ),
          ),
        ),
        Center(
          child: SizedBox(
            height: 490,
            width: 430,
            child: Image.asset('assets/images/Task.png', fit: BoxFit.contain),
          ),
        ),
        Center(
          child: SizedBox(
            height: 490,
            width: 430,
            child: Image.asset(
              'assets/images/inventory tracking.png',
              fit: BoxFit.contain,
            ),
          ),
        ),
        Center(
          child: SizedBox(
            height: 490,
            width: 430,
            child: Image.asset(
              'assets/images/meal planning.png',
              fit: BoxFit.contain,
            ),
          ),
        ),
        Center(
          child: SizedBox(
            height: 490,
            width: 430,
            child: Image.asset('assets/images/Task.png', fit: BoxFit.contain),
          ),
        ),
      ],
      totalPage: 5,
      speed: 1.5,
      pageBodies: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: const [
              SizedBox(height: 430),
              Text(
                'Welcome to LILI!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 35,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1D2345),
                ),
              ),
              SizedBox(height: 15),
              Text(
                'Your smart home inventory assistant.\nManage groceries, track expiry dates,\nand never forget to restock!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 19, color: Color(0xFF213555)),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: const [
              SizedBox(height: 430),
              Text(
                'Stay On Top of Tasks!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 35,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1D2345),
                ),
              ),
              SizedBox(height: 15),
              Text(
                'Assign chores, set reminders, and keep your household organized with effortless task tracking.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 19, color: Color(0xFF213555)),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: const [
              SizedBox(height: 430),
              Text(
                'Know What You Have !',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 35,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1D2345),
                ),
              ),
              SizedBox(height: 15),
              Text(
                'Track what is in your fridge and pantry. Get alerts before items expire and avoid overbuying.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 19, color: Color(0xFF213555)),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: const [
              SizedBox(height: 430),
              Text(
                'Cook With What You Have !',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 35,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1D2345),
                ),
              ),
              SizedBox(height: 15),
              Text(
                'Not sure what to make? LILI suggests meals based on your available ingredients.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 19, color: Color(0xFF213555)),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: const [
              SizedBox(height: 430),
              Text(
                'Smart Spending, Happy Wallet !',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 35,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1D2345),
                ),
              ),
              SizedBox(height: 15),
              Text(
                'Monitor your grocery spending, get budget insights, and save money without the hassle.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 19, color: Color(0xFF213555)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
