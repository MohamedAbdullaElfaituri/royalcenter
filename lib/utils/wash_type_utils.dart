import '../models/wash_transaction.dart';

String getWashTypeName(WashType washType) {
  switch (washType) {
    case WashType.external:
      return 'خارجي';
    case WashType.internal:
      return 'داخلي';
    case WashType.engine:
      return 'محرك';
    case WashType.undercarriage:
      return 'سفلي';
    case WashType.seats:
      return 'كراسي';
    case WashType.complete:
      return 'كامل';
    default:
      return 'غير معروف';
  }
}