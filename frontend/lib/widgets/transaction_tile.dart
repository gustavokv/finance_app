// Componente de Card Individual (Transformado em Stateless)
import 'package:finance_app/models/Transaction.dart';
import 'package:finance_app/models/TransactionCategory.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TransactionTile extends StatelessWidget {
  final Transaction transaction;
  final List<TransactionCategory> categories;
  final bool isLast;

  const TransactionTile({
    super.key,
    required this.transaction,
    required this.categories,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    final selectedCategory = categories.firstWhere(
      (cat) => cat.id == transaction.category,
      orElse: () => TransactionCategory(
        id: 'unknown',
        title: 'Desconhecido',
        color: Colors.grey,
        icon: Icons.help_outline_rounded,
        type: transaction.type,
      ),
    );

    final bool isExpense = transaction.type == "EXPENSE";
    final formatter = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: EdgeInsets.only(bottom: isLast ? 0 : 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              // Usamos a variável local selectedCategory
              color: (selectedCategory.color).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              selectedCategory.icon,
              color: selectedCategory.color,
              size: 22,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: colorScheme.onSurface,
                  ),
                ),
                Text(
                  selectedCategory.title,
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                formatter.format(transaction.amount.toDouble()),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: isExpense
                      ? Colors.red.shade400
                      : Colors.green.shade600,
                ),
              ),
              Text(
                DateFormat('d MMM', 'pt_BR').format(transaction.date),
                style: TextStyle(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
