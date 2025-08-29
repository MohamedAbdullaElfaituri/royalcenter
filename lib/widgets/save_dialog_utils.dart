import 'package:flutter/material.dart';

class SaveDialogUtils {
  // عنصر صف يُظهر أيقونة + عنوان + قيمة
  static Widget buildSaveDialogItem({
    required IconData icon,           // الأيقونة
    required String title,            // العنوان
    required String value,            // القيمة
    required Color primaryColor,      // اللون الأساسي
    required Color secondaryColor,    // اللون الثانوي
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: primaryColor),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: secondaryColor,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  // عنصر صف يُظهر نوع الغسيل مع العدد
  static Widget buildWashTypeItem(
      String name,
      int count,
      Color color,
      Color primaryColor
      ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          // دائرة ملونة لتمييز النوع
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '• $name: ',
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          Text(
            '$count',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: primaryColor,
            ),
          ),
        ],
      ),
    );
  }
}
