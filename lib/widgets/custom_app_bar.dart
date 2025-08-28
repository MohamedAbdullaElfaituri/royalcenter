import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool hasTransactions;
  final VoidCallback? onSave;
  final VoidCallback? onClear;

  const CustomAppBar({
    Key? key,
    required this.hasTransactions,
    this.onSave,
    this.onClear,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
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
                    offset: const Offset(1.0, 1.0),
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
                    offset: const Offset(1.0, 1.0),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      centerTitle: true,
      backgroundColor: Colors.teal[700],
      foregroundColor: Colors.white,
      elevation: 8,
      shadowColor: Colors.black.withOpacity(0.6),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(30),
        ),
      ),
      actions: [
        if (hasTransactions) ...[
          // Save button with enhanced styling
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            decoration: BoxDecoration(
              color: Colors.teal[500],
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
              icon: const Icon(Icons.save_rounded, size: 24),
              onPressed: onSave,
              tooltip: 'حفظ السجل اليومي',
              color: Colors.white,
            ),
          ),
          // Clear button with enhanced styling
          Container(
            margin: const EdgeInsets.only(right: 8, top: 8, bottom: 8),
            decoration: BoxDecoration(
              color: Colors.red[400],
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
              icon: const Icon(Icons.delete_rounded, size: 24),
              onPressed: onClear,
              tooltip: 'مسح جميع المعاملات',
              color: Colors.white,
            ),
          ),
        ],
      ],
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.teal[700]!,
              Colors.teal[600]!,
              Colors.teal[700]!,
            ],
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}