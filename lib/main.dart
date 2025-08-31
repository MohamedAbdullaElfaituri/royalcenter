import 'package:flutter/material.dart';
import 'package:royalcenter/pages/dashboard_page.dart';
import 'package:royalcenter/pages/login_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    });
  }

  // دالة لتحديث حالة تسجيل الدخول
  void _updateLoginStatus(bool isLoggedIn) {
    setState(() {
      _isLoggedIn = isLoggedIn;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'منظومة الغسيل الماليّة',
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Cairo',
      ),
      home: Directionality(
        textDirection: TextDirection.rtl,
        child: _isLoggedIn
            ? DashboardPage(onLogout: () => _updateLoginStatus(false))
            : LoginPage(onLogin: () => _updateLoginStatus(true)),
      ),
    );
  }
}