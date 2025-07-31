import 'dart:convert';
import 'dart:io';

import 'package:intl/intl.dart';
import 'package:dio/dio.dart';

import 'ds_api.dart';
import 'lib/bili.dart' as bili;
import 'lib/baidu.dart' as baidu;
import 'lib/douyin.dart' as douyin;
import 'lib/weibo.dart' as weibo;
import 'lib/zhihu.dart' as zhihu;

const sysMsg = '''你是一个社会事件分析专家，从热搜条目中选取较有意义的事件并评估其重要性，输出格式：
[{"word":<String:提练热词>,"kind":"社会民生","sign":"important"},"desc":<String:解释描述>]
1.提练热词必须是经过修饰的名词，尽量不出现句子，务必保证表达准确无歧义，不同榜单存在重复，注意合并热词。例如“我国将出现三大暴雨中心”提炼为“三大暴雨中心”、“中美新一轮经贸会谈最新进展”提炼为“中美新一轮经贸会谈”；
2.desc解释描述可以对知乎热榜中相对应的信息进行50字左右准确概括，禁止虚构；标点符号应该齐全，如句末句号；
3.kind分类严谨；sign重要性评估准确。甄别剔除娱乐新闻；
4.kind可选：[政治,经济,社会民生,公共安全,文化,科技,其他]；sign可选: [important(值得关注),urgent(影响较大事件),critical(战争级别,尽量不使用)]；
5.条目数量不限，符合上述条件都可以；
6.纯文本JSON格式单行输出，禁止输出```json之类的修饰内容''';

// in/
//   - deepseek-api.key
//   - zhihu-cookie.key

// DeepSeek API Key
final apiKey = File('in/deepseek-api.key').readAsStringSync();

void main() async {
  await generateWords();
}

Future<void> generateWords() async {
  final dio = Dio();
  final String? biliData = await bili.getStringData(dio);
  print('- bili: ${biliData?.length}');
  final String? baiduData = await baidu.getStringData(dio);
  print('- baidu: ${baiduData?.length}');
  final String? douyinData = await douyin.getStringData(dio);
  print('- douyin: ${douyinData?.length}');
  final String? weiboData = await weibo.getStringData(dio);
  print('- weibo: ${weiboData?.length}');
  final String? zhihuData = await zhihu.getStringData(dio);
  print('- zhihu: ${zhihuData?.length}');

  final String data = [
    biliData,
    baiduData,
    douyinData,
    weiboData,
    zhihuData,
  ].join('\n\n');

  String makeFileName() {
    final dt = DateTime.now();
    return '${DateFormat('yyyyMMdd').format(dt)}-${dt.hour ~/ 6 + 1}';
  }

  saveToJsonFile('${makeFileName()}-RAW.txt', data);

  String resJson = '';
  // AI Summary
  try {
    resJson = await callDeepSeek(data);
    final eventList = jsonDecode(resJson);

    saveToJsonFile(
      '${makeFileName()}.json',
      JsonEncoder.withIndent('    ').convert(eventList),
    );
  } catch (e) {
    print('- Error: $e');
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
  // 默认选择第一个回答
  return dsRes?['choices'][0]?['message']['content'];
}

void saveToJsonFile(String fileName, String contents) {
  if (!Directory('out').existsSync()) {
    Directory('out').createSync(recursive: true);
  }

  File('out/$fileName').writeAsStringSync(contents);
  print('- Finished! -> out/$fileName');
}
