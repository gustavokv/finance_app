import 'package:finance_app/services/api_service.dart';

Future<List<Map<String, dynamic>>> loadTransactions({
  Map<String, String>? filter,
}) async {
  try {
    final response = await ApiService.instance.get(
      '/transaction/get',
      queryParameters: filter,
    );

    if (response.data is List) {
      final List<dynamic> data = response.data;

      return data.map((item) => item as Map<String, dynamic>).toList();
    } else {
      return [];
    }
  } catch (e) {
    rethrow;
  }
}
