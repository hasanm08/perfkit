import 'dart:io';

import 'package:path_provider/path_provider.dart';

Future<String?> readJson(String name) async {
  final dir = await getApplicationSupportDirectory();
  final file = File('${dir.path}/$name');
  if (!await file.exists()) return null;
  return file.readAsString();
}

Future<void> writeJson(String name, String json) async {
  final dir = await getApplicationSupportDirectory();
  final file = File('${dir.path}/$name');
  await file.writeAsString(json);
}
