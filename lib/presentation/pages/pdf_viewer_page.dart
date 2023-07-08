import 'dart:io';

import 'package:dio/dio.dart';
import 'package:downloads_path_provider_28/downloads_path_provider_28.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

class PdfViewerPage extends StatefulWidget {
  final String url;
  final String title;

  const PdfViewerPage({
    Key? key,
    required this.url,
    required this.title,
  }) : super(key: key);

  @override
  State<PdfViewerPage> createState() => _PdfViewerPageState();
}

class _PdfViewerPageState extends State<PdfViewerPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            onPressed: () async {
              var saveSuccess =
                  await saveFile(widget.url, "${widget.title}.pdf");
            },
            icon: const Icon(Icons.download_rounded),
          ),
        ],
      ),
      body: const PDF().cachedFromUrl(
        widget.url,
        placeholder: (progress) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const LinearProgressIndicator(),
                Text('$progress %'),
                const LinearProgressIndicator(),
              ],
            ),
          );
        },
        errorWidget: (error) => Center(child: Text(error.toString())),
      ),
    );
  }

  Future<bool> saveFile(String url, String fileName) async {
    if (await _requestPermission(Permission.storage)) {
      Directory? dir = await DownloadsPathProvider.downloadsDirectory;

      File saveFile = File("${dir?.path}/$fileName");
      if (kDebugMode) {
        print(saveFile.path);
      }
      if (await dir?.exists() != null) {
        await Dio().download(
          url,
          saveFile.path,
        );
      }
      Get.snackbar(
        "สำเร็จ",
        "บันทึกสำเร็จในโฟลเดอร์ pdf_download ที่เก็บข้อมูลภายในได้สำเร็จ",
        duration: const Duration(seconds: 1),
        colorText: Colors.grey,
        icon: const Icon(Icons.check_circle),
        snackPosition: SnackPosition.BOTTOM,
      );
      return true;
    } else {
      return false;
    }
  }

  Future<bool> _requestPermission(Permission permission) async {
    if (await permission.isGranted) {
      return true;
    } else {
      var result = await permission.request();
      debugPrint(
          'reasult ${result.toString()}, ${PermissionStatus.permanentlyDenied}');
      // ignore: unrelated_type_equality_checks
      if (result == PermissionStatus.granted) {
        return true;
      }
      // ignore: unrelated_type_equality_checks
      if (result == PermissionStatus.permanentlyDenied) {
        Get.snackbar(
          "ล้มเหลว",
          "ข้อผิดพลาดการอนุญาต",
          duration: const Duration(seconds: 1),
          colorText: Colors.white,
          icon: const Icon(Icons.check_circle),
          snackPosition: SnackPosition.BOTTOM,
        );
        openAppSettings();
      }
    }
    return false;
  }
}
