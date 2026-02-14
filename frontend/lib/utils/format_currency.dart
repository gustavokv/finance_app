import 'package:intl/intl.dart';
import 'package:decimal/decimal.dart';

String formatCurrency(Decimal value) {
  NumberFormat formater = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

  return formater.format(value.toDouble());
}

Decimal parseCurrencyBR(String value) {
  if (value.isEmpty) return Decimal.zero;

  String cleanedValue = value.replaceAll('R\$', '').replaceAll('.', '').trim();
  cleanedValue = cleanedValue.replaceAll(',', '.');

  try {
    return Decimal.parse(cleanedValue);
  } catch (e) {
    return Decimal.zero;
  }
}
