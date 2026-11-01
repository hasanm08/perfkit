import 'dart:io';

import 'package:path_provider/path_provider.dart';

Future<String?> readProgressJson() async {
  final file = await _file();
  if (!await file.exists()) return null;
  return file.readAsString();
}

Future<void> writeProgressJson(String json) async {
  final file = await _file();
  await file.writeAsString(json);
}

Future<File> _file() async {
  final dir = await getApplicationSupportDirectory();
  return File('${dir.path}/perfkit_progress.json');
}
