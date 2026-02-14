import 'package:finance_app/models/Transaction.dart';
import 'package:finance_app/models/TransactionCategory.dart';
import 'package:finance_app/widgets/transaction_tile.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:finance_app/utils/transaction.dart';
import 'package:finance_app/utils/transaction_category.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  String _selectedFilter = 'Todos'; // 'Todos', 'Receitas', 'Despesas'
  DateTimeRange? _selectedDateRange;
  bool _isLoading = false;
  List<Transaction>? _transactions;
  List<TransactionCategory>? _categories;

  @override
  void initState() {
    super.initState();
    _loadData();
    // Padrão: Mês atual
    final now = DateTime.now();
    _selectedDateRange = DateTimeRange(
      start: DateTime(now.year, now.month, 1),
      end: DateTime(now.year, now.month + 1, 0),
    );
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    final categories = await loadCategories();
    final transactions = await loadTransactions();

    if (mounted) {
      setState(() {
        _categories = categories
            .map((json) => TransactionCategory.fromJson(json))
            .toList();

        _transactions = transactions
            .map((json) => Transaction.fromJson(json))
            .toList();

        _isLoading = false;
      });
    }
  }

  // Lógica de Filtragem
  List<Transaction> get _filteredTransactions {
    return _transactions!.where((tx) {
      // Filtro de Data
      if (_selectedDateRange != null) {
        // Normaliza para comparar apenas datas, ignorando horas
        final start = DateUtils.dateOnly(_selectedDateRange!.start);
        final end = DateUtils.dateOnly(
          _selectedDateRange!.end,
        ).add(const Duration(days: 1)).subtract(const Duration(seconds: 1));

        if (tx.date.isBefore(start) || tx.date.isAfter(end)) {
          return false;
        }
      }

      // Filtro de Tipo
      if (_selectedFilter == 'Receitas' && tx.type == "EXPENSE") return false;
      if (_selectedFilter == 'Despesas' && tx.type == "INCOME") return false;

      return true;
    }).toList();
  }

  // --- UI ---

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            // 1. Cabeçalho Personalizado
            _buildHeader(context, colorScheme),

            const SizedBox(height: 16),

            // 2. Área de Filtros
            _buildFilters(context, colorScheme),

            const SizedBox(height: 16),

            // 3. Lista de Transações
            _isLoading == true || _transactions == null || _categories == null
                ? CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      ColorScheme.of(context).primary,
                    ),
                    strokeWidth: 4.0,
                  )
                : Expanded(
                    child: _filteredTransactions.isEmpty
                        ? _buildEmptyState(colorScheme)
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 10,
                            ),
                            physics: const BouncingScrollPhysics(),
                            itemCount: _filteredTransactions.length,
                            itemBuilder: (context, index) {
                              return TransactionTile(
                                transaction: _filteredTransactions[index],
                                categories: _categories!,
                              );
                            },
                          ),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Botão Voltar Estilizado
          GestureDetector(
            onTap: () => context.go('/home'),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.3,
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 20,
                color: colorScheme.onSurface,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Text(
            'Extrato Completo',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters(BuildContext context, ColorScheme colorScheme) {
    final dateFormat = DateFormat('dd MMM', 'pt_BR');
    final dateString = _selectedDateRange == null
        ? 'Todas as datas'
        : '${dateFormat.format(_selectedDateRange!.start)} - ${dateFormat.format(_selectedDateRange!.end)}';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // 1. Botão de Data (Full Width)
          GestureDetector(
            onTap: _pickDateRange,
            child: Container(
              width: double.infinity, // Ocupa toda a largura
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.5,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: colorScheme.outline.withValues(alpha: 0.1),
                ),
              ),
              child: Row(
                mainAxisAlignment:
                    MainAxisAlignment.center, // Centraliza o conteúdo
                children: [
                  Icon(
                    Icons.calendar_month_rounded,
                    size: 18,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    dateString,
                    style: TextStyle(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 18,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // 2. Filtros de Tipo (Divididos igualmente na tela)
          Row(
            children: [
              Expanded(child: _buildFilterChip('Todos', colorScheme)),
              const SizedBox(width: 8),
              Expanded(child: _buildFilterChip('Receitas', colorScheme)),
              const SizedBox(width: 8),
              Expanded(child: _buildFilterChip('Despesas', colorScheme)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, ColorScheme colorScheme) {
    final isSelected = _selectedFilter == label;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? colorScheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: isSelected
              ? Border.all(color: Colors.transparent)
              : Border.all(color: colorScheme.outline.withValues(alpha: 0.3)),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected
                ? colorScheme.onPrimary
                : colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(ColorScheme colorScheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.search_off_rounded,
              size: 48,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Nenhuma transação encontrada',
            style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 16),
          ),
          Text(
            'Tente mudar os filtros',
            style: TextStyle(
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      initialDateRange: _selectedDateRange,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              surface: Theme.of(context).colorScheme.surfaceContainerHigh,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() => _selectedDateRange = picked);
    }
  }
}
