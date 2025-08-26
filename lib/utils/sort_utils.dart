int? getSortColumnIndex(String sortColumn) {
  switch (sortColumn) {
    case 'time':
      return 1;
    case 'washType':
      return 2;
    case 'carSize':
      return 3;
    case 'price':
      return 5;
    default:
      return null;
  }
}
