import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class FileDownloadService {
  /// Request storage permission
  static Future<bool> requestPermission() async {
    if (Platform.isAndroid) {
      // For Android 11 (API 30) and above
      if (await Permission.manageExternalStorage.isGranted) {
        return true;
      }

      // For Android 10 and below
      if (await Permission.storage.isGranted) {
        return true;
      }

      // Check SDK version
      // In a real app we would check android.os.Build.VERSION.SDK_INT
      // But for simplicity in Flutter, we request both and handle the result

      var status = await Permission.storage.request();
      if (status.isGranted) {
        return true;
      }

      // Try manage external storage for Android 11+
      status = await Permission.manageExternalStorage.request();
      if (status.isGranted) {
        return true;
      }

      return false;
    }
    return true; // iOS doesn't need explicit storage permission for app documents
  }

  /// Get download directory path
  static Future<String?> getDownloadPath() async {
    Directory? directory;
    try {
      if (Platform.isIOS) {
        directory = await getApplicationDocumentsDirectory();
      } else {
        // Android: Try to get the public downloads directory
        directory = Directory('/storage/emulated/0/Download');
        // Fallback if that doesn't exist (e.g. emulator sometimes)
        if (!await directory.exists()) {
          directory = await getExternalStorageDirectory();
        }
      }
    } catch (e) {
      debugPrint("Error getting download path: $e");
    }
    return directory?.path;
  }

  /// Save file buffer to downloads and open it
  static Future<String?> saveFile(
    String fileName,
    List<int> bytes,
    String mimeType,
    dynamic OpenFile,
  ) async {
    try {
      if (!await requestPermission()) {
        debugPrint("Storage permission denied");
        return null;
      }

      String? path = await getDownloadPath();
      if (path == null) {
        debugPrint("Could not access storage directory");
        return null;
      }

      // Ensure directory exists
      final dir = Directory(path);
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }

      // Create unique filename if exists
      String filePath = '$path/$fileName';
      File file = File(filePath);

      int i = 1;
      while (await file.exists()) {
        final nameParts = fileName.split('.');
        final ext = nameParts.length > 1 ? '.${nameParts.last}' : '';
        final name = nameParts
            .take(nameParts.length - (nameParts.length > 1 ? 1 : 0))
            .join('.');
        filePath = '$path/$name ($i)$ext';
        file = File(filePath);
        i++;
      }

      // Write file
      await file.writeAsBytes(bytes);
      debugPrint("File saved to: $filePath");

      // Open file
      final result = await OpenFile.open(filePath, type: mimeType);
      debugPrint("Open file result: ${result.message}");

      return filePath;
    } catch (e) {
      debugPrint("Error saving file: $e");
      return null;
    }
  }
}


