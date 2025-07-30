import 'package:dio/dio.dart';

const zhihuPrompt = '《知乎热搜榜》优先级高';

Future<String?> getStringData(Dio dio) async {
  try {
    final response = await dio.get(
      'https://www.zhihu.com/api/v3/feed/topstory/hot-lists/total',
      queryParameters: {'limit': 50, 'desktop': true},
      options: Options(
        headers: {
          'Accept': 'application/json, text/plain, */*',
          'Cookie':
              '_xsrf=nTRUfPE0j6I7UF4X3EFmQXEkGnfQJoza;__zse_ck=004_SgI=1fOXsPFX5b82Uvv6fgAouLqOn9UeZH9mMcMhtwrtqfqERhlTtImuPklbAs4YDzki1=pEVoeDYMbwEgCQjJ6IT/9rJ1DYJMGPAdByviEi9SdWBT1b/UPPIzPk/=cY-tFreMWgFTNdoUGrWilmFP02NnbHEmeEW05h0oVNk7sITQe9s23SvPTcUeei/gZuNjt7A7PSs4PZwl7pjc0SqGTLKgx2FjOmxSdZHxIt4ubw9qXt0wg9iXLSOAU/HAcwE; _zap=7d417b56-3674-45e3-8155-6015474d1984; d_c0=FgQUo-rXaxqPTih_GgWysktBrVGmK5CmKok=|1746693848; Hm_lvt_98beee57fd2ef70ccdd5ca52b9740c49=1746693853; z_c0=2|1:0|10:1753784155|4:z_c0|80:MS4xRHlUZFV3QUFBQUFtQUFBQVlBSlZUUUJpYjJuS09lYV9pVXZlZFVFRUphS3RxR19LU3JHNWp3PT0=|99bdd65d772c71df361b969bb6b49e468d6aa31532dcc275037154f6c28bfcd4; Hm_lpvt_98beee57fd2ef70ccdd5ca52b9740c49=1746697651; HMACCOUNT=05DBFFDDB33E513F;SESSIONID=lahfElBUPvRMhQT3r7rDrMxWa5sgdrU3QPBTXJXTtFQ;BEC=244e292b1eefcef20c9b81b1d9777823;q_c1=ae5fe315569b49e9ab52e3fbd64b3078|1753850910000|1753850910000; tst=h',
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
        .map((e) => '${e['target']['title']}: ${e['target']['excerpt']}')
        .join('\n');

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
