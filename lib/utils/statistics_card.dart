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
    return Card(
      margin: EdgeInsets.all(12),
      color: Colors.teal[50],
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Text('إحصائيات اليوم', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Text('عدد المعاملات', style: TextStyle(fontSize: 14)),
                    Text(transactionCount.toString(), style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
                Column(
                  children: [
                    Text('إجمالي الدخل', style: TextStyle(fontSize: 14)),
                    Text('${totalIncome.toStringAsFixed(2)} دينار', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.teal[700])),
                  ],
                ),
              ],
            ),
            SizedBox(height: 10),
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: [
                buildWashTypeChip('خارجي', washTypeCounts[WashType.external]!, Colors.blue),
                buildWashTypeChip('داخلي', washTypeCounts[WashType.internal]!, Colors.green),
                buildWashTypeChip('محرك', washTypeCounts[WashType.engine]!, Colors.orange),
                buildWashTypeChip('سفلي', washTypeCounts[WashType.undercarriage]!, Colors.brown),
                buildWashTypeChip('كراسي', washTypeCounts[WashType.seats]!, Colors.pink),
                buildWashTypeChip('كامل', washTypeCounts[WashType.complete]!, Colors.purple),
              ],
            ),
          ],
        ),
      ),
    );
  }
}