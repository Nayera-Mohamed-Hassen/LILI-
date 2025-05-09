import 'package:flutter/material.dart';
import 'package:untitled4/pages/emergency.dart';
import 'package:untitled4/pages/loadingRecipe.dart';
import 'package:untitled4/pages/main_menu.dart';
import 'package:untitled4/pages/profile.dart';
import 'package:untitled4/pages/recipes.dart';
import 'pages/signing_page.dart';
import 'pages/login_page.dart';
import 'pages/broadcast_page.dart';
import 'pages/signup_page.dart';
import 'pages/hosting_page.dart';
import 'pages/joining_page.dart';
import 'pages/init_setup_page.dart';
import 'pages/forget_password_email_page.dart';
import 'pages/forget_password_reset_page.dart';
import 'pages/login_with_face_id_page.dart';
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


import 'package:http/http.dart' as http;



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
        scaffoldBackgroundColor: Color(0xFFF5EFE7), // beige background
      ),
      initialRoute: '/homepage',
      routes: {
        '/': (context) => BroadcastPage(),
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
        '/login with face id ': (context) => LoginWithFaceIDPage(),
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
      },
    );
  }
}
void fetchData() async {
  final response = await http.get(Uri.parse('http://10.0.2.2:8000/')); // Use this for the Android emulator
  if (response.statusCode == 200) {
    print('Response: ${response.body}');
  } else {
    print('Request failed with status: ${response.statusCode}.');
  }
}

