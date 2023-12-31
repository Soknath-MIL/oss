import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:oss/presentation/pages/pdf_viewer_page.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

import '../controllers/journal_controller.dart';

final dio = Dio();

class JournalPage extends StatefulWidget {
  const JournalPage({super.key});

  @override
  State<JournalPage> createState() => _JournalPageState();
}

class _JournalPageState extends State<JournalPage> {
  // ignore: non_constant_identifier_names
  final JournalController _JournalConroller = Get.put(JournalController());
  final errorMessageController = TextEditingController();
  bool isLoading = true;

  @override
  Widget build(BuildContext context) {
    if (errorMessageController.text.isNotEmpty) {
      return Center(child: Text(errorMessageController.text));
    }

    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('วารสาร'),
      ),
      body: Obx(
        () => SafeArea(
          child: ListView.builder(
            itemCount: _JournalConroller.journalList.length,
            itemBuilder: (ctx, i) {
              var createdAt = DateTime.parse(
                      _JournalConroller.journalList[i].data['\$createdAt'])
                  .toLocal();
              var formatted = DateFormat.yMMMMEEEEd('th').format(createdAt);
              return GestureDetector(
                onTap: () async {
                  var url = jsonDecode(_JournalConroller
                      .journalList[i].data["attachment"])[0]["url"];
                  if (url == null) {
                    Get.snackbar(
                      "ข้อผิดพลาด",
                      "ไม่พบเอกสาร",
                      duration: const Duration(seconds: 1),
                      colorText: Colors.redAccent,
                      icon: const Icon(Icons.cancel),
                      snackPosition: SnackPosition.BOTTOM,
                    );
                    return;
                  }
                  // ignore: use_build_context_synchronously
                  openPdf(context, url,
                      _JournalConroller.journalList[i].data["title"]);
                },
                child: Container(
                    height: 120,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.all(
                        Radius.circular(10),
                      ),
                      color: Colors.green.shade300,
                      boxShadow: const [
                        BoxShadow(
                          offset: Offset(0, 1),
                          color: Colors.grey,
                          blurRadius: 5,
                        )
                      ],
                    ),
                    margin: const EdgeInsets.only(top: 10, left: 10, right: 10),
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              height: 100,
                              width: 100,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(
                                    10.0), // Set the desired border radius
                                child: CachedNetworkImage(
                                  imageUrl: jsonDecode(_JournalConroller
                                          .journalList[i].data["cover"])[0]
                                      ["url"], // Replace with your image URL
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(formatted),
                                  Text(
                                    _JournalConroller
                                        .journalList[i].data["title"],
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    )),
              );
            },
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    errorMessageController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadController();
  }

  Future<void> loadController() async {
    try {
      await Get.putAsync(() async => _JournalConroller);
      setState(() {
        isLoading = false;
      });
    } catch (error) {
      setState(() {
        errorMessageController.text = 'Error: ${error.toString()}';
      });
    }
  }

  void openPdf(BuildContext context, String url, String title) =>
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => PdfViewerPage(url: url, title: title),
        ),
      );

  Future<File> _storeFile(String url, List<int> bytes) async {
    final filename = basename(url);
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$filename');
    await file.writeAsBytes(bytes, flush: true);
    if (kDebugMode) {
      print('$file');
    }
    return file;
  }
}
