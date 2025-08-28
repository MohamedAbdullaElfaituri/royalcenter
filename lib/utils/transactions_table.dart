import 'package:flutter/material.dart';
import 'package:royalcenter/models/wash_transaction.dart';
import 'package:royalcenter/utils/car_size_utils.dart';
import 'package:royalcenter/utils/data_column_utils.dart';
import 'package:royalcenter/utils/dialog_utils.dart';
import 'package:royalcenter/utils/fatura.dart';
import 'package:royalcenter/utils/sort_utils.dart';
import 'package:royalcenter/utils/wash_type_utils.dart';



class TransactionsTable extends StatelessWidget {
  final List<WashTransaction> transactions;
  final String sortColumn;
  final bool sortAscending;
  final Function(WashTransaction) onDelete;
  final Function(WashTransaction) onPrint; // Callback لطباعة الفاتورة

  const TransactionsTable({
    Key? key,
    required this.transactions,
    required this.sortColumn,
    required this.sortAscending,
    required this.onDelete,
    required this.onPrint,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: MaterialStateProperty.all(Colors.teal.shade50),
          dataRowColor: MaterialStateProperty.resolveWith((states) {
            return states.contains(MaterialState.selected)
                ? Colors.teal.withOpacity(0.2)
                : Colors.grey.shade50;
          }),
          columnSpacing: 16,
          sortColumnIndex: getSortColumnIndex(sortColumn),
          sortAscending: sortAscending,
          columns: [
            buildDataColumn('م', 'index'),
            buildDataColumn('الوقت', 'time'),
            buildDataColumn('نوع الغسيل', 'washType'),
            buildDataColumn('حجم السيارة', 'carSize'),
            buildDataColumn('الموديل', 'model'),
            buildDataColumn('السعر', 'price'),
            buildDataColumn('ملاحظات', 'notes', isSortable: false),
            buildDataColumn("الفاتورة", "", isSortable: false), // عمود الفاتورة
            buildDataColumn('الإجراءات', 'actions', isSortable: false),
          ],
          rows: transactions.asMap().entries.map((entry) {
            int index = entry.key + 1;
            WashTransaction transaction = entry.value;
            return DataRow(
              cells: [
                DataCell(Text(transaction.transactionNumber.toString())),
                DataCell(Text(
                    "${transaction.time.hour}:${transaction.time.minute.toString().padLeft(2, '0')}")),
                DataCell(Text(getWashTypeName(transaction.washType))),
                DataCell(Text(getCarSizeName(transaction.carSize))),
                DataCell(Text(
                    transaction.carModel.isNotEmpty ? transaction.carModel : '-')),
                DataCell(Text('${transaction.price.toStringAsFixed(2)} دينار')),
                DataCell(
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 150),
                    child: Text(
                      transaction.notes.isNotEmpty ? transaction.notes : '-',
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                  ),
                ),
                // عمود الفاتورة: زر فاتورة
                DataCell(
                  IconButton(
                    icon: Icon(Icons.receipt_long, color: Colors.blue),
                    tooltip: "فاتورة",
                    onPressed: () {
                      showArabicPDFInvoice(context, transaction);
                    },
                  ),
                ),
                // عمود الإجراءات: حذف
                DataCell(
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => showDeleteTransactionDialog(
                      context: context,
                      transaction: transaction,
                      onDelete: () => onDelete(transaction),
                    ),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}
