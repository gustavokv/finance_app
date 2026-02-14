import 'package:flutter/material.dart';

final List<Map<String, dynamic>> categoryIconsList = [
  {'name': 'Alimentação', 'icon': Icons.lunch_dining_rounded},
  {'name': 'Transporte', 'icon': Icons.directions_car_rounded},
  {'name': 'Lazer', 'icon': Icons.movie_rounded},
  {'name': 'Compras', 'icon': Icons.shopping_bag_rounded},
  {'name': 'Contas', 'icon': Icons.receipt_long_rounded},
  {'name': 'Saúde', 'icon': Icons.favorite_rounded},
  {'name': 'Educação', 'icon': Icons.school_rounded},
  {'name': 'Outros', 'icon': Icons.more_horiz_rounded},

  {'name': 'Salário', 'icon': Icons.paid},
  {'name': 'Doação', 'icon': Icons.account_balance},
  {'name': 'Auxílio', 'icon': Icons.attach_money},
];

Color? stringToColor(String colorName) {
  final Map<String, Color> colors = {
    'red': Colors.red,
    'green': Colors.green,
    'blue': Colors.blue,
    'yellow': Colors.yellow,
    'orange': Colors.orange,
    'purple': Colors.purple,
    'pink': Colors.pink,
    'teal': Colors.teal,
    'cyan': Colors.cyan,
    'amber': Colors.amber,
    'lime': Colors.lime,
    'indigo': Colors.indigo,
    'brown': Colors.brown,
    'grey': Colors.grey,
    'white': Colors.white,
    'black': Colors.black,
  };

  return colors[colorName.toLowerCase()];
}

class TransactionCategory {
  final String id;
  final String title;
  final Color color;
  final String type;
  final IconData icon;

  TransactionCategory({
    required this.id,
    required this.title,
    required this.color,
    required this.type,
    required this.icon,
  });

  factory TransactionCategory.fromJson(Map<String, dynamic> json) {
    final desiredIcon = categoryIconsList.firstWhere(
      (element) => element['name'] == json['title'],
      orElse: () => categoryIconsList[categoryIconsList.length - 1],
    );

    return TransactionCategory(
      id: json['_id'] as String,
      title: json['title'] as String,
      color: stringToColor(json['color'])!,
      type: json['type'] as String,
      icon: desiredIcon['icon'] ?? Icons.more,
    );
  }
}
