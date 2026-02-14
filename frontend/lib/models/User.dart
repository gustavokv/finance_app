import 'package:decimal/decimal.dart';

class User {
  final String name;
  final String email;
  final Decimal accountBalance;
  final Decimal thisMonthIncomes;
  final Decimal thisMonthExpenses;

  User({
    required this.name,
    required this.email,
    required this.accountBalance,
    required this.thisMonthIncomes,
    required this.thisMonthExpenses,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    final balance = json['accountBalance'];

    return User(
      name: json['name'] as String,
      email: json['email'] as String,
      accountBalance: Decimal.parse(balance['\$numberDecimal']),
      thisMonthIncomes: Decimal.parse(json['thisMonthIncomes']),
      thisMonthExpenses: Decimal.parse(json['thisMonthExpenses']),
    );
  }
}
