import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool hasTransactions; // هل توجد معاملات حالية
  final VoidCallback? onSave; // حدث عند الضغط على زر الحفظ
  final VoidCallback? onClear; // حدث عند الضغط على زر المسح
  final List<Color>? gradientColors; // ألوان الخلفية (يمكن تخصيصها)

  const CustomAppBar({
    Key? key,
    required this.hasTransactions,
    this.onSave,
    this.onClear,
    this.gradientColors, // لو ما انمررت، يستخدم ألوان افتراضية
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      // ====== العنوان مع أيقونة السيارة ======
      title: RichText(
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
      ),
      centerTitle: true,
      backgroundColor: Colors.transparent, // نجعلها شفافة مع Gradient
      elevation: 8,
      foregroundColor: Colors.white,
      shadowColor: Colors.black.withOpacity(0.6),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(30),
        ),
      ),

      // ====== الأزرار (الحفظ و المسح) ======
      actions: [
        if (hasTransactions) ...[
          // زر الحفظ
          _buildActionButton(
            icon: Icons.save_rounded,
            tooltip: 'حفظ السجل اليومي',
            color: Colors.teal[500],
            onPressed: onSave,
          ),
          // زر المسح
          _buildActionButton(
            icon: Icons.delete_rounded,
            tooltip: 'مسح جميع المعاملات',
            color: Colors.red[400],
            onPressed: onClear,
          ),
        ],
      ],

      // ====== خلفية متدرجة ======
      flexibleSpace: Container(
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
      ),
    );
  }

  // دالة مساعدة لبناء زر في الـ AppBar
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

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
