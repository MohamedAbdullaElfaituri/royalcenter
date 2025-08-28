import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../models/wash_transaction.dart';
import '../utils/car_size_utils.dart';
import '../utils/wash_type_utils.dart';

Future<void> showArabicPDFInvoice(BuildContext context, WashTransaction transaction) async {
  // تحميل الخطوط
  final arabicFont = pw.Font.ttf(await rootBundle.load('assets/fonts/NotoNaskhArabic-Regular.ttf'));
  final arabicFontBold = pw.Font.ttf(await rootBundle.load('assets/fonts/NotoNaskhArabic-Bold.ttf'));
  final pdf = pw.Document();

  // أنماط النصوص المحسنة
  final headerStyle = pw.TextStyle(font: arabicFontBold, fontSize: 26, color: PdfColors.blue900);
  final subHeaderStyle = pw.TextStyle(font: arabicFontBold, fontSize: 18, color: PdfColors.blue800);
  final normalStyle = pw.TextStyle(font: arabicFont, fontSize: 14, color: PdfColors.grey800);
  final tableHeaderStyle = pw.TextStyle(font: arabicFontBold, fontSize: 14, color: PdfColors.white);
  final accentStyle = pw.TextStyle(font: arabicFontBold, fontSize: 16, color: PdfColors.blue900);
  final footerStyle = pw.TextStyle(font: arabicFont, fontSize: 12, color: PdfColors.grey600);

  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      theme: pw.ThemeData.withFont(
        base: arabicFont,
        bold: arabicFontBold,
      ),
      build: (pw.Context context) {
        return pw.Directionality(
          textDirection: pw.TextDirection.rtl,
          child: pw.Container(
            decoration: pw.BoxDecoration(
              gradient: pw.LinearGradient(
                begin: pw.Alignment.topCenter,
                end: pw.Alignment.bottomCenter,
                colors: [PdfColors.blue50, PdfColors.white],
              ),
            ),
            child: pw.Padding(
              padding: const pw.EdgeInsets.all(25),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // عنوان وشعار - تصميم محسن
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text("مركز رويال", style: headerStyle),
                          pw.SizedBox(height: 4),
                          pw.Text("ROYAL CENTER", style: subHeaderStyle.copyWith(
                              color: PdfColors.blue700,
                              fontSize: 16
                          )),
                          pw.SizedBox(height: 4),
                          pw.Text("عناية متكاملة للسيارات", style: normalStyle.copyWith(
                              fontSize: 12,
                              color: PdfColors.grey700
                          )),
                        ],
                      ),
                      // مساحة للشعار - يمكن استبدالها بصورة
                      pw.Container(
                        width: 80,
                        height: 80,
                        decoration: pw.BoxDecoration(
                          color: PdfColors.white, // خلفية
                          borderRadius: pw.BorderRadius.circular(40),
                          border: pw.Border.all(color: PdfColors.blue200, width: 2),
                          boxShadow: [
                            pw.BoxShadow(
                              color: PdfColors.grey300,
                              blurRadius: 5,
                            )
                          ],
                        ),
                        child: pw.Center(
                          child: pw.Text("شعارك", style: pw.TextStyle(
                              font: arabicFontBold,
                              fontSize: 14,
                              color: PdfColors.blue900
                          )),
                        ),
                      ),
                    ],
                  ),

                  pw.SizedBox(height: 20),
                  pw.Divider(thickness: 2, color: PdfColors.blue300, height: 1),
                  pw.SizedBox(height: 15),

                  // عنوان الفاتورة مع تصميم مميز
                  pw.Center(
                    child: pw.Container(
                      padding: pw.EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                      decoration: pw.BoxDecoration(
                        color: PdfColors.blue800,
                        borderRadius: pw.BorderRadius.circular(6),
                      ),
                      child: pw.Text("فاتورة خدمات غسيل السيارات",
                        style: headerStyle.copyWith(
                            fontSize: 20,
                            color: PdfColors.white
                        ),
                      ),
                    ),
                  ),

                  pw.SizedBox(height: 25),

                  // معلومات المعاملة مع تصميم بطاقة محسن
                  _buildCard(
                      title: "معلومات المعاملة",
                      children: [
                        _buildInfoRow("رقم المعاملة:", transaction.transactionNumber.toString(), normalStyle),
                        _buildInfoRow("التاريخ:", _formatDate(transaction.date), normalStyle),
                        _buildInfoRow("الوقت:", _formatTime(transaction.time), normalStyle),
                      ]
                  ),

                  pw.SizedBox(height: 15),

                  // معلومات الخدمة
                  _buildCard(
                      title: "معلومات السيارة والخدمة",
                      children: [
                        _buildInfoRow("نوع الغسيل:", getWashTypeName(transaction.washType), normalStyle),
                        _buildInfoRow("حجم السيارة:", getCarSizeName(transaction.carSize), normalStyle),
                        _buildInfoRow("الموديل:", transaction.carModel, normalStyle),
                      ]
                  ),

                  pw.SizedBox(height: 20),

                  // جدول السعر والخدمة مع تصميم محسن
                  pw.Container(
                    width: double.infinity,
                    decoration: pw.BoxDecoration(
                        color: PdfColors.white,
                        border: pw.Border.all(color: PdfColors.grey300),
                        borderRadius: pw.BorderRadius.circular(8),
                        boxShadow: [
                          pw.BoxShadow(
                            color: PdfColors.grey200,
                            blurRadius: 4,
                          )
                        ]
                    ),
                    child: pw.Table(
                      border: pw.TableBorder.all(color: PdfColors.grey300, width: 1),
                      columnWidths: {
                        0: pw.FlexColumnWidth(3),
                        1: pw.FlexColumnWidth(1),
                      },
                      children: [
                        // رأس الجدول
                        pw.TableRow(
                          decoration: pw.BoxDecoration(color: PdfColors.blue800),
                          children: [
                            pw.Padding(
                              padding: pw.EdgeInsets.all(10),
                              child: pw.Text("الخدمة",
                                  style: tableHeaderStyle,
                                  textAlign: pw.TextAlign.center
                              ),
                            ),
                            pw.Padding(
                              padding: pw.EdgeInsets.all(10),
                              child: pw.Text("السعر",
                                  style: tableHeaderStyle,
                                  textAlign: pw.TextAlign.center
                              ),
                            ),
                          ],
                        ),
                        // محتوى الجدول
                        pw.TableRow(
                          children: [
                            pw.Padding(
                              padding: pw.EdgeInsets.all(12),
                              child: pw.Text(getWashTypeName(transaction.washType),
                                  style: normalStyle,
                                  textAlign: pw.TextAlign.center
                              ),
                            ),
                            pw.Padding(
                              padding: pw.EdgeInsets.all(12),
                              child: pw.Text("${transaction.price.toStringAsFixed(2)} دينار",
                                  style: accentStyle,
                                  textAlign: pw.TextAlign.center
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  pw.SizedBox(height: 20),

                  // المبلغ الإجمالي مع تصميم بارز
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.end,
                    children: [
                      pw.Container(
                        padding: pw.EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        decoration: pw.BoxDecoration(
                            color: PdfColors.blue50,
                            border: pw.Border.all(color: PdfColors.blue300, width: 1.5),
                            borderRadius: pw.BorderRadius.circular(8),
                            boxShadow: [
                              pw.BoxShadow(
                                color: PdfColors.grey200,
                                blurRadius: 3,
                              )
                            ]
                        ),
                        child: pw.Text("المبلغ الإجمالي: ${transaction.price.toStringAsFixed(2)} دينار",
                          style: pw.TextStyle(
                              font: arabicFontBold,
                              fontSize: 18,
                              color: PdfColors.blue900
                          ),
                        ),
                      ),
                    ],
                  ),

                  pw.SizedBox(height: 20),

                  // الملاحظات مع تصميم محسن
                  pw.Text("ملاحظات:", style: subHeaderStyle.copyWith(fontSize: 16)),
                  pw.SizedBox(height: 8),
                  pw.Container(
                    width: double.infinity,
                    padding: pw.EdgeInsets.all(15),
                    decoration: pw.BoxDecoration(
                        color: PdfColors.grey50,
                        border: pw.Border.all(color: PdfColors.grey300),
                        borderRadius: pw.BorderRadius.circular(8)
                    ),
                    child: pw.Text(
                      transaction.notes.isNotEmpty ? transaction.notes : 'لا توجد ملاحظات',
                      style: normalStyle,
                    ),
                  ),

                  pw.SizedBox(height: 30),

                  // معلومات الاتصال مع تصميم تذييل الصفحة
                  pw.Divider(thickness: 1, color: PdfColors.grey400),
                  pw.SizedBox(height: 15),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                    children: [
                      pw.Text("هاتف: 1234567890", style: footerStyle),
                      pw.Text("البريد الإلكتروني: info@royal-center.com", style: footerStyle),
                    ],
                  ),
                  pw.SizedBox(height: 10),
                  pw.Center(
                    child: pw.Text("شكراً لثقتكم واختياركم خدماتنا",
                      style: footerStyle.copyWith(
                          fontStyle: pw.FontStyle.italic,
                          color: PdfColors.blue700
                      ),
                    ),
                  ),
                  pw.SizedBox(height: 5),
                  pw.Center(
                    child: pw.Text("نتمنى لكم تجربة ممتعة",
                      style: footerStyle.copyWith(
                          color: PdfColors.grey600
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    ),
  );

  // عرض PDF
  showDialog(
    context: context,
    builder: (context) => Dialog(
      insetPadding: EdgeInsets.all(20),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.85,
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
        ),
        child: PdfPreview(
          build: (format) => pdf.save(),
        ),
      ),
    ),
  );
}

// مساعد لإنشاء بطاقة بمظهر محسن
pw.Widget _buildCard({required String title, required List<pw.Widget> children}) {
  return pw.Container(
    padding: pw.EdgeInsets.all(15),
    decoration: pw.BoxDecoration(
        color: PdfColors.white,
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(10),
        boxShadow: [
          pw.BoxShadow(
            color: PdfColors.grey200,
            blurRadius: 4,
          )
        ]
    ),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(title,
          style: pw.TextStyle(
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blue800
          ),
        ),
        pw.SizedBox(height: 12),
        ...children,
      ],
    ),
  );
}

// مساعد لإنشاء صف معلومات
pw.Widget _buildInfoRow(String label, String value, pw.TextStyle style) {
  return pw.Padding(
    padding: pw.EdgeInsets.symmetric(vertical: 6),
    child: pw.Row(
      children: [
        pw.Expanded(
          flex: 2,
          child: pw.Text(value,
              style: style,
              textAlign: pw.TextAlign.right
          ),
        ),
        pw.SizedBox(width: 10),
        pw.Expanded(
          flex: 1,
          child: pw.Text(label,
              style: style.copyWith(
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.blue800
              ),
              textAlign: pw.TextAlign.left
          ),
        ),
      ],
    ),
  );
}

// تنسيق التاريخ
String _formatDate(DateTime date) => "${date.year}-${date.month.toString().padLeft(2,'0')}-${date.day.toString().padLeft(2,'0')}";

// تنسيق الوقت
String _formatTime(TimeOfDay time) => "${time.hour.toString().padLeft(2,'0')}:${time.minute.toString().padLeft(2,'0')}";