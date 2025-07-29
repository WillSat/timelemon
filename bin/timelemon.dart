import 'package:dio/dio.dart';
import 'lib/bili_rank.dart' as bili_rank;

void main() async {
  final biliRankData = await bili_rank.getStringData();
  print(biliRankData);

  // 替换成你的 DeepSeek API Key
  const apiKey = '<DeepSeek API Key>';

  // 调用 DeepSeek API
}
