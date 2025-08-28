import 'package:flutter/material.dart';

void showClearAllTransactionsDialog({
  required BuildContext context,
  required Function onClear,
}) {
  showDialog(
    context: context,
    builder: (context) => Directionality(
      textDirection: TextDirection.rtl,
      child: AlertDialog(
        title: Text('تأكيد المسح'),
        content: Text('هل أنت متأكد من رغبتك في مسح جميع معاملات اليوم؟ لا يمكن التراجع عن هذا الإجراء.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              onClear();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('تأكيد المسح'),
          ),
        ],
      ),
    ),
  );
}