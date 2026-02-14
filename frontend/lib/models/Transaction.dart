import 'package:decimal/decimal.dart';

class Transaction {
  final String title;
  final String? description;
  final Decimal amount;
  final String type;
  final String category;
  final DateTime date;

  Transaction({
    required this.title,
    this.description,
    required this.amount,
    required this.type,
    required this.category,
    required this.date,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> amount = json['amount'];

    return Transaction(
      title: json['title'] as String,
      description: json['description'] as String,
      amount: Decimal.parse(amount['\$numberDecimal']),
      type: json['type'] as String,
      category: json['category'] as String,
      date: DateTime.parse(json['date']),
    );
  }
}
