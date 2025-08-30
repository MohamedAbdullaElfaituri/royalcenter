import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:royalcenter/pages/dashboard_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/animated_background.dart';
import '../widgets/left_panel.dart' hide LeftPanel;
import '../widgets/login_form.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  late AnimationController _cardController;

  @override
  void initState() {
    super.initState();

    _cardController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    // فتح animation عند بداية الصفحة
    Timer(const Duration(milliseconds: 300), () {
      _cardController.forward();
    });
  }

  @override
  void dispose() {
    _cardController.dispose();
    super.dispose();
  }

  // 🔹 دالة لتخزين حالة تسجيل الدخول
  Future<void> _onLoginSuccess() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) =>  DashboardScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // خلفية متدرجة متحركة
          const AnimatedBackground(),

          // نقاط ضوئية متحركة
          Positioned.fill(
            child: IgnorePointer(
              child: Align(
                alignment: Alignment.topCenter,
                child: Opacity(
                  opacity: 0.15,
                  child: ImageFiltered(
                    imageFilter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
                    child: const Icon(Icons.local_car_wash_rounded, size: 420),
                  ),
                ),
              ),
            ),
          ),

          // المحتوى
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 820),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // بطاقة اليسار: شعار/نص توضيحي
                    Expanded(
                      flex: 5,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0.3, 0),
                          end: Offset.zero,
                        ).animate(
                          CurvedAnimation(parent: _cardController, curve: Curves.easeOut),
                        ),
                        child: const LeftPanel(),
                      ),
                    ),

                    const SizedBox(width: 24),

                    // بطاقة اليمين: نموذج الدخول
                    Expanded(
                      flex: 6,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(-0.3, 0),
                          end: Offset.zero,
                        ).animate(
                          CurvedAnimation(parent: _cardController, curve: Curves.easeOut),
                        ),
                        // 🔹 هنا مررت callback
                        child: LoginForm(onLoginSuccess: _onLoginSuccess),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
