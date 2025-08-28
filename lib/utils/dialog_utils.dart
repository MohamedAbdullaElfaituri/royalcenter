import 'package:flutter/material.dart';
import '../models/wash_transaction.dart';


void showDeleteTransactionDialog({
  required BuildContext context,
  required WashTransaction transaction,
  required Function onDelete,
}) {
  showDialog(
    context: context,
    builder: (context) => Directionality(
      textDirection: TextDirection.rtl,
      child: AlertDialog(
        title: Text('تأكيد الحذف'),
        content: Text('هل تريد حذف معاملة الغسيل رقم ${transaction.transactionNumber}؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              onDelete();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('تم حذف المعاملة بنجاح'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('حذف'),
          ),
        ],
      ),
    ),
  );
}

