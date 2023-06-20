import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../controllers/news_controller.dart';

class NewsPage extends StatefulWidget {
  const NewsPage({super.key});

  @override
  State<NewsPage> createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage> {
  // ignore: non_constant_identifier_names
  final NewsController _NewsConroller = Get.put(NewsController());
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
        title: const Text('ข่าวสาร'),
      ),
      body: Obx(
        () => SafeArea(
          child: GridView.builder(
            shrinkWrap: true,
            padding: const EdgeInsets.all(8),
            itemCount: _NewsConroller.newsList.length,
            itemBuilder: (ctx, i) {
              var createdAt =
                  DateTime.parse(_NewsConroller.newsList[i].data['\$createdAt'])
                      .toLocal();
              var formatted = DateFormat.yMMMMEEEEd('th').format(createdAt);
              return GestureDetector(
                onTap: () {
                  Get.toNamed("/news-detail",
                      arguments: [_NewsConroller.newsList[i].data]);
                },
                child: Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Container(
                    height: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    margin: const EdgeInsets.all(5),
                    padding: const EdgeInsets.all(5),
                    child: Stack(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            SizedBox(
                              height: 100,
                              child: ClipRRect(
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(10)),
                                child: CachedNetworkImage(
                                  imageUrl: jsonDecode(_NewsConroller
                                      .newsList[i].data['images'])[0]["url"],
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Text(
                              formatted,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.end,
                              style: const TextStyle(
                                fontSize: 10,
                              ),
                            ),
                            Expanded(
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      _NewsConroller.newsList[i].data['title'],
                                      textAlign: TextAlign.start,
                                      softWrap: true,
                                      style: const TextStyle(
                                        fontSize: 15,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.0,
              crossAxisSpacing: 0.0,
              mainAxisSpacing: 5,
              mainAxisExtent: 250,
            ),
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
      await Get.putAsync(() async => _NewsConroller);
      setState(() {
        isLoading = false;
      });
    } catch (error) {
      setState(() {
        errorMessageController.text = 'Error: ${error.toString()}';
      });
    }
  }
}
