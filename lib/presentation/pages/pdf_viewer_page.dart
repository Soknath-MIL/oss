import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class PdfViewerPage extends StatefulWidget {
  final File file;
  final String url;

  const PdfViewerPage({
    Key? key,
    required this.file,
    required this.url,
  }) : super(key: key);

  @override
  State<PdfViewerPage> createState() => _PdfViewerPageState();
}

class _PdfViewerPageState extends State<PdfViewerPage> {
  @override
  Widget build(BuildContext context) {
    final name = basename(widget.file.path);
    return Scaffold(
      appBar: AppBar(
        title: Text(name),
        actions: [
          IconButton(
            onPressed: () async {
              var saveSuccess = await saveFile(widget.url, "$name.pdf");
              debugPrint('saveSucess ${saveSuccess.toString()}');
              // ignore: use_build_context_synchronously
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'บันทึกสำเร็จในโฟลเดอร์ "pdf_download" ที่เก็บข้อมูลภายในได้สำเร็จ',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              );
            },
            icon: const Icon(Icons.download_rounded),
          ),
        ],
      ),
      body: PDFView(
        filePath: widget.file.path,
      ),
    );
  }

  Future<bool> saveFile(String url, String fileName) async {
    try {
      if (await _requestPermission(Permission.storage)) {
        debugPrint('New path1');
        Directory? directory;
        directory = await getExternalStorageDirectory();
        String newPath = "";
        List<String> paths = directory!.path.split("/");
        for (int x = 1; x < paths.length; x++) {
          String folder = paths[x];
          if (folder != "Android") {
            newPath += "/$folder";
          } else {
            break;
          }
        }
        debugPrint('New path2');
        newPath = "$newPath/PDF_Download";
        directory = Directory(newPath);

        File saveFile = File("${directory.path}/$fileName");
        if (kDebugMode) {
          print(saveFile.path);
        }
        if (!await directory.exists()) {
          await directory.create(recursive: true);
        }
        if (await directory.exists()) {
          await Dio().download(
            url,
            saveFile.path,
          );
        }
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> _requestPermission(Permission permission) async {
    if (await permission.isGranted) {
      return true;
    } else {
      var result = await permission.request();
      debugPrint('reasult ${result.toString()}');
      if (result == PermissionStatus.granted) {
        return true;
      }
      if (result == PermissionStatus.permanentlyDenied) {
        openAppSettings();
      }
    }
    return false;
  }
}
