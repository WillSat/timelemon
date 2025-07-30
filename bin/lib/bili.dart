import 'package:dio/dio.dart';

const int biliLimit = 50;

const biliPrompt = '《哔哩哔哩热搜榜》优先级中';

Future<String?> getStringData(Dio dio) async {
  try {
    final response = await dio.get(
      'https://api.bilibili.com/x/web-interface/wbi/search/square',
      queryParameters: {
        'limit': biliLimit,
        'platform': 'web',
        'wts': DateTime.now().millisecondsSinceEpoch ~/ 1000,
      },
      options: Options(
        headers: {
          'User-Agent':
              'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:143.0) Gecko/20100101 Firefox/143.0',
          'Referer': 'https://www.bilibili.com/',
        },
      ),
    );

    final list = (response.data?['data']?['trending']?['list'] as List?)
        ?.cast<Map>();

    // 处理数据
    if (list == null || list.isEmpty) return null;
    final content = list.map((e) => e['keyword']).join(', ');
    return '$biliPrompt\n$content';
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
