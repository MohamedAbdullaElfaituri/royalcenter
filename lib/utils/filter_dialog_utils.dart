import 'package:flutter/material.dart';

void showFilterOptionsDialog({
  required BuildContext context,
  required String sortColumn,
  required bool sortAscending,
  required void Function(String columnName, bool ascending) onSort,
}) {
  final Color primaryColor = Colors.teal;
  final Color secondaryColor = Colors.blueGrey;

  showDialog(
    context: context,
    builder: (context) => Directionality(
      textDirection: TextDirection.rtl,
      child: Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header Section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.filter_list_rounded,
                      size: 28,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'خيارات التصفية والترتيب',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),

              // Content Section
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'ترتيب حسب:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: secondaryColor,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildSortOption(
                      title: 'الوقت',
                      columnName: 'time',
                      icon: Icons.access_time,
                      sortColumn: sortColumn,
                      sortAscending: sortAscending,
                      onSort: onSort,
                      primaryColor: primaryColor,
                    ),
                    _buildSortOption(
                      title: 'نوع الغسيل',
                      columnName: 'washType',
                      icon: Icons.local_car_wash,
                      sortColumn: sortColumn,
                      sortAscending: sortAscending,
                      onSort: onSort,
                      primaryColor: primaryColor,
                    ),
                    _buildSortOption(
                      title: 'حجم السيارة',
                      columnName: 'carSize',
                      icon: Icons.directions_car,
                      sortColumn: sortColumn,
                      sortAscending: sortAscending,
                      onSort: onSort,
                      primaryColor: primaryColor,
                    ),
                    _buildSortOption(
                      title: 'السعر',
                      columnName: 'price',
                      icon: Icons.attach_money,
                      sortColumn: sortColumn,
                      sortAscending: sortAscending,
                      onSort: onSort,
                      primaryColor: primaryColor,
                    ),
                  ],
                ),
              ),

              // Actions Section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    child: Text(
                      'تم',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

Widget _buildSortOption({
  required String title,
  required String columnName,
  required IconData icon,
  required String sortColumn,
  required bool sortAscending,
  required void Function(String columnName, bool ascending) onSort,
  required Color primaryColor,
}) {
  final bool isSelected = sortColumn == columnName;

  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
    child: Material(
      color: isSelected ? primaryColor.withOpacity(0.1) : Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () => onSort(columnName, isSelected ? !sortAscending : true),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? primaryColor : Colors.grey[300]!,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: isSelected ? primaryColor : Colors.grey[600],
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected ? primaryColor : Colors.grey[700],
                  ),
                ),
              ),
              if (isSelected) ...[
                Icon(
                  sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
                  size: 18,
                  color: primaryColor,
                ),
                const SizedBox(width: 4),
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: primaryColor,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    ),
  );
}

// Alternative compact version for mobile
Widget _buildSortOptionCompact({
  required String title,
  required String columnName,
  required IconData icon,
  required String sortColumn,
  required bool sortAscending,
  required void Function(String columnName, bool ascending) onSort,
  required Color primaryColor,
}) {
  final bool isSelected = sortColumn == columnName;

  return ListTile(
    leading: Icon(
      icon,
      color: isSelected ? primaryColor : Colors.grey[600],
    ),
    title: Text(
      title,
      style: TextStyle(
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        color: isSelected ? primaryColor : Colors.grey[700],
      ),
    ),
    trailing: isSelected
        ? Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
          size: 18,
          color: primaryColor,
        ),
        const SizedBox(width: 4),
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: primaryColor,
            shape: BoxShape.circle,
          ),
        ),
      ],
    )
        : null,
    onTap: () => onSort(columnName, isSelected ? !sortAscending : true),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
  );
}