import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:convert';

class FileService {
  static Future<String> getDocumentsPath() async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  static Future<String> getCachePath() async {
    final directory = await getTemporaryDirectory();
    return directory.path;
  }

  static Future<bool> saveTextToFile(String content, String fileName) async {
    try {
      final path = await getDocumentsPath();
      final file = File('$path/$fileName');
      await file.writeAsString(content, encoding: utf8);
      return true;
    } catch (e) {
      print('Error saving file: $e');
      return false;
    }
  }

  static Future<String?> readTextFromFile(String fileName) async {
    try {
      final path = await getDocumentsPath();
      final file = File('$path/$fileName');
      if (await file.exists()) {
        return await file.readAsString(encoding: utf8);
      }
      return null;
    } catch (e) {
      print('Error reading file: $e');
      return null;
    }
  }

  static Future<bool> deleteFile(String fileName) async {
    try {
      final path = await getDocumentsPath();
      final file = File('$path/$fileName');
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      print('Error deleting file: $e');
      return false;
    }
  }

  static Future<List<String>> listFiles() async {
    try {
      final path = await getDocumentsPath();
      final directory = Directory(path);
      final files = await directory.list().toList();
      return files
          .whereType<File>()
          .map((file) => file.path.split('/').last)
          .toList();
    } catch (e) {
      print('Error listing files: $e');
      return [];
    }
  }

  static Future<void> shareFile(String content, String fileName) async {
    try {
      final path = await getCachePath();
      final file = File('$path/$fileName');
      await file.writeAsString(content, encoding: utf8);

      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'مشاركة من تطبيق الكتب الشيعية',
      );
    } catch (e) {
      print('Error sharing file: $e');
    }
  }

  static Future<Map<String, dynamic>> exportData(
      Map<String, dynamic> data) async {
    try {
      final fileName = 'backup_${DateTime.now().millisecondsSinceEpoch}.json';
      final jsonString = jsonEncode(data);
      final success = await saveTextToFile(jsonString, fileName);

      return {
        'success': success,
        'fileName': fileName,
        'path': await getDocumentsPath(),
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  static Future<Map<String, dynamic>?> importData(String fileName) async {
    try {
      final jsonString = await readTextFromFile(fileName);
      if (jsonString != null) {
        return jsonDecode(jsonString) as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      print('Error importing data: $e');
      return null;
    }
  }

  static Future<bool> fileExists(String fileName) async {
    try {
      final path = await getDocumentsPath();
      final file = File('$path/$fileName');
      return await file.exists();
    } catch (e) {
      return false;
    }
  }

  static Future<int> getFileSize(String fileName) async {
    try {
      final path = await getDocumentsPath();
      final file = File('$path/$fileName');
      if (await file.exists()) {
        return await file.length();
      }
      return 0;
    } catch (e) {
      return 0;
    }
  }
}
