import 'package:finance_app/utils/format_currency.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:finance_app/utils/transaction_category.dart';
import 'package:finance_app/models/TransactionCategory.dart';
import 'package:finance_app/services/api_service.dart';
import 'package:finance_app/utils/util_snackbar.dart';

class AddTransactionModal extends StatefulWidget {
  const AddTransactionModal({super.key});

  @override
  State<AddTransactionModal> createState() => _AddTransactionModalState();
}

class _AddTransactionModalState extends State<AddTransactionModal> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  String _transactionType = "EXPENSE"; // EXPENSE ou INCOME
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;

  TransactionCategory? _selectedCategory;
  List<TransactionCategory>? _categories, _incomeCategories, _expenseCategories;

  Future<void> _loadCategories() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final categories = await loadCategories();

      if (mounted) {
        setState(() {
          _categories = categories
              .map((json) => TransactionCategory.fromJson(json))
              .toList();

          if (_categories != null && _categories!.isNotEmpty) {
            _selectedCategory = _categories![0];
          }

          _incomeCategories = _categories!
              .where((cat) => cat.type == "INCOME")
              .toList();
          _expenseCategories = _categories!
              .where((cat) => cat.type == "EXPENSE")
              .toList();

          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        // Aqui usamos dialog porque o modal ainda está aberto
        _showLocalAlert("Erro ao carregar categorias.");
      }
    }
  }

  // Helper para mostrar erros EM CIMA do modal
  void _showLocalAlert(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.error_outline_rounded, color: Colors.red.shade400),
            const SizedBox(width: 10),
            const Text("Atenção", style: TextStyle(fontSize: 18)),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              "OK",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveTransaction() async {
    FocusScope.of(context).unfocus();

    // --- INÍCIO DAS VALIDAÇÕES ---

    // 1. Validação de Título
    if (_titleController.text.trim().isEmpty) {
      _showLocalAlert("Por favor, insira um título para a transação.");
      return;
    }

    // 2. Validação de Valor
    if (_amountController.text.isEmpty) {
      _showLocalAlert("Por favor, insira um valor.");
      return;
    }

    // 3. Validação de Categoria
    if (_selectedCategory == null) {
      _showLocalAlert("Selecione uma categoria.");
      return;
    }

    // --- FIM DAS VALIDAÇÕES ---

    final Map<String, dynamic> transactionObject = {
      "title": _titleController.text.trim(),
      "description": _descriptionController.text.trim(),
      "amount": parseCurrencyBR(_amountController.text),
      "type": _transactionType,
      "category": _selectedCategory!.id,
      "date": _selectedDate.toIso8601String(),
    };

    try {
      setState(() => _isLoading = true);

      final response = await ApiService.instance.post(
        '/transaction/add',
        data: transactionObject,
      );

      final msg = response.data['message'] ?? "Transação salva com sucesso!";

      if (!mounted) return;

      // 1. Fecha o Modal PRIMEIRO
      Navigator.pop(context);

      // 2. AGORA mostra o SnackBar (ele aparecerá na Home, que agora está visível)
      UtilSnackBar.showSuccess(msg);
    } catch (error) {
      if (mounted) {
        setState(() => _isLoading = false);
        // Erro de API mantém o modal aberto, então usa Alert
        _showLocalAlert("Erro inesperado ao salvar: $error");
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Color get _activeColor => _transactionType == "EXPENSE"
      ? const Color(0xFFFF5252)
      : const Color(0xFF00C853);

  void _formatCurrency(String value) {
    String cleanedValue = value.replaceAll(RegExp(r'[^\d]'), '');

    if (cleanedValue.isEmpty) {
      _amountController.clear();
      return;
    }

    double valueDouble = double.parse(cleanedValue) / 100;

    final currencyFormatter = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: '',
      decimalDigits: 2,
    );

    String formattedValue = currencyFormatter.format(valueDouble).trim();

    _amountController.value = TextEditingValue(
      text: formattedValue,
      selection: TextSelection.collapsed(offset: formattedValue.length),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final keyboardSpace = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      height: MediaQuery.of(context).size.height * 0.90,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        children: [
          // 1. Barra de "Pega"
          Center(
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // 2. Cabeçalho com Toggle
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Cancelar',
                    style: TextStyle(color: colorScheme.onSurfaceVariant),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest.withValues(
                      alpha: 0.5,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      _buildTypeButton('Despesa', "EXPENSE"),
                      _buildTypeButton('Receita', "INCOME"),
                    ],
                  ),
                ),
                const SizedBox(width: 60),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // 3. Conteúdo Rolável
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.fromLTRB(24, 0, 24, keyboardSpace + 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- INPUT DE VALOR ---
                  Center(
                    child: Column(
                      children: [
                        Text(
                          'Valor da transação',
                          style: TextStyle(
                            color: colorScheme.onSurfaceVariant,
                            fontSize: 14,
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'R\$ ',
                              style: TextStyle(
                                fontSize: 48,
                                fontWeight: FontWeight.w500,
                                color: colorScheme.onSurface.withValues(
                                  alpha: 0.3,
                                ),
                              ),
                            ),
                            IntrinsicWidth(
                              child: TextField(
                                controller: _amountController,
                                keyboardType: TextInputType.number,
                                onChanged: _formatCurrency,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 48,
                                  fontWeight: FontWeight.bold,
                                  color: _activeColor,
                                  letterSpacing: -1.0,
                                ),
                                decoration: InputDecoration(
                                  hintText: '0,00',
                                  hintStyle: TextStyle(
                                    color: colorScheme.onSurface.withValues(
                                      alpha: 0.1,
                                    ),
                                  ),
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // --- LINHA 1: TÍTULO E DATA ---
                  Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: _ModernTextField(
                          controller: _titleController,
                          label: 'Título',
                          icon: Icons.title_rounded,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: GestureDetector(
                          onTap: _pickDate,
                          child: Container(
                            height: 60,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: colorScheme.surfaceContainerHighest
                                  .withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: colorScheme.outline.withValues(
                                  alpha: 0.05,
                                ),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.calendar_today_rounded,
                                  size: 18,
                                  color: colorScheme.primary,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  DateFormat(
                                    'd MMM',
                                    'pt_BR',
                                  ).format(_selectedDate),
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: colorScheme.onSurface,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // --- LINHA 2: DESCRIÇÃO ---
                  _ModernTextField(
                    controller: _descriptionController,
                    label: 'Descrição (Opcional)',
                    icon: Icons.notes_rounded,
                  ),

                  const SizedBox(height: 24),

                  // --- SELEÇÃO DE CATEGORIA ---
                  Text(
                    'Categoria',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // GRID DE CATEGORIAS
                  _isLoading
                      ? Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              ColorScheme.of(context).primary,
                            ),
                            strokeWidth: 4.0,
                          ),
                        )
                      : GridView.builder(
                          padding: EdgeInsets.zero,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 4,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 16,
                                childAspectRatio: 0.75,
                              ),
                          itemCount: _transactionType == "EXPENSE"
                              ? (_expenseCategories?.length ?? 0)
                              : (_incomeCategories?.length ?? 0),
                          itemBuilder: (context, index) {
                            final cat = _transactionType == "EXPENSE"
                                ? _expenseCategories![index]
                                : _incomeCategories![index];
                            final isSelected =
                                _selectedCategory?.title == cat.title;
                            return _buildCategoryItem(
                              cat,
                              isSelected,
                              colorScheme,
                            );
                          },
                        ),

                  const SizedBox(height: 40),

                  // --- BOTÃO DE SALVAR ---
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        _saveTransaction();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _activeColor,
                        foregroundColor: Colors.white,
                        elevation: 8,
                        shadowColor: _activeColor.withValues(alpha: 0.4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 3,
                              ),
                            )
                          : const Text(
                              'SALVAR TRANSAÇÃO',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.0,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGETS AUXILIARES ---

  Widget _buildTypeButton(String label, String typeKey) {
    final isSelected = _transactionType == typeKey;
    return GestureDetector(
      onTap: () {
        setState(() => _transactionType = typeKey);

        if (typeKey == "EXPENSE" &&
            _expenseCategories != null &&
            _expenseCategories!.isNotEmpty) {
          _selectedCategory = _expenseCategories![0];
        } else if (typeKey == "INCOME" &&
            _incomeCategories != null &&
            _incomeCategories!.isNotEmpty) {
          _selectedCategory = _incomeCategories![0];
        } else {
          _selectedCategory = null;
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? _activeColor : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? Colors.white
                : Theme.of(context).colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryItem(
    TransactionCategory cat,
    bool isSelected,
    ColorScheme colorScheme,
  ) {
    return GestureDetector(
      onTap: () {
        setState(() => _selectedCategory = cat);
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: isSelected
                  ? _activeColor.withValues(alpha: 0.1)
                  : colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              shape: BoxShape.circle,
              border: isSelected
                  ? Border.all(color: _activeColor, width: 2)
                  : Border.all(color: Colors.transparent),
            ),
            child: Icon(
              cat.icon,
              color: isSelected ? _activeColor : colorScheme.onSurfaceVariant,
              size: 26,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            cat.title,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              color: isSelected ? _activeColor : colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        final theme = Theme.of(context);
        return Theme(
          data: theme.copyWith(
            colorScheme: theme.colorScheme.copyWith(
              primary: _activeColor,
              onPrimary: Colors.white,
              surface: theme.colorScheme.surfaceContainerHigh,
              onSurface: theme.colorScheme.onSurface,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: _activeColor),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }
}

class _ModernTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;

  const _ModernTextField({
    required this.controller,
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextField(
        controller: controller,
        style: TextStyle(
          color: colorScheme.onSurface,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
          prefixIcon: Icon(icon, color: colorScheme.onSurfaceVariant),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
    );
  }
}
