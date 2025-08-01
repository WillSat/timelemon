import '../utils.dart';
import 'package:dio/dio.dart';

const douyinPrompt = '##《抖音热点榜》优先级高';

Future<String?> getStringData(Dio dio) async {
  try {
    final response = await dio.get(
      'https://www.douyin.com/aweme/v1/web/hot/search/list',
      options: Options(
        headers: {
          'User-Agent':
              'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:143.0) Gecko/20100101 Firefox/143.0',
          'Accept': 'application/json, text/plain, */*',
          'Referer': 'https://www.douyin.com/?recommend=1',
        },
      ),
    );

    final list = (response.data?['data']?['word_list'] as List?)?.cast<Map>();

    if (list == null || list.isEmpty) return null;
    final content = list.map((e) => e['word']).join('\n');
    return '$douyinPrompt\n$content';
  } catch (e) {
    // 错误处理
    if (e is DioException) {
      log('Request douyin error: $e');
    } else {
      log('Unexpected error: $e');
    }
    return null;
  }
}
