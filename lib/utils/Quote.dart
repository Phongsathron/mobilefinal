import 'dart:io';
import 'package:path_provider/path_provider.dart';

class QuoteUtils{
  static Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  static Future<File> _quoteFile(int userId) async {
    final path = await _localPath;
    return File('$path/$userId.txt');
  }

  static Future<String> readQuote(int userId) async {
    try {
      final file = await _quoteFile(userId);
      // Read the file
      String contents = await file.readAsString();
      return contents;
    } catch (e) {
      return ' ';
    }
  }

  static Future<File> writeQuote(int userId, String quote) async {
    final file = await _quoteFile(userId);
    return file.writeAsString('$quote');
  }
}