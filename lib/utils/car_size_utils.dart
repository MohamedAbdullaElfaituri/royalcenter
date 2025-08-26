import '../models/wash_transaction.dart';

String getCarSizeName(CarSize carSize) {
  switch (carSize) {
    case CarSize.small:
      return 'صغير';
    case CarSize.medium:
      return 'وسط';
    case CarSize.large:
      return 'كبير';
    default:
      return '';
  }
}
