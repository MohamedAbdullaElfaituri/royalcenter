import 'package:flutter/material.dart';
import 'package:royalcenter/models/wash_transaction.dart';
import '../utils/chip_utils.dart';

class StatisticsCard extends StatelessWidget {
  final int transactionCount;
  final double totalIncome;
  final Map<WashType, int> washTypeCounts;

  const StatisticsCard({
    Key? key,
    required this.transactionCount,
    required this.totalIncome,
    required this.washTypeCounts,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Colors.teal;
    final Color secondaryColor = Colors.blueGrey;
    final Color accentColor = Colors.orange;

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ],
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            primaryColor.withOpacity(0.05),
            primaryColor.withOpacity(0.02),
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  Icons.bar_chart_rounded,
                  color: primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'إحصائيات اليوم',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Stats Row
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: primaryColor.withOpacity(0.2)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem(
                    icon: Icons.receipt_long,
                    label: 'عدد المعاملات',
                    value: transactionCount.toString(),
                    color: primaryColor,
                  ),
                  Container(
                    width: 1,
                    height: 40,
                    color: primaryColor.withOpacity(0.3),
                  ),
                  _buildStatItem(
                    icon: Icons.attach_money_rounded,
                    label: 'إجمالي الدخل',
                    value: '${totalIncome.toStringAsFixed(2)} دينار',
                    color: Colors.green,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Wash Types Title
            Text(
              'تفاصيل أنواع الغسيل',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: secondaryColor,
              ),
            ),

            const SizedBox(height: 12),

            // Wash Types Chips
            Center(
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.center,     // Yatayda ortalama
                runAlignment: WrapAlignment.center,  // Dikeyde ortalama
                children: [
                  _buildModernWashTypeChip('خارجي', washTypeCounts[WashType.external]!, Colors.blue),
                  _buildModernWashTypeChip('داخلي', washTypeCounts[WashType.internal]!, Colors.green),
                  _buildModernWashTypeChip('محرك', washTypeCounts[WashType.engine]!, Colors.orange),
                  _buildModernWashTypeChip('سفلي', washTypeCounts[WashType.undercarriage]!, Colors.brown),
                  _buildModernWashTypeChip('كراسي', washTypeCounts[WashType.seats]!, Colors.pink),
                  _buildModernWashTypeChip('كامل', washTypeCounts[WashType.complete]!, Colors.purple),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          size: 20,
          color: color,
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.blueGrey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildModernWashTypeChip(String label, int count, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3), width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Count Badge
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  count.toString(),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 6),

            // Label
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
