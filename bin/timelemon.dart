import 'dart:convert';
import 'dart:io';
import 'utils.dart';
import 'ds_api.dart';
import 'lib/bili.dart' as bili;
import 'lib/baidu.dart' as baidu;
import 'lib/douyin.dart' as douyin;
import 'lib/weibo.dart' as weibo;
import 'lib/zhihu.dart' as zhihu;

import 'package:dio/dio.dart';
// in/
//   - deepseek-api.key
//   - zhihu-cookie.key

void main() async {
  if (!File('in/deepseek-api.key').existsSync() ||
      !File('in/zhihu-cookie.key').existsSync()) {
    File('in/deepseek-api.key').createSync(recursive: true);
    File('in/zhihu-cookie.key').createSync(recursive: true);
    return;
  }

  // await generateWords();

  while (true) {
    await generateWords();
    log('Get ready to sleep for 3 hours.');
    sleep(Duration(hours: 3));
  }
}

Future<void> generateWords() async {
  final dio = Dio();
  final String? biliData = await bili.getStringData(dio);
  log('Got bili: ${biliData?.length}');
  final String? baiduData = await baidu.getStringData(dio);
  log('Got baidu: ${baiduData?.length}');
  final String? douyinData = await douyin.getStringData(dio);
  log('Got douyin: ${douyinData?.length}');
  final String? weiboData = await weibo.getStringData(dio);
  log('Got weibo: ${weiboData?.length}');
  final String? zhihuData = await zhihu.getStringData(dio);
  log('Got zhihu: ${zhihuData?.length}');

  final String data = [
    biliData,
    baiduData,
    douyinData,
    weiboData,
    zhihuData,
  ].join('\n\n');

  // saveToJsonFile('${makeFileName()}-RAW.txt', data);

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
    log('Error: $e');
  }
}
