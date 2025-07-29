import 'dart:convert';
import 'dart:io';

import 'ds_api.dart';
import 'lib/bili.dart' as bili;

const sysMsg = '''你是一个社会事件分析者，挑选较有意义的事件并准确评估重要性，输出格式：
[{"event":<String:事件名称>,"category":"社会民生","sign":"important"}]
1.事件名称需要能够准确概括事件，用词准确客观
2.category可选：[政治,经济,社会民生,公共安全,文化,科技,其他]
3.sign可选: [important(值得关注),urgent(影响较大事件,少使用),critical(战争级别,尽量不使用)]
4.不出现```json，纯文本单行''';

// DeepSeek API Key
final apiKey = File('api.key').readAsStringSync();

void main() async {
  final biliData = await bili.getStringData();

  // bili
  try {
    final eventList = jsonDecode(await callDeepSeek(biliData));
    saveToJsonFile(
      'bili-${DateTime.now().millisecondsSinceEpoch ~/ 1000}',
      jsonEncode(eventList),
    );
  } catch (e) {
    print('Error: $e');
  }
}

Future<String> callDeepSeek(String data) async {
  // 调用 DeepSeek API
  final Map? dsRes = await callDeepSeekAPI(apiKey, sysMsg, data);
  return dsRes?['choices'][0]?['message']['content'];
  // [{"event":"北京因灾死亡30人","category":"公共安全","sign":"important"},{"event":"育儿补贴释放什么信号","category":"社会民生","sign":"important"},{"event":"北方暴雨为何如此猛烈","category":"社会民生","sign":"important"},{"event":"如何看待武大图书馆诬告案","category":"社会民生","sign":"important"},{"event":"台风竹节草实时路径","category":"公共安全","sign":"important"}]
}

void saveToJsonFile(String fileName, String contents) {
  if (!Directory('out').existsSync()) {
    Directory('out').createSync(recursive: true);
  }

  File('out/$fileName.json').writeAsStringSync(contents);
}
