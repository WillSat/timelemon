import 'dart:convert';
import 'dart:io';

import 'package:intl/intl.dart';
import 'package:dio/dio.dart';

import 'ds_api.dart';
import 'lib/zhihu.dart' as zhihu;
import 'lib/bili.dart' as bili;
import 'lib/baidu.dart' as baidu;
import 'lib/douyin.dart' as douyin;
import 'lib/weibo.dart' as weibo;

const sysMsg = '''你是一个社会事件分析专家，从热搜条目中提取有意义的事件并准确评估其重要性，输出格式：
[{"word":<String:提练热词>,"kind":"社会民生","sign":"important"},"desc":<String:解释描述>]
1.提练热词必须是经过修饰的名词，尽量不出现句子，务必保证表达准确无歧义，不同榜单存在重复，注意合并热词。例如“我国将出现三大暴雨中心”提炼为“三大暴雨中心”、“中美新一轮经贸会谈最新进展”提炼为“中美新一轮经贸会谈”；
2.desc解释描述可以对知乎热榜中相对应的信息进行准确概括，不超过30字；没有对应的保持与word提练热词保持一致，不可虚构；
3.kind分类严谨；sign重要性评估准确。谨慎甄别剔除娱乐新闻；
4.kind可选：[政治,经济,社会民生,公共安全,文化,科技,其他]；sign可选: [important(值得关注),urgent(对中国影响较大事件),critical(战争级别,尽量不使用)]；
5.不出现```json，纯文本单行''';

// DeepSeek API Key
final apiKey = File('api.key').readAsStringSync();

void main() async {
  final dio = Dio();
  final String? zhihuData = await zhihu.getStringData(dio);
  final String? biliData = await bili.getStringData(dio);
  final String? baiduData = await baidu.getStringData(dio);
  final String? douyinData = await douyin.getStringData(dio);
  final String? weiboData = await weibo.getStringData(dio);

  final String data = [
    zhihuData,
    biliData,
    baiduData,
    douyinData,
    weiboData,
  ].join('\n\n');
  String resJson = '';

  // AI Summary
  if (biliData != null &&
      baiduData != null &&
      douyinData != null &&
      weiboData != null) {
    try {
      resJson = await callDeepSeek(data);
      final eventList = jsonDecode(resJson);

      final dt = DateTime.now();

      saveToJsonFile(
        DateFormat('yyyyMMdd#HH').format(dt),
        JsonEncoder.withIndent('    ').convert(eventList),
      );
    } catch (e) {
      print('Error: $e\n$resJson');
    }
  }
}

Future<String> callDeepSeek(String data) async {
  // 调用 DeepSeek API
  final Map? dsRes = await callDeepSeekAPI(
    apiKey,
    sysMsg,
    data,
    ifThink: false,
  );
  return dsRes?['choices'][0]?['message']['content'];
}

void saveToJsonFile(String fileName, String contents) {
  if (!Directory('out').existsSync()) {
    Directory('out').createSync(recursive: true);
  }

  File('out/$fileName.json').writeAsStringSync(contents);
  print('Finished! -> out/$fileName.json');
}
