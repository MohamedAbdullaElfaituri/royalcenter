import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../pages/dashboard_page.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> with TickerProviderStateMixin {
  // حقول الإدخال
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  // مفتاح التحقق من صحة النموذج
  final _formKey = GlobalKey<FormState>();

  // للتحكم في أنيميشن زر الدخول
  late AnimationController _buttonController;

  // حالات واجهة تسجيل الدخول
  bool _isLoading = false;     // جاري التحميل
  bool _loginSuccess = false;  // نجاح تسجيل الدخول
  bool _obscurePassword = true; // إخفاء كلمة المرور
  bool _rememberMe = false;    // خيار "تذكرني"

  @override
  void initState() {
    super.initState();
    _buttonController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _loadSavedCredentials(); // تحميل بيانات المستخدم إذا سبق أن اختار "تذكرني"
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _buttonController.dispose();
    super.dispose();
  }

  // 🔹 تحميل بيانات الاعتماد من SharedPreferences
  Future<void> _loadSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final savedRemember = prefs.getBool('rememberMe') ?? false;

    if (savedRemember) {
      setState(() {
        _rememberMe = true;
        _usernameController.text = prefs.getString('username') ?? '';
        _passwordController.text = prefs.getString('password') ?? '';
      });
    }
  }

  // 🔹 حفظ بيانات المستخدم إذا فعّل "تذكرني"
  Future<void> _saveCredentials(String username, String password) async {
    final prefs = await SharedPreferences.getInstance();
    if (_rememberMe) {
      await prefs.setBool('rememberMe', true);
      await prefs.setString('username', username);
      await prefs.setString('password', password);
    } else {
      await prefs.remove('rememberMe');
      await prefs.remove('username');
      await prefs.remove('password');
    }
  }

  // 🔹 التحقق من صحة النموذج ومحاولة تسجيل الدخول
  Future<bool> _submit() async {
    if (!_formKey.currentState!.validate()) return false;

    // بدء أنيميشن زر التحميل
    _buttonController.forward();

    // محاكاة طلب سيرفر (شبكة)
    await Future.delayed(const Duration(seconds: 2));

    // تحقق من اسم المستخدم وكلمة المرور (ثابتة هنا للتجربة)
    final ok = _usernameController.text.trim() == 'admin' &&
        _passwordController.text == '123456';

    if (ok) {
      setState(() {
        _loginSuccess = true;
      });

      // حفظ بيانات الدخول إذا اختار المستخدم "تذكرني"
      await _saveCredentials(
        _usernameController.text.trim(),
        _passwordController.text,
      );

      // تأخير بسيط لإظهار نجاح الدخول
      await Future.delayed(const Duration(milliseconds: 700));

      if (!mounted) return true;
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 900),
          pageBuilder: (_, __, ___) => Directionality(
            textDirection: TextDirection.rtl,
            child: DashboardScreen(),
          ),
        ),
      );
      return true;
    } else {
      // في حال فشل الدخول
      setState(() {
        _isLoading = false;
      });
      _buttonController.reverse();
      _showErrorSnack('اسم المستخدم أو كلمة المرور غير صحيحتين');
      return false;
    }
  }

  // 🔹 إظهار رسالة خطأ
  void _showErrorSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // 🔹 إظهار رسالة عادية (معلومة)
  void _showInfo(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // 🔹 الضغط على زر "تسجيل الدخول"
  void _handleLogin() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final success = await _submit();

      if (!success && mounted) {
        setState(() {
          _isLoading = false;
        });
        _buttonController.reverse();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _buttonController.reverse();
        _showErrorSnack('حدث خطأ غير متوقع: ${e.toString()}');
      }
    }
  }

  // 🔹 نافذة استعادة كلمة المرور
  void _showForgotPasswordDialog() {
    showDialog(
      context: context,
      builder: (ctx) {
        final emailCtrl = TextEditingController();
        return Dialog(
          backgroundColor: Colors.white.withOpacity(0.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'استعادة كلمة المرور',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade800,
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: emailCtrl,
                  decoration: InputDecoration(
                    labelText: 'أدخل اسم المستخدم أو البريد الإلكتروني',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('إلغاء'),
                    ),
                    FilledButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        _showInfo('تم إرسال رابط الاستعادة إلى بريدك الإلكتروني');
                      },
                      child: const Text('إرسال'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
      child: Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 30,
              offset: const Offset(0, 15),
            ),
          ],
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 🔹 العنوان الرئيسي
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.lock_outline,
                      size: 32, color: Colors.blue.shade200),
                  const SizedBox(width: 12),
                  Text(
                    'تسجيل الدخول',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 24,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              Text(
                'أدخل بياناتك للوصول إلى النظام',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 24),

              // 🔹 حقل اسم المستخدم
              TextFormField(
                controller: _usernameController,
                textInputAction: TextInputAction.next,
                style: TextStyle(color: Colors.white.withOpacity(0.95)),
                decoration: InputDecoration(
                  labelText: 'اسم المستخدم',
                  labelStyle: TextStyle(color: Colors.white.withOpacity(0.8)),
                  prefixIcon:
                  Icon(Icons.person_outline, color: Colors.blue.shade200),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'من فضلك أدخل اسم المستخدم'
                    : null,
              ),

              const SizedBox(height: 16),

              // 🔹 حقل كلمة المرور
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                textInputAction: TextInputAction.done,
                style: TextStyle(color: Colors.white.withOpacity(0.95)),
                decoration: InputDecoration(
                  labelText: 'كلمة المرور',
                  labelStyle: TextStyle(color: Colors.white.withOpacity(0.8)),
                  prefixIcon:
                  Icon(Icons.key_rounded, color: Colors.blue.shade200),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: Colors.white.withOpacity(0.7),
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'من فضلك أدخل كلمة المرور';
                  if (v.length < 6) {
                    return 'كلمة المرور يجب أن تكون 6 أحرف أو أكثر';
                  }
                  return null;
                },
                onFieldSubmitted: (_) => _handleLogin(),
              ),

              const SizedBox(height: 20),

              // 🔹 رابط "نسيت كلمة المرور"
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: _showForgotPasswordDialog,
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.blue.shade200,
                  ),
                  child: const Text('نسيت كلمة المرور؟'),
                ),
              ),

              const SizedBox(height: 16),

              // 🔹 زر تسجيل الدخول
              SizedBox(
                height: 56,
                child: AnimatedBuilder(
                  animation: _buttonController,
                  builder: (context, child) {
                    final t = _buttonController.value;
                    final widthFactor = 1.0 - (t * 0.4);
                    return FractionallySizedBox(
                      widthFactor: widthFactor,
                      child: child,
                    );
                  },
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade700,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: _isLoading ? null : _handleLogin,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 400),
                      child: _isLoading
                          ? SizedBox(
                        height: 28,
                        width: 28,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          color: Colors.white.withOpacity(0.95),
                        ),
                      )
                          : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (_loginSuccess) ...[
                            const Icon(Icons.check_circle_outline,
                                color: Colors.white),
                            const SizedBox(width: 8),
                          ],
                          Text(
                            _loginSuccess
                                ? 'تم الدخول'
                                : 'دخول إلى النظام',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_forward, size: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // 🔹 خيار "تذكرني"
              Row(
                children: [
                  Checkbox(
                    value: _rememberMe,
                    onChanged: (value) {
                      setState(() {
                        _rememberMe = value ?? false;
                      });
                    },
                    fillColor: MaterialStateProperty.all(Colors.blue.shade700),
                    checkColor: Colors.white,
                  ),
                  const Text('تذكرني على هذا الجهاز',
                      style: TextStyle(color: Colors.white70)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
