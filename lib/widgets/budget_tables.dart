import 'package:flutter/material.dart';

class BudgetTables {
  // دالة ثابتة لإنشاء جدول الموازنة
  static Widget buildBudgetTable(
      double totalIncome,        // إجمالي الدخل
      double expensesTotal,      // إجمالي المصاريف
      double owner1Withdrawn,    // مسحوبات الشريك الأول
      double owner2Withdrawn,    // مسحوبات الشريك الثاني
      Color primaryColor,        // اللون الأساسي للتصميم
      ) {
    // الحسابات الأساسية
    double netIncome = totalIncome - expensesTotal; // صافي الدخل بعد المصاريف
    double remainingMoney = netIncome - (owner1Withdrawn + owner2Withdrawn); // الرصيد المتبقي

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ===== عنوان الجدول =====
          Text(
            '📊 جدول الموازنة',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: primaryColor,
            ),
          ),
          const SizedBox(height: 16),

          // ===== الجدول =====
          Table(
            columnWidths: const {
              0: FlexColumnWidth(2),
              1: FlexColumnWidth(1),
            },
            children: [
              _buildRow('إجمالي الدخل:', totalIncome, primaryColor),
              _buildRow('إجمالي المصاريف:', expensesTotal, Colors.red[700]!),
              _buildRow('صافي الدخل:', netIncome, primaryColor),
              _buildRow('مسحوبات الشريك الأول:', owner1Withdrawn, Colors.orange[700]!),
              _buildRow('مسحوبات الشريك الثاني:', owner2Withdrawn, Colors.orange[700]!),
              _buildRow(
                'الرصيد المتبقي:',
                remainingMoney,
                remainingMoney >= 0 ? Colors.green[700]! : Colors.red[800]!,
                isBold: true,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // دالة مساعدة لبناء صف داخل الجدول
  static TableRow _buildRow(String label, double value, Color color, {bool isBold = false}) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            label,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            '${value.toStringAsFixed(2)} دينار',
            textAlign: TextAlign.end,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}
