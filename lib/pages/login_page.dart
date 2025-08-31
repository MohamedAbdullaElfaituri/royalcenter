import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:royalcenter/pages/dashboard_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/animated_background.dart';
import '../widgets/left_panel.dart';
import '../widgets/login_form.dart';

class LoginPage extends StatefulWidget {
  final VoidCallback onLogin;
  const LoginPage({super.key, required this.onLogin});

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
      if (mounted){
      _cardController.forward();}
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

    // إخطار التطبيق الرئيسي بتحديث حالة تسجيل الدخول
    widget.onLogin();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // 🔹 خلفية بتدرج أزرق
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0D47A1), Color(0xFF1976D2)],
                // أزرق غامق إلى فاتح
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
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
                          CurvedAnimation(
                              parent: _cardController,
                              curve: Curves.easeOut
                          ),
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
                          CurvedAnimation(
                              parent: _cardController,
                              curve: Curves.easeOut
                          ),
                        ),
                        // 🔹 مررت callback مع onLoginSuccess
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