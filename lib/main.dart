import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:LILI/pages/budgetAnalysis.dart';
import 'package:LILI/pages/emergency.dart';
import 'package:LILI/pages/loadingRecipe.dart';
import 'package:LILI/pages/main_menu.dart';
import 'package:LILI/pages/profile.dart';
import 'package:LILI/pages/recipes.dart';
import 'pages/signing_page.dart';
import 'pages/login_page.dart';
import 'pages/signup_page.dart';
import 'pages/hosting_page.dart';
import 'pages/joining_page.dart';
import 'pages/init_setup_page.dart';
import 'pages/forget_password_email_page.dart';
import 'pages/forget_password_reset_page.dart';
import 'pages/add_user_page.dart';
import 'pages/tasks_home_page.dart';
import 'pages/navbar.dart';
import 'pages/create_new_task_page.dart';
import 'pages/create_new_category_page.dart';
import 'pages/loadingRecipe.dart';
import 'pages/inventory_page.dart';
import 'pages/add_new_itemInventory_page.dart';
import 'pages/create_new_categoryInventory_page.dart';
import 'pages/wave2.dart';
import 'pages/budget_page_navbar.dart';
import 'pages/my_card_page.dart';
import 'pages/budget_home_page.dart';
import 'pages/add_new_expenses.dart';
import 'pages/create_new_category_budget.dart';
import 'pages/on_boarding.dart';
import 'pages/google_sign_in_sevice.dart';
import 'pages/host_house.dart';
import 'pages/menuItem.dart';

void main() {
  runApp(LiliApp());
}

class LiliApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LILI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Color(0xFFF2F2F2),
      ),
      initialRoute: '/homepage',
      routes: {
        '/': (context) => OnBoarding(),
        '/menu': (context) => MenuItem(),
        '/analysis': (context) => AnalysisPage(),
        '/WaveClipper': (context) => RecipePage(),
        '/Recipe': (context) => Recipe(),
        '/loadingRecipe': (context) => RecipeLoading(),
        '/homepage': (context) => Navbar(),
        '/mainmenu': (context) => MainMenuPage(),
        '/emergency': (context) => EmergencyPage(),
        '/profile': (context) => ProfilePage(),
        '/signing': (context) => SigningPage(),
        '/login': (context) => LoginPage(),
        '/signup': (context) => SignUpPage(),
        '/hosting': (context) => HostingPage(),
        '/joining': (context) => JoiningPage(),
        '/init setup': (context) => InitSetupPage(),
        '/forget password email': (context) => ForgetPasswordEmailPage(),
        '/forget password reset': (context) => ForgetPasswordResetPage(),
        '/add user': (context) => AddUserPage(),
        '/task home': (context) => TasksHomePage(),
        '/create new task': (context) => CreateNewTaskPage(),
        '/create new category': (context) => CreateNewCategoryPage(),
        '/inventory': (context) => InventoryPage(),
        '/new item inventory': (context) => CreateNewItemPage(),

        '/budget': (context) => BudgetPageNavbar(),
        '/budget home': (context) => BudgetPage(),
        '/my card': (context) => MyCardPage(),
        '/add new expenses': (context) => CreateNewExpensesPage(),
        '/create new category budget':
            (context) => CreateNewCategoryBudgetPage(),
        '/host house': (context) => HostHousePage(),
      },
    );
  }
}

class PrimaryButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;

  const PrimaryButton({required this.onPressed, required this.text, super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ButtonStyle(
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        backgroundColor: MaterialStateProperty.resolveWith<Color>((
          Set<MaterialState> states,
        ) {
          return const Color(0xFF3E5879); // Always use base color
        }),
        overlayColor: MaterialStateProperty.resolveWith<Color>((
          Set<MaterialState> states,
        ) {
          if (states.contains(MaterialState.pressed)) {
            return const Color(0xFF213555); // Darker when pressed
          }
          return Colors.transparent;
        }),
        padding: MaterialStateProperty.all<EdgeInsets>(
          const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      onPressed: onPressed,
      child: Text(
        text,
        style: const TextStyle(color: Color(0xFFF2F2F2)),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class SecondaryButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;

  const SecondaryButton({
    required this.onPressed,
    required this.text,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ButtonStyle(
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        backgroundColor: MaterialStateProperty.all<Color>(
          const Color(0xFFF2F2F2),
        ),
        shadowColor: MaterialStateProperty.all<Color>(Colors.transparent),
        side: MaterialStateProperty.resolveWith<BorderSide>((
          Set<MaterialState> states,
        ) {
          // 5px when pressed, 3px otherwise
          final width = states.contains(MaterialState.pressed) ? 5.0 : 3.0;
          return BorderSide(width: width, color: const Color(0xFF3E5879));
        }),
        padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
          const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
        overlayColor: MaterialStateProperty.all<Color>(Colors.transparent),
      ),
      onPressed: onPressed,
      child: Text(
        text,
        style: const TextStyle(color: Color(0xFF3E5879)),
        textAlign: TextAlign.center,
      ),
    );
  }
}
