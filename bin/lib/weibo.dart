import '../utils.dart';
import 'package:dio/dio.dart';

const weiboPrompt = '##《微博热搜榜》优先级低';

Future<String?> getStringData(Dio dio) async {
  try {
    final response = await dio.get(
      'https://weibo.com/ajax/side/hotSearch',
      options: Options(
        headers: {
          'User-Agent':
              'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:143.0) Gecko/20100101 Firefox/143.0',
          'Accept': 'application/json, text/plain, */*',
          'Referer': 'https://weibo.com/',
        },
      ),
    );

    final list = (response.data?['data']?['realtime'] as List?)?.cast<Map>();

    if (list == null || list.isEmpty) return null;
    final content = list.map((e) => e['word']).join('\n');
    return '$weiboPrompt\n$content';
  } catch (e) {
    // 错误处理
    if (e is DioException) {
      log('Request weibo error: $e');
    } else {
      log('Unexpected error: $e');
    }
    return null;
  }
}
