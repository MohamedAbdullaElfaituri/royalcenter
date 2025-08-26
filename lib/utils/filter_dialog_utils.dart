import 'package:flutter/material.dart';

void showFilterOptionsDialog({
  required BuildContext context,
  required String sortColumn,
  required bool sortAscending,
  required void Function(String columnName, bool ascending) onSort,
}) {
  showDialog(
    context: context,
    builder: (context) => Directionality(
      textDirection: TextDirection.rtl,
      child: AlertDialog(
        title: Text('خيارات التصفية والترتيب'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildSortTile('الوقت', 'time', sortColumn, sortAscending, onSort),
            _buildSortTile('نوع الغسيل', 'washType', sortColumn, sortAscending, onSort),
            _buildSortTile('حجم السيارة', 'carSize', sortColumn, sortAscending, onSort),
            _buildSortTile('السعر', 'price', sortColumn, sortAscending, onSort),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('إغلاق'),
          ),
        ],
      ),
    ),
  );
}

Widget _buildSortTile(
    String title,
    String columnName,
    String sortColumn,
    bool sortAscending,
    void Function(String columnName, bool ascending) onSort,
    ) {
  return ListTile(
    title: Text(title),
    trailing: sortColumn == columnName
        ? Icon(sortAscending ? Icons.arrow_upward : Icons.arrow_downward)
        : null,
    onTap: () => onSort(columnName, sortColumn == columnName ? !sortAscending : true),
  );
}
