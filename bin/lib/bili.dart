import 'package:dio/dio.dart';

const int biliLimit = 30;

const biliPrompt = '哔哩哔哩热搜榜';

Future<String> getStringData() async {
  final res = await getJson();
  final list = (res?['data']?['trending']?['list'] as List?)?.cast<Map>();

  // 处理数据
  if (list == null || list.isEmpty) return 'NULL';
  return '$biliPrompt\n${list.map((e) => e['keyword']).join('\n')}';
}

Future<Map?> getJson() async {
  try {
    // 发送 GET 请求
    final response = await Dio().get(
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

    return response.data;
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
