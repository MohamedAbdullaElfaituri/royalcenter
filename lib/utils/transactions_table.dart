import 'package:flutter/material.dart';
import 'package:royalcenter/models/wash_transaction.dart';
import 'package:royalcenter/services/invoice_service.dart';
import 'package:royalcenter/utils/car_size_utils.dart';
import 'package:royalcenter/utils/data_column_utils.dart';
import 'package:royalcenter/utils/dialog_utils.dart';
import 'package:royalcenter/utils/sort_utils.dart';
import 'package:royalcenter/utils/wash_type_utils.dart';

class TransactionsTable extends StatelessWidget {
  final List<WashTransaction> transactions;
  final String sortColumn;
  final bool sortAscending;
  final Function(WashTransaction) onDelete;
  final Function(WashTransaction) onPrint;

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
    final Color primaryColor = Colors.teal;
    final Color secondaryColor = Colors.blueGrey;
    final Color accentColor = Colors.orange;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 12,
              spreadRadius: 2,
            ),
          ],
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: DataTable(
              headingRowHeight: 60,
              dataRowHeight: 60,
              horizontalMargin: 16,
              columnSpacing: 20,
              dividerThickness: 1,
              headingTextStyle: TextStyle(
                fontWeight: FontWeight.bold,
                color: primaryColor,
                fontSize: 14,
              ),
              dataTextStyle: TextStyle(
                color: secondaryColor,
                fontSize: 13,
              ),
              headingRowColor: MaterialStateProperty.all(
                primaryColor.withOpacity(0.08),
              ),
              dataRowColor: MaterialStateProperty.resolveWith((states) {
                return states.contains(MaterialState.selected)
                    ? primaryColor.withOpacity(0.15)
                    : Colors.transparent;
              }),
              sortColumnIndex: getSortColumnIndex(sortColumn),
              sortAscending: sortAscending,
              columns: [
                _buildModernDataColumn('م', 'index', primaryColor),
                _buildModernDataColumn('الوقت', 'time', primaryColor),
                _buildModernDataColumn('نوع الغسيل', 'washType', primaryColor),
                _buildModernDataColumn('حجم السيارة', 'carSize', primaryColor),
                _buildModernDataColumn('الموديل', 'model', primaryColor),
                _buildModernDataColumn('السعر', 'price', primaryColor),
                _buildModernDataColumn('ملاحظات', 'notes', primaryColor, isSortable: false),
                _buildModernDataColumn("الفاتورة", "", primaryColor, isSortable: false),
                _buildModernDataColumn('الإجراءات', 'actions', primaryColor, isSortable: false),
              ],
              rows: transactions.asMap().entries.map((entry) {
                final index = entry.key;
                final transaction = entry.value;

                return DataRow(
                  cells: [
                    _buildDataCell(
                      Text(
                        transaction.transactionNumber.toString(),
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: primaryColor,
                        ),
                      ),
                    ),
                    _buildDataCell(
                      Text(
                        "${transaction.time.hour}:${transaction.time.minute.toString().padLeft(2, '0')}",
                        style: TextStyle(
                          color: secondaryColor.withOpacity(0.8),
                        ),
                      ),
                    ),
                    _buildDataCell(
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getWashTypeColor(transaction.washType),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          getWashTypeName(transaction.washType),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    _buildDataCell(
                      Text(
                        getCarSizeName(transaction.carSize),
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: secondaryColor,
                        ),
                      ),
                    ),
                    _buildDataCell(
                      Text(
                        transaction.carModel.isNotEmpty ? transaction.carModel : '-',
                        style: TextStyle(
                          color: secondaryColor.withOpacity(0.8),
                          fontStyle: transaction.carModel.isEmpty
                              ? FontStyle.italic
                              : FontStyle.normal,
                        ),
                      ),
                    ),
                    _buildDataCell(
                      Text(
                        '${transaction.price.toStringAsFixed(2)} دينار',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                    ),
                    _buildDataCell(
                      Tooltip(
                        message: transaction.notes.isNotEmpty ? transaction.notes : 'لا توجد ملاحظات',
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 120),
                          child: Text(
                            transaction.notes.isNotEmpty ? transaction.notes : '-',
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                            style: TextStyle(
                              color: secondaryColor.withOpacity(0.7),
                              fontStyle: transaction.notes.isEmpty
                                  ? FontStyle.italic
                                  : FontStyle.normal,
                            ),
                          ),
                        ),
                      ),
                    ),
                    _buildDataCell(
                      IconButton(
                        icon: Icon(Icons.receipt_long,
                            color: primaryColor, size: 22),
                        tooltip: "فاتورة",
                        onPressed: () {
                          InvoiceService.showArabicPDFInvoice(context, transaction);
                        },
                        style: IconButton.styleFrom(
                          backgroundColor: primaryColor.withOpacity(0.1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.all(6),
                        ),
                      ),
                    ),
                    _buildDataCell(
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.delete,
                                color: Colors.red.shade600, size: 20),
                            onPressed: () => showDeleteTransactionDialog(
                              context: context,
                              transaction: transaction,
                              onDelete: () => onDelete(transaction),
                            ),
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.red.withOpacity(0.1),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.all(6),
                            ),
                          ),
                          const SizedBox(width: 4),
                          IconButton(
                            icon: Icon(Icons.print,
                                color: accentColor, size: 20),
                            tooltip: "طباعة",
                            onPressed: () => onPrint(transaction),
                            style: IconButton.styleFrom(
                              backgroundColor: accentColor.withOpacity(0.1),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.all(6),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  DataColumn _buildModernDataColumn(String label, String columnName,
      Color primaryColor, {bool isSortable = true}) {
    return DataColumn(
      label: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: primaryColor,
            fontSize: 14,
          ),
        ),
      ),
      onSort: isSortable ? (columnIndex, ascending) {
        // Handle sort logic here
      } : null,
    );
  }

  DataCell _buildDataCell(Widget child) {
    return DataCell(
      Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: child,
      ),
    );
  }

  Color _getWashTypeColor(WashType washType) {
    switch (washType) {
      case WashType.external:
        return Colors.blue.shade600;
      case WashType.internal:
        return Colors.green.shade600;
      case WashType.engine:
        return Colors.orange.shade600;
      case WashType.undercarriage:
        return Colors.purple.shade600;
      case WashType.seats:
        return Colors.red.shade600;
      case WashType.complete:
        return Colors.teal.shade600;
      default:
        return Colors.grey.shade600;
    }
  }
}