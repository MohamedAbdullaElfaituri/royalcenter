import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class InvoiceStyles {
  static pw.TextStyle createHeaderStyle(pw.Font arabicFontBold) {
    return pw.TextStyle(
      font: arabicFontBold,
      fontSize: 26,
      color: PdfColors.blue900,
    );
  }

  static pw.TextStyle createSubHeaderStyle(pw.Font arabicFontBold) {
    return pw.TextStyle(
      font: arabicFontBold,
      fontSize: 18,
      color: PdfColors.blue800,
    );
  }

  static pw.TextStyle createNormalStyle(pw.Font arabicFont) {
    return pw.TextStyle(
      font: arabicFont,
      fontSize: 14,
      color: PdfColors.grey800,
    );
  }

  static pw.TextStyle createTableHeaderStyle(pw.Font arabicFontBold) {
    return pw.TextStyle(
      font: arabicFontBold,
      fontSize: 14,
      color: PdfColors.white,
    );
  }

  static pw.TextStyle createAccentStyle(pw.Font arabicFontBold) {
    return pw.TextStyle(
      font: arabicFontBold,
      fontSize: 16,
      color: PdfColors.blue900,
    );
  }

  static pw.TextStyle createFooterStyle(pw.Font arabicFont) {
    return pw.TextStyle(
      font: arabicFont,
      fontSize: 12,
      color: PdfColors.grey600,
    );
  }
}