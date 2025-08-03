import 'dart:io';

import 'package:dio/dio.dart';

import 'utils.dart';

Future<String> callDeepSeek(String data) async {
  // prompt
  final sysMsg = File('in/prompt-system.txt').readAsStringSync();
  // DeepSeek API Key
  final apiKey = File('in/deepseek-api.key').readAsStringSync();

  final Map? dsRes = await callDeepSeekAPI(
    apiKey,
    sysMsg,
    data,
    ifThink: false,
  );
  // 默认选择第一个回答
  return dsRes?['choices'][0]?['message']['content'];
}

Future callDeepSeekAPI(
  String apiKey,
  String sysMsg,
  String userMsg, {
  bool ifThink = false,
  bool stream = false,
}) async {
  // 构建消息体
  final List<Map<String, String>> messages = [
    {"role": "system", "content": sysMsg},
    {"role": "user", "content": userMsg},
  ];

  final model = ifThink ? 'deepseek-reasoner' : 'deepseek-chat';

  try {
    final response = await Dio().post(
      'https://api.deepseek.com/chat/completions',
      options: Options(
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
      ),
      data: {
        'model': model,
        'messages': messages,
        'stream': stream,
        'response_format': {'type': 'json_object'},
      },
    );

    return response.data;
  } catch (e) {
    // 错误处理
    if (e is DioException) {
      log('Request deepseek API error: $e');
    } else {
      log('Unexpected error: $e');
    }
    return null;
  }
}
