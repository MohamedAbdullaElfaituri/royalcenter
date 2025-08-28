import 'package:flutter/material.dart';
import '../models/wash_transaction.dart';
import '../utils/wash_type_utils.dart';
import '../utils/car_size_utils.dart';

void showAddTransactionDialog({
  required BuildContext context,
  required int transactionCounter,
  required Function(WashTransaction) onAddTransaction,
}) {
  WashType selectedWashType = WashType.external;
  CarSize selectedCarSize = CarSize.medium;
  TextEditingController carModelController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController notesController = TextEditingController();

  double getSuggestedPrice(WashType washType, CarSize carSize) {
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

  double suggestedPrice = getSuggestedPrice(selectedWashType, selectedCarSize);
  priceController.text = suggestedPrice.toStringAsFixed(2);

  showDialog(
    context: context,
    builder: (context) => Directionality(
      textDirection: TextDirection.rtl,
      child: StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Center(
              child: Text('إضافة معاملة غسيل',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.teal[700])),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('رقم المعاملة: $transactionCounter',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 10),
                  DropdownButtonFormField<WashType>(
                    value: selectedWashType,
                    decoration: InputDecoration(
                      labelText: 'نوع الغسيل',
                      prefixIcon: Icon(Icons.local_car_wash, color: Colors.teal),
                    ),
                    items: [
                      DropdownMenuItem(
                        value: WashType.external,
                        child: Text('غسيل خارجي'),
                      ),
                      DropdownMenuItem(
                        value: WashType.internal,
                        child: Text('غسيل داخلي'),
                      ),
                      DropdownMenuItem(
                        value: WashType.engine,
                        child: Text('غسيل محرك'),
                      ),
                      DropdownMenuItem(
                        value: WashType.undercarriage,
                        child: Text('غسيل سفلي'),
                      ),
                      DropdownMenuItem(
                        value: WashType.seats,
                        child: Text('غسيل كراسي'),
                      ),
                      DropdownMenuItem(
                        value: WashType.complete,
                        child: Text('غسيل كامل'),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        selectedWashType = value!;
                        suggestedPrice = getSuggestedPrice(selectedWashType, selectedCarSize);
                        priceController.text = suggestedPrice.toStringAsFixed(2);
                      });
                    },
                  ),
                  SizedBox(height: 10),
                  DropdownButtonFormField<CarSize>(
                    value: selectedCarSize,
                    decoration: InputDecoration(
                      labelText: 'حجم السيارة',
                      prefixIcon: Icon(Icons.directions_car, color: Colors.teal),
                    ),
                    items: [
                      DropdownMenuItem(
                        value: CarSize.small,
                        child: Text('صغير'),
                      ),
                      DropdownMenuItem(
                        value: CarSize.medium,
                        child: Text('وسط'),
                      ),
                      DropdownMenuItem(
                        value: CarSize.large,
                        child: Text('كبير'),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        selectedCarSize = value!;
                        suggestedPrice = getSuggestedPrice(selectedWashType, selectedCarSize);
                        priceController.text = suggestedPrice.toStringAsFixed(2);
                      });
                    },
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    controller: carModelController,
                    decoration: InputDecoration(
                      labelText: 'موديل السيارة (اختياري)',
                      prefixIcon: Icon(Icons.description, color: Colors.teal),
                    ),
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    controller: priceController,
                    decoration: InputDecoration(
                      labelText: 'السعر',
                      prefixIcon: Icon(Icons.attach_money, color: Colors.teal),
                    ),
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    controller: notesController,
                    decoration: InputDecoration(
                      labelText: 'ملاحظات (اختياري)',
                      prefixIcon: Icon(Icons.note, color: Colors.teal),
                    ),
                    maxLines: 2,
                  ),
                  SizedBox(height: 15),
                  Card(
                    color: Colors.teal[50],
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('السعر المقترح:',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          Text('${suggestedPrice.toStringAsFixed(2)} دينار',
                              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.teal[700])),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('إلغاء'),
              ),
              ElevatedButton(
                onPressed: () {
                  double price = double.tryParse(priceController.text) ?? suggestedPrice;

                  onAddTransaction(WashTransaction(
                    transactionNumber: transactionCounter,
                    date: DateTime.now(),
                    time: TimeOfDay.now(),
                    washType: selectedWashType,
                    carSize: selectedCarSize,
                    carModel: carModelController.text,
                    price: price,
                    notes: notesController.text,
                  ));
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('تمت إضافة المعاملة بنجاح'),
                      backgroundColor: Colors.teal,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                child: Text('إضافة'),
              ),
            ],
          );
        },
      ),
    ),
  );
}