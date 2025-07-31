import 'dart:io';
import 'package:dio/dio.dart';

const zhihuPrompt = '##《知乎热搜榜》优先级高';

Future<String?> getStringData(Dio dio) async {
  final apiKey = File('in/zhihu-cookie.key').readAsStringSync();

  try {
    final response = await dio.get(
      'https://www.zhihu.com/api/v3/feed/topstory/hot-lists/total',
      queryParameters: {'limit': 50, 'desktop': true},
      options: Options(
        headers: {
          'Accept': 'application/json, text/plain, */*',
          // Zhihu Account: timelemon_user
          'Cookie': apiKey,
          'Host': 'www.zhihu.com',
          'Referer': 'https://www.zhihu.com/hot',
          'User-Agent':
              'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:143.0) Gecko/20100101 Firefox/143.0',
        },
      ),
    );

    final list = (response.data?['data'] as List?)?.cast<Map>();

    if (list == null || list.isEmpty) return null;
    final content = list
        .map((e) => '${e['target']['title']}\n${e['target']['excerpt']}')
        .join('\n---\n');

    return '$zhihuPrompt\n$content';
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
