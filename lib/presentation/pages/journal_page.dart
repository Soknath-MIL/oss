import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
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
                onTap: () {
                  // Download book
                },
                child: Container(
                    height: 150,
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.all(
                        Radius.circular(10),
                      ),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          offset: Offset(0, 1),
                          color: Colors.grey,
                          blurRadius: 5,
                        )
                      ],
                    ),
                    margin: const EdgeInsets.all(10),
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              height: 90,
                              width: 90,
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
                            Text(formatted),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              _JournalConroller.journalList[i].data["title"],
                              overflow: TextOverflow.ellipsis,
                            ),
                            GestureDetector(
                              onTap: () async {
                                var url = jsonDecode(_JournalConroller
                                    .journalList[i]
                                    .data["attachment"])[0]["url"];
                                debugPrint('file name: $url');
                                await EasyLoading.show(
                                  status: 'กำลังโหลด...',
                                  maskType: EasyLoadingMaskType.black,
                                );
                                final file = await loadPdfFromNetwork(url);
                                await EasyLoading.dismiss();
                                // ignore: use_build_context_synchronously
                                openPdf(
                                    context,
                                    file,
                                    url,
                                    _JournalConroller
                                        .journalList[i].data["title"]);
                              },
                              child: const Icon(
                                Icons.download,
                                color: Colors.green,
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

  Future<File> loadPdfFromNetwork(String url) async {
    final response =
        await dio.get(url, options: Options(responseType: ResponseType.bytes));
    final bytes = response.data;
    return _storeFile(url, bytes);
  }

  void openPdf(BuildContext context, File file, String url, String title) =>
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) =>
              PdfViewerPage(file: file, url: url, title: title),
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
