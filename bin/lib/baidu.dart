import 'package:dio/dio.dart';

const baiduPrompt = '##《百度热搜榜》优先级中';

Future<String?> getStringData(Dio dio) async {
  try {
    final response = await dio.get('https://v2.xxapi.cn/api/baiduhot');

    final list = (response.data?['data'] as List?)?.cast<Map>();

    // 处理数据
    if (list == null || list.isEmpty) return null;
    final content = list.map((e) => e['title']).join('\n');
    return '$baiduPrompt\n$content';
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
