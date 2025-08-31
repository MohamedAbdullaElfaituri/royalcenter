import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../models/wash_transaction.dart';
import '../utils/date_time_utils.dart';
import '../utils/car_size_utils.dart';
import '../utils/wash_type_utils.dart';

class PdfInvoiceBuilder {
  static const _primaryColor = PdfColors.blue700;
  static const _secondaryColor = PdfColors.grey600;
  static const _accentColor = PdfColors.green600;
  static const _backgroundColor = PdfColors.grey50;
  static const _borderColor = PdfColors.grey300;

  /// 🟦 بطاقة (Card) تحتوي على عنوان + عناصر
  static pw.Widget buildCard({
    required String title,
    required List<pw.Widget> children,
    required pw.Font arabicFontBold,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: PdfColors.white,
        borderRadius: pw.BorderRadius.circular(8),
        boxShadow: [
          pw.BoxShadow(color: _borderColor, blurRadius: 4),
        ],
        border: pw.Border.all(color: _borderColor, width: 0.5),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            title,
            style: pw.TextStyle(
              font: arabicFontBold,
              fontSize: 14,
              color: _primaryColor,
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Divider(color: _borderColor, height: 1, thickness: 0.5),
          pw.SizedBox(height: 8),
          ...children,
        ],
      ),
    );
  }

  /// 🟨 صف معلومات (Label : Value)
  static pw.Widget buildInfoRow(
      String label,
      String value,
      pw.TextStyle style, {
        bool isTotal = false,
      }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          // القيمة
          pw.Text(
            value,
            style: style.copyWith(
              color: isTotal ? _accentColor : _secondaryColor,
              fontSize: isTotal ? 12 : 10,
              fontWeight: isTotal ? pw.FontWeight.bold : pw.FontWeight.normal,
            ),
            textAlign: pw.TextAlign.right,
          ),
          // العنوان
          pw.Text(
            label,
            style: style.copyWith(
              fontWeight: pw.FontWeight.bold,
              color: _primaryColor,
              fontSize: isTotal ? 12 : 10,
            ),
            textAlign: pw.TextAlign.left,
          ),
        ],
      ),
    );
  }

  /// 📄 المحتوى الكامل للفاتورة
  static pw.Widget buildInvoiceContent(
      WashTransaction transaction,
      pw.Font arabicFont,
      pw.Font arabicFontBold,
      pw.ImageProvider? logoImage,
      ) {
    // أنماط عامة
    final headerStyle = pw.TextStyle(font: arabicFontBold, fontSize: 16, color: _primaryColor);
    final subHeaderStyle = pw.TextStyle(font: arabicFontBold, fontSize: 12, color: _secondaryColor);
    final normalStyle = pw.TextStyle(font: arabicFont, fontSize: 10, color: _secondaryColor);
    final accentStyle = pw.TextStyle(font: arabicFontBold, fontSize: 12, color: _accentColor);
    final footerStyle = pw.TextStyle(font: arabicFont, fontSize: 8, color: _secondaryColor);

    return pw.Container(
      color: _backgroundColor,
      padding: const pw.EdgeInsets.all(16),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [

          /// 🔵 الهيدر (Header)
          pw.Container(
            padding: const pw.EdgeInsets.all(16),
            decoration: pw.BoxDecoration(
              color: PdfColors.white,
              borderRadius: pw.BorderRadius.circular(8),
              boxShadow: [pw.BoxShadow(color: _borderColor, blurRadius: 4)],
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // ✅ معلومات الشركة
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text("KING CENTER", style: headerStyle.copyWith(fontSize: 18)),
                    pw.SizedBox(height: 2),
                    pw.Text("مركز الملكي", style: subHeaderStyle.copyWith(fontSize: 14)),
                    pw.SizedBox(height: 4),
                    pw.Text("عناية متكاملة للسيارات", style: normalStyle.copyWith(fontSize: 10)),
                    pw.SizedBox(height: 6),
                    pw.Row(
                      children: [
                        pw.SizedBox(width: 4),
                        pw.Text("0920133085 الزبير بالتمر ", style: normalStyle.copyWith(fontSize: 9)),
                      ],
                    ),
                    pw.SizedBox(height: 2),
                    pw.Row(
                      children: [
                        pw.SizedBox(width: 4),
                        pw.Text("0918847217 فراس بالتمر ", style: normalStyle.copyWith(fontSize: 9)),
                      ],
                    ),
                  ],
                ),

                // ✅ شعار الشركة + بيانات الفاتورة
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    if (logoImage != null)
                      pw.Container(
                        width: 50, height: 50,
                        child: pw.Image(logoImage, fit: pw.BoxFit.cover),
                      )
                    else
                      pw.Container(
                        width: 50, height: 50,
                        decoration: pw.BoxDecoration(
                          color: _primaryColor,
                          borderRadius: pw.BorderRadius.circular(25),
                        ),
                        child: pw.Center(
                          child: pw.Text("K.C.",
                            style: pw.TextStyle(
                              font: arabicFontBold, fontSize: 16, color: PdfColors.white,
                            ),
                          ),
                        ),
                      ),
                    pw.SizedBox(height: 8),
                    pw.Container(
                      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: pw.BoxDecoration(
                        color: _primaryColor,
                        borderRadius: pw.BorderRadius.circular(3),
                      ),
                      child: pw.Text("فاتورة خدمات",
                        style: pw.TextStyle(font: arabicFontBold, fontSize: 10, color: PdfColors.white),
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text("#${transaction.transactionNumber}",
                      style: normalStyle.copyWith(fontSize: 9, fontWeight: pw.FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
          ),

          pw.SizedBox(height: 16),

          /// 🟢 بيانات العميل + السيارة
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                child: buildCard(
                  title: "معلومات المعاملة",
                  children: [
                    buildInfoRow("رقم المعاملة:", transaction.transactionNumber.toString(), normalStyle),
                    buildInfoRow("التاريخ:", formatDate(transaction.date), normalStyle),
                    buildInfoRow("الوقت:", formatTime(transaction.time), normalStyle),
                  ],
                  arabicFontBold: arabicFontBold,
                ),
              ),
              pw.SizedBox(width: 12),
              pw.Expanded(
                child: buildCard(
                  title: "معلومات السيارة",
                  children: [
                    buildInfoRow("نوع الغسيل:", getWashTypeName(transaction.washType), normalStyle),
                    buildInfoRow("حجم السيارة:", getCarSizeName(transaction.carSize), normalStyle),
                    buildInfoRow("الموديل:", transaction.carModel, normalStyle),
                  ],
                  arabicFontBold: arabicFontBold,
                ),
              ),
            ],
          ),

          pw.SizedBox(height: 16),

          /// 🟡 جدول الخدمات
          pw.Container(
            width: double.infinity,
            decoration: pw.BoxDecoration(
              color: PdfColors.white,
              borderRadius: pw.BorderRadius.circular(8),
              boxShadow: [pw.BoxShadow(color: _borderColor, blurRadius: 4)],
              border: pw.Border.all(color: _borderColor, width: 0.5),
            ),
            child: pw.Table(
              border: pw.TableBorder(
                horizontalInside: pw.BorderSide(color: _borderColor, width: 0.5),
                verticalInside: pw.BorderSide(color: _borderColor, width: 0.3),
              ),
              columnWidths: {
                0: const pw.FlexColumnWidth(3),
                1: const pw.FlexColumnWidth(1),
              },
              children: [
                // رأس الجدول
                pw.TableRow(
                  decoration: pw.BoxDecoration(color: _primaryColor),
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text("الخدمة",
                        style: headerStyle.copyWith(fontSize: 12, color: PdfColors.white),
                        textAlign: pw.TextAlign.center,
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text("السعر",
                        style: headerStyle.copyWith(fontSize: 12, color: PdfColors.white),
                        textAlign: pw.TextAlign.center,
                      ),
                    ),
                  ],
                ),
                // بيانات الخدمة
                pw.TableRow(
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(getWashTypeName(transaction.washType),
                        style: normalStyle.copyWith(fontSize: 10),
                        textAlign: pw.TextAlign.center,
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text("${transaction.price.toStringAsFixed(2)} دينار",
                        style: accentStyle.copyWith(fontSize: 11, fontWeight: pw.FontWeight.bold),
                        textAlign: pw.TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          pw.SizedBox(height: 16),

          /// 🔴 المبلغ الكلي
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.all(16),
            decoration: pw.BoxDecoration(
              color: PdfColors.white,
              borderRadius: pw.BorderRadius.circular(8),
              boxShadow: [pw.BoxShadow(color: _borderColor, blurRadius: 4)],
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text("المبلغ الإجمالي:",
                  style: normalStyle.copyWith(fontSize: 14, color: _primaryColor, fontWeight: pw.FontWeight.bold),
                ),
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: pw.BoxDecoration(
                    borderRadius: pw.BorderRadius.circular(6),
                    border: pw.Border.all(color: _accentColor, width: 0.5),
                  ),
                  child: pw.Text("${transaction.price.toStringAsFixed(2)} دينار",
                    style: accentStyle.copyWith(fontSize: 16, fontWeight: pw.FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),

          pw.SizedBox(height: 16),

          /// 📝 ملاحظات
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.all(16),
            decoration: pw.BoxDecoration(
              color: PdfColors.white,
              borderRadius: pw.BorderRadius.circular(8),
              boxShadow: [pw.BoxShadow(color: _borderColor, blurRadius: 4)],
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  children: [
                    pw.Icon(pw.IconData(0), size: 14, color: _primaryColor),
                    pw.SizedBox(width: 6),
                    pw.Text("ملاحظات:",
                      style: subHeaderStyle.copyWith(fontSize: 14, color: _primaryColor),
                    ),
                  ],
                ),
                pw.SizedBox(height: 8),
                pw.Container(
                  padding: const pw.EdgeInsets.all(8),
                  decoration: pw.BoxDecoration(
                    color: _backgroundColor,
                    borderRadius: pw.BorderRadius.circular(6),
                    border: pw.Border.all(color: _borderColor, width: 0.5),
                  ),
                  child: pw.Text(
                    transaction.notes.isNotEmpty ? transaction.notes : 'لا توجد ملاحظات',
                    style: normalStyle.copyWith(fontSize: 10, color: _secondaryColor),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
