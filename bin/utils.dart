import 'package:intl/intl.dart';
import 'dart:io';

void log(String msg) {
  final dt = DateTime.now();
  print(
    '[${dt.month.toString().padLeft(2, '0')}/${dt.day.toString().padLeft(2, '0')} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}:${dt.second.toString().padLeft(2, '0')}] $msg',
  );
}

String makeFileName() {
  final dt = DateTime.now();
  return '${DateFormat('yyyyMMdd').format(dt)}-${dt.hour ~/ 6 + 1}';
}

void saveToJsonFile(String fileName, String contents) {
  if (!Directory('out').existsSync()) {
    Directory('out').createSync(recursive: true);
  }

  File('out/$fileName').writeAsStringSync(contents);
  log('Finished to save to file! -> out/$fileName');
}
