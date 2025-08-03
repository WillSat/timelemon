import '../utils.dart';
import 'package:dio/dio.dart';

const bingPrompt = '##《Bing 热搜》优先级高';

Future<String?> getStringData(Dio dio) async {
  try {
    final response = await dio.get(
      'https://cn.bing.com/hp/api/v1/carousel?format=json',
      options: Options(
        headers: {
          'User-Agent':
              'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:143.0) Gecko/20100101 Firefox/143.0',
          'Accept': 'application/json, text/plain, */*',
          'Referer': 'https://cn.bing.com/',
        },
      ),
    );

    final list = (response.data?['data'][0]?['items'] as List?)?.cast<Map>();

    if (list == null || list.isEmpty) return null;
    final content = list.map((e) => e['title']).join('\n');
    return '$bingPrompt\n$content';
  } catch (e) {
    // 错误处理
    if (e is DioException) {
      log('Request bing error: $e');
    } else {
      log('Unexpected error: $e');
    }
    return null;
  }
}
