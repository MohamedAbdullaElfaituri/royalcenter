import 'package:flutter/material.dart';

import '../models/wash_transaction.dart';


void showDeleteTransactionDialog({
  required BuildContext context,
  required WashTransaction transaction,
  required List<WashTransaction> transactions,
  required VoidCallback onUpdate,
}) {
  showDialog(
    context: context,
    builder: (context) => Directionality(
      textDirection: TextDirection.rtl,
      child: AlertDialog(
        title: Text('حذف المعاملة'),
        content: Text('هل أنت متأكد من رغبتك في حذف هذه المعاملة؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              transactions.remove(transaction); // listeyi dışarıdan aldık
              onUpdate(); // örneğin setState() veya filtreleme fonksiyonu çağrılır
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('تم حذف المعاملة'),
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
