import 'package:LILI/user_session.dart';
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
import 'pages/verify_code_page.dart';
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
import 'pages/my_card_page.dart';
import 'pages/add_new_expenses.dart';
import 'pages/create_new_category_budget.dart';
import 'pages/on_boarding.dart';
import 'pages/host_house.dart';
import 'pages/menuItem.dart';
import 'pages/RecipeNavBar.dart';
import 'pages/dash_board_page.dart';
import 'pages/expenses_page.dart';
import 'package:provider/provider.dart';
import 'package:LILI/services/task_service.dart';
import 'new Lib/views/screens/calendar_screen.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Check for persistent login
  final prefs = await SharedPreferences.getInstance();
  final userId = prefs.getString('user_id');
  final houseId = prefs.getString('house_id');
  final username = prefs.getString('username');
  final name = prefs.getString('name');
  if (userId != null && userId.isNotEmpty) {
    UserSession().setUserId(userId);
    if (houseId != null) {
      UserSession().setHouseId(houseId);
    }
    if (username != null) {
      UserSession().setUsername(username);
    }
    if (name != null) {
      UserSession().setName(name);
    }
  }

  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => TaskService())],
      child: LiliApp(isLoggedIn: userId != null && userId.isNotEmpty),
    ),
  );
}

class LiliApp extends StatelessWidget {
  final bool isLoggedIn;

  LiliApp({this.isLoggedIn = false});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'LILI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Color(0xFFF2F2F2),
      ),
      initialRoute: isLoggedIn ? '/homepage' : '/',
      routes: {
        '/': (context) => OnBoarding(),
        '/menu': (context) => MenuItem(),
        '/analysis': (context) => AnalysisPage(),
        // '/WaveClipper': (context) => RecipePage(),
        '/Recipe': (context) => RecipeNavbar(),
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
        //'/init setup': (context) => InitSetupPage(),
        '/forget password email': (context) => ForgetPasswordEmailPage(),
        '/verify code': (context) {
          final email = ModalRoute.of(context)?.settings.arguments as String?;
          return VerifyCodePage(email: email ?? '');
        },
        '/forget password reset': (context) => ForgetPasswordResetPage(),
        '/add user': (context) => AddUserPage(),
        '/task home': (context) => TasksHomePage(),
        //  '/create new task': (context) => CreateNewTaskPage(),
        '/create new category': (context) => CreateNewCategoryPage(),
        '/inventory': (context) => InventoryPage(),
        '/new item inventory': (context) => CreateNewItemPage(),
        '/my card': (context) => MyCardPage(),
        '/add new expenses': (context) => CreateNewExpensesPage(),
        '/create new category budget':
            (context) => CreateNewCategoryBudgetPage(),
        '/host house': (context) => HostHousePage(),
        '/dash board ':
            (context) =>
                ReportDashboard(userId: UserSession().getUserId().toString()),
        '/Expenses ':
            (context) =>
                ExpensesPage(userId: UserSession().getUserId().toString()),
        '/family_calendar': (context) => CalendarScreen(),
      },
    );
  }
}

//primary button
class PrimaryButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;
  final double width;
  final double height;

  const PrimaryButton({
    required this.onPressed,
    required this.text,
    this.width = 0,
    this.height = 0,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    Widget button = ElevatedButton(
      style: ButtonStyle(
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        backgroundColor: MaterialStateProperty.resolveWith<Color>((_) {
          return const Color(0xFF3E5879);
        }),
        overlayColor: MaterialStateProperty.resolveWith<Color>((states) {
          if (states.contains(MaterialState.pressed)) {
            return const Color(0xFF213555);
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
        style: const TextStyle(color: Color(0xFFF2F2F2), fontSize: 24),
        textAlign: TextAlign.center,
      ),
    );

    // Wrap with SizedBox only if width or height > 0
    if (width > 0 || height > 0) {
      button = SizedBox(
        width: width > 0 ? width : null,
        height: height > 0 ? height : null,
        child: button,
      );
    }

    return button;
  }
}

//secondary button
class SecondaryButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;
  final double width;
  final double height;

  const SecondaryButton({
    required this.onPressed,
    required this.text,
    this.width = 0,
    this.height = 0,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    Widget button = ElevatedButton(
      style: ButtonStyle(
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        backgroundColor: MaterialStateProperty.all<Color>(
          const Color(0xFFF2F2F2),
        ),
        shadowColor: MaterialStateProperty.all<Color>(Colors.transparent),
        side: MaterialStateProperty.resolveWith<BorderSide>((states) {
          final sideWidth = states.contains(MaterialState.pressed) ? 5.0 : 3.0;
          return BorderSide(width: sideWidth, color: const Color(0xFF3E5879));
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

    if (width > 0 || height > 0) {
      button = SizedBox(
        width: width > 0 ? width : null,
        height: height > 0 ? height : null,
        child: button,
      );
    }

    return button;
  }
}
