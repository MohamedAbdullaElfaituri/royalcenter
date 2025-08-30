import 'package:flutter/material.dart';
import 'package:royalcenter/pages/dashboard_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'pages/login_page.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // تحميل البيانات المحفوظة
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

  runApp(MyApp(isLoggedIn: isLoggedIn));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  const MyApp({super.key, required this.isLoggedIn});

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
        child: isLoggedIn ?  DashboardScreen() : const LoginPage(),
      ),
    );
  }
}
