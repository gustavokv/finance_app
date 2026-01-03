import 'package:intl/intl.dart';
import 'package:decimal/decimal.dart'; // Caso esteja usando este pacote

String formatCurrency(Decimal value) {
  NumberFormat formater = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

  // O intl requer double, então convertemos aqui
  return formater.format(value.toDouble());
}
