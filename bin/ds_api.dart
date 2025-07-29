import 'package:dio/dio.dart';

Future callDeepSeekAPI(
  String apiKey,
  String sysMsg,
  String userMsg, {
  String model = "deepseek-chat", // DeepSeek-V3
  bool stream = false,
}) async {
  // 构建消息体
  final List<Map<String, String>> messages = [
    {"role": "system", "content": sysMsg},
    {"role": "user", "content": userMsg},
  ];

  try {
    final response = await Dio().post(
      'https://api.deepseek.com/chat/completions',
      options: Options(
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
      ),
      data: {'model': model, 'messages': messages, 'stream': stream},
    );

    return response.data;
  } catch (e) {
    // 错误处理
    if (e is DioException) {
      print('Dio error: $e');
    } else {
      print('Unexpected error: $e');
    }
    return null;
  }
}
