import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool hasTransactions;
  final VoidCallback? onSave;
  final VoidCallback? onClear;
  final VoidCallback? onLogout;
  final List<Color>? gradientColors;

  const CustomAppBar({
    Key? key,
    required this.hasTransactions,
    this.onSave,
    this.onClear,
    this.onLogout,
    this.gradientColors,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: _buildTitle(),
      centerTitle: true,
      backgroundColor: Colors.transparent,
      elevation: 8,
      foregroundColor: Colors.white,
      shadowColor: Colors.black.withOpacity(0.6),
      shape: _buildAppBarShape(),
      actions: _buildActions(),
      flexibleSpace: _buildBackground(),
    );
  }

  // بناء العنوان مع أيقونة السيارة
  Widget _buildTitle() {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: '🚗 ',
            style: TextStyle(
              fontSize: 28,
              shadows: [
                Shadow(
                  blurRadius: 4.0,
                  color: Colors.black.withOpacity(0.3),
                  offset: const Offset(1, 1),
                ),
              ],
            ),
          ),
          TextSpan(
            text: 'نظام غسيل السيارات',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 22,
              letterSpacing: 0.5,
              shadows: [
                Shadow(
                  blurRadius: 2.0,
                  color: Colors.black.withOpacity(0.2),
                  offset: const Offset(1, 1),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // بناء شكل الـ AppBar
  ShapeBorder _buildAppBarShape() {
    return const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        bottom: Radius.circular(30),
      ),
    );
  }

  // بناء قائمة الأزرار
  List<Widget> _buildActions() {
    final actions = <Widget>[];

    if (hasTransactions) {
      actions.add(
        _buildActionButton(
          icon: Icons.delete_rounded,
          tooltip: 'مسح جميع المعاملات',
          color: Colors.red[400],
          onPressed: onClear,
        ),
      );
    }

    actions.add(_buildLogoutButton());

    return actions;
  }

  // زر تسجيل الخروج
  Widget _buildLogoutButton() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.orange, Colors.redAccent, Colors.pink],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.redAccent.withOpacity(0.6),
            blurRadius: 12,
            spreadRadius: 1,
            offset: const Offset(0, 3),
          ),
          BoxShadow(
            color: Colors.orange.withOpacity(0.3),
            blurRadius: 25,
            spreadRadius: 2,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: IconButton(
        icon: const Icon(Icons.logout_rounded, size: 26),
        tooltip: 'تسجيل الخروج',
        color: Colors.white,
        onPressed: onLogout,
      ),
    );
  }

  // زر إجراء عام
  Widget _buildActionButton({
    required IconData icon,
    required String tooltip,
    required Color? color,
    required VoidCallback? onPressed,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, size: 24),
        onPressed: onPressed,
        tooltip: tooltip,
        color: Colors.white,
      ),
    );
  }

  // بناء الخلفية المتدرجة
  Widget _buildBackground() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors ??
              [
                Colors.teal[700]!,
                Colors.teal[600]!,
                Colors.teal[700]!,
              ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}