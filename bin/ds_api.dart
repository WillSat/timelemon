import 'package:dio/dio.dart';

Future<void> callDeepSeekAPI({
  required String apiKey,
  String model = "deepseek-chat",
  List<Map<String, String>> messages = const [
    {"role": "system", "content": "You are a helpful assistant."},
    {"role": "user", "content": "Hello!"},
  ],
  bool stream = false,
}) async {
  final dio = Dio();

  try {
    final response = await dio.post(
      'https://api.deepseek.com/chat/completions',
      options: Options(
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
      ),
      data: {'model': model, 'messages': messages, 'stream': stream},
    );

    print('Response status: ${response.statusCode}');
    print('Response data: ${response.data}');
  } catch (e) {
    if (e is DioException) {
      print('Dio error:');
      print('  Type: ${e.type}');
      print('  Message: ${e.message}');
      print('  Response: ${e.response?.data}');
    } else {
      print('Unexpected error: $e');
    }
  }
}
