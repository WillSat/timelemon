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

  // Loop
  while (true) {
    final st = DateTime.now().millisecondsSinceEpoch;
    final wasSuccess = await generateWords();

    if (wasSuccess) {
      final sleepTime =
          Duration(hours: 3) -
          Duration(milliseconds: DateTime.now().millisecondsSinceEpoch - st);
      log('Get ready to sleep for $sleepTime hours.');
      sleep(sleepTime);
    } else {
      final sleepTime =
          Duration(minutes: 3) -
          Duration(milliseconds: DateTime.now().millisecondsSinceEpoch - st);
      log('Get ready to sleep for $sleepTime minutes.');
      sleep(sleepTime);
    }
  }
}

Future<bool> generateWords() async {
  final dio = Dio();

  final results = await Future.wait([
    bili.getStringData(dio),
    baidu.getStringData(dio),
    douyin.getStringData(dio),
    weibo.getStringData(dio),
    zhihu.getStringData(dio),
  ]);

  log(
    'Got result: bl:${results[0]?.length} bd:${results[1]?.length} dy:${results[2]?.length} wb:${results[3]?.length} zh:${results[4]?.length}',
  );

  final String data = [
    results[0],
    results[1],
    results[2],
    results[3],
    results[4],
  ].join('\n\n');

  // saveToJsonFile('${makeFileName()}-RAW.txt', data);

  String resJson = '';

  // AI Summary
  try {
    resJson = await callDeepSeek(data);
    final List? eventList = jsonDecode(resJson)['list'];
    if (eventList == null) throw Error();

    saveToJsonFile(
      '${makeFileName()}.json',
      JsonEncoder.withIndent('    ').convert(eventList),
    );

    saveToJsonFile(
      'last_update.txt',
      DateTime.now().millisecondsSinceEpoch.toString(),
    );

    return true;
  } catch (e) {
    log('JSON respond error! Returning false to the loop.');
    return false;
  }
}
