import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

/// 从 assets 复制文件到本地临时目录
Future<File> copyAssetToFile(String assetPath) async {
  final bytes = await rootBundle.load(assetPath);
  final dir = await getTemporaryDirectory();
  final file = File('${dir.path}/${basename(assetPath)}');
  await file.writeAsBytes(bytes.buffer.asUint8List());
  return file;
}