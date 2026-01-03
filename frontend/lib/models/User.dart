import 'package:decimal/decimal.dart';

class User {
  final String name;
  final String email;
  final Decimal accountBalance;

  User({required this.name, required this.email, required this.accountBalance});

  factory User.fromJson(Map<String, dynamic> json) {
    final balance = json['account_balance'];

    return User(
      name: json['username'] as String,
      email: json['email'] as String,
      accountBalance: Decimal.parse(balance['\$numberDecimal']),
    );
  }
}
