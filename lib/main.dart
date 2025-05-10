import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:untitled4/pages/budgetAnalysis.dart';
import 'package:untitled4/pages/emergency.dart';
import 'package:untitled4/pages/loadingRecipe.dart';
import 'package:untitled4/pages/main_menu.dart';
import 'package:untitled4/pages/profile.dart';
import 'package:untitled4/pages/recipes.dart';
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
      initialRoute: '/',
      routes: {
        '/': (context) => OnBoarding(),
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
        '/new category inventory':
            (context) => CreateNewCategoryInventoryPage(),
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