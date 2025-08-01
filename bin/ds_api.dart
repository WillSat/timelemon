import 'dart:io';

import 'package:dio/dio.dart';

import 'utils.dart';

const sysMsg = '''你是一个社会事件分析专家，从热搜条目中选取较有意义的事件并评估其重要性，输出格式：
[{"word":<String:提练热词>,"kind":"社会民生","sign":"important"},"desc":<String:解释描述>]
1.提练热词必须是经过修饰的名词，尽量不出现句子，务必保证表达准确无歧义，不同榜单存在重复，注意合并热词。例如“我国将出现三大暴雨中心”提炼为“三大暴雨中心”、“中美新一轮经贸会谈最新进展”提炼为“中美新一轮经贸会谈”；
2.desc解释描述可以对知乎热榜中相对应的信息进行50字左右准确概括，禁止虚构；标点符号应该齐全，如句末句号；
3.kind分类严谨；sign重要性评估准确。甄别剔除娱乐新闻；
4.kind可选：[政治,经济,社会民生,公共安全,文化,科技,其他]；sign可选: [important(值得关注),urgent(影响较大事件),critical(战争级别,尽量不使用)]；
5.条目数量不限，符合上述条件都可以；
6.禁止输出```json，纯文本JSON格式单行输出''';

// DeepSeek API Key
final apiKey = File('in/deepseek-api.key').readAsStringSync();

Future<String> callDeepSeek(String data) async {
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
      data: {'model': model, 'messages': messages, 'stream': stream},
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
