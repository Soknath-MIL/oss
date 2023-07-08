import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:oss/presentation/pages/pdf_viewer_page.dart';

import '../controllers/open_access_controller.dart';

final dio = Dio();

class OpenAccessPage extends StatefulWidget {
  const OpenAccessPage({super.key});

  @override
  State<OpenAccessPage> createState() => _OpenAccessPageState();
}

class _OpenAccessPageState extends State<OpenAccessPage> {
  // ignore: non_constant_identifier_names
  final OpenAccessController _JournalConroller =
      Get.put(OpenAccessController());
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
        title: const Text('เอกสารดาวน์โหลด'),
      ),
      body: Obx(
        () => SafeArea(
          child: ListView.builder(
            itemCount: _JournalConroller.openAccessList.length,
            itemBuilder: (ctx, i) {
              var createdAt = DateTime.parse(
                      _JournalConroller.openAccessList[i].data['\$createdAt'])
                  .toLocal();
              var formatted = DateFormat.yMMMMEEEEd('th').format(createdAt);
              return GestureDetector(
                onTap: () {
                  // Download book
                },
                child: GestureDetector(
                  onTap: () async {
                    var url = jsonDecode(_JournalConroller
                        .openAccessList[i].data["attachment"])[0]["url"];
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
                        _JournalConroller.openAccessList[i].data["title"]);
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
                      margin:
                          const EdgeInsets.only(top: 10, left: 10, right: 10),
                      padding: const EdgeInsets.all(10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            height: 100,
                            width: 100,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(
                                  10.0), // Set the desired border radius
                              child: Image.asset(
                                "assets/images/docs.png", // Replace with your image URL
                                fit: BoxFit.fitWidth,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(formatted),
                                Text(
                                  _JournalConroller
                                      .openAccessList[i].data["title"],
                                  overflow: TextOverflow.ellipsis,
                                )
                              ],
                            ),
                          ),
                        ],
                      )),
                ),
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
}
