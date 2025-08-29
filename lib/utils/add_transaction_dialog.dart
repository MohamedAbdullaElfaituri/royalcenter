import 'package:flutter/material.dart';
import '../models/wash_transaction.dart';
import '../utils/wash_type_utils.dart';
import '../utils/car_size_utils.dart';

void showAddTransactionDialog({
  required BuildContext context,
  required int transactionCounter,
  required Function(WashTransaction) onAddTransaction,
}) {
  showDialog(
    context: context,
    builder: (context) => Directionality(
      textDirection: TextDirection.rtl,
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(20),
        child: _AddTransactionDialogContent(
          transactionCounter: transactionCounter,
          onAddTransaction: onAddTransaction,
        ),
      ),
    ),
  );
}

class _AddTransactionDialogContent extends StatefulWidget {
  final int transactionCounter;
  final Function(WashTransaction) onAddTransaction;

  const _AddTransactionDialogContent({
    required this.transactionCounter,
    required this.onAddTransaction,
  });

  @override
  __AddTransactionDialogContentState createState() => __AddTransactionDialogContentState();
}

class __AddTransactionDialogContentState extends State<_AddTransactionDialogContent> {
  late WashType _selectedWashType;
  late CarSize _selectedCarSize;
  late TextEditingController _carModelController;
  late TextEditingController _priceController;
  late TextEditingController _notesController;
  late double _suggestedPrice;

  final Color _primaryColor = Colors.teal;
  final Color _secondaryColor = Colors.blueGrey;
  final Color _accentColor = Colors.orange;

  @override
  void initState() {
    super.initState();
    _selectedWashType = WashType.external;
    _selectedCarSize = CarSize.medium;
    _carModelController = TextEditingController();
    _notesController = TextEditingController();
    _priceController = TextEditingController();

    _updateSuggestedPrice();
  }

  @override
  void dispose() {
    _carModelController.dispose();
    _priceController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  double _getSuggestedPrice(WashType washType, CarSize carSize) {
    switch (washType) {
      case WashType.internal:
        switch (carSize) {
          case CarSize.medium: return 15.0;
          case CarSize.large: return 20.0;
          default: return 15.0;
        }
      case WashType.external:
        switch (carSize) {
          case CarSize.medium: return 15.0;
          case CarSize.large: return 20.0;
          default: return 10.0;
        }
      case WashType.complete:
        switch (carSize) {
          case CarSize.medium: return 30.0;
          case CarSize.large: return 40.0;
          default: return 30.0;
        }
      case WashType.engine: return 15.0;
      case WashType.undercarriage: return 15.0;
      case WashType.seats: return 80.0;
      default: return 15.0;
    }
  }

  void _updateSuggestedPrice() {
    _suggestedPrice = _getSuggestedPrice(_selectedWashType, _selectedCarSize);
    _priceController.text = _suggestedPrice.toStringAsFixed(2);
  }

  void _onWashTypeChanged(WashType? value) {
    if (value == null) return;

    setState(() {
      _selectedWashType = value;
      _updateSuggestedPrice();
    });
  }

  void _onCarSizeChanged(CarSize? value) {
    if (value == null) return;

    setState(() {
      _selectedCarSize = value;
      _updateSuggestedPrice();
    });
  }

  void _onAddTransaction() {
    final price = double.tryParse(_priceController.text) ?? _suggestedPrice;

    widget.onAddTransaction(WashTransaction(
      transactionNumber: widget.transactionCounter,
      date: DateTime.now(),
      time: TimeOfDay.now(),
      washType: _selectedWashType,
      carSize: _selectedCarSize,
      carModel: _carModelController.text,
      price: price,
      notes: _notesController.text,
    ));

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تمت إضافة المعاملة بنجاح'),
        backgroundColor: _primaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
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
              color: _primaryColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.local_car_wash,
                  size: 40,
                  color: Colors.white,
                ),
                const SizedBox(height: 10),
                Text(
                  'إضافة معاملة غسيل',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'رقم المعاملة: ${widget.transactionCounter}',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),

          // Form Section
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildDropdownField(
                    value: _selectedWashType,
                    items: _buildWashTypeDropdownItems(),
                    onChanged: _onWashTypeChanged,
                    label: 'نوع الغسيل',
                    icon: Icons.local_car_wash,
                  ),
                  const SizedBox(height: 16),
                  _buildDropdownField(
                    value: _selectedCarSize,
                    items: _buildCarSizeDropdownItems(),
                    onChanged: _onCarSizeChanged,
                    label: 'حجم السيارة',
                    icon: Icons.directions_car,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _carModelController,
                    label: 'موديل السيارة (اختياري)',
                    icon: Icons.description,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _priceController,
                    label: 'السعر',
                    icon: Icons.attach_money,
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _notesController,
                    label: 'ملاحظات (اختياري)',
                    icon: Icons.note,
                    maxLines: 2,
                  ),
                  const SizedBox(height: 20),
                  _buildSuggestedPriceCard(),
                ],
              ),
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
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(color: _secondaryColor),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'إلغاء',
                      style: TextStyle(
                        color: _secondaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _onAddTransaction,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    child: const Text(
                      'إضافة',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownField<T>({
    required T value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
    required String label,
    required IconData icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: DropdownButtonFormField<T>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: _primaryColor),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
        items: items,
        onChanged: onChanged,
        dropdownColor: Colors.white,
        style: TextStyle(color: _secondaryColor, fontSize: 14),
        icon: Icon(Icons.arrow_drop_down, color: _primaryColor),
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: TextStyle(color: _secondaryColor, fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: _secondaryColor.withOpacity(0.7)),
        prefixIcon: Icon(icon, color: _primaryColor),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _primaryColor, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey[50],
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  List<DropdownMenuItem<WashType>> _buildWashTypeDropdownItems() {
    return [
      _buildDropdownItem(WashType.external, 'غسيل خارجي', Icons.wash),
      _buildDropdownItem(WashType.internal, 'غسيل داخلي', Icons.airline_seat_recline_normal),
      _buildDropdownItem(WashType.engine, 'غسيل محرك', Icons.engineering),
      _buildDropdownItem(WashType.undercarriage, 'غسيل سفلي', Icons.vertical_align_bottom),
      _buildDropdownItem(WashType.seats, 'غسيل كراسي', Icons.chair),
      _buildDropdownItem(WashType.complete, 'غسيل كامل', Icons.local_car_wash),
    ];
  }

  List<DropdownMenuItem<CarSize>> _buildCarSizeDropdownItems() {
    return [
      _buildDropdownItem(CarSize.small, 'صغير', Icons.directions_car),
      _buildDropdownItem(CarSize.medium, 'وسط', Icons.directions_car),
      _buildDropdownItem(CarSize.large, 'كبير', Icons.directions_car),
    ];
  }

  DropdownMenuItem<T> _buildDropdownItem<T>(T value, String text, IconData icon) {
    return DropdownMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(icon, size: 18, color: _secondaryColor),
          const SizedBox(width: 8),
          Text(text, style: TextStyle(color: _secondaryColor)),
        ],
      ),
    );
  }

  Widget _buildSuggestedPriceCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _primaryColor.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'السعر المقترح:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: _secondaryColor,
              fontSize: 14,
            ),
          ),
          Text(
            '${_suggestedPrice.toStringAsFixed(2)} دينار',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: _primaryColor,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}