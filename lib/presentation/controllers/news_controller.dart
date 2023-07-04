import 'package:appwrite/appwrite.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:oss/constants/constants.dart';

import '../../data/services/appwrite_service.dart';

class NewsController extends GetxController {
  final Account account = Account(Appwrite.instance.client);
  final Databases database = Databases(Appwrite.instance.client);
  final newsList = [].obs;

  Future<void> getAllNews() async {
    try {
      var allNewsList = await database.listDocuments(
        databaseId: Constants.databseId,
        collectionId: Constants.newsId,
        queries: [
          Query.orderDesc("\$createdAt"),
        ],
      ); // add group ID filter
      // debugPrint(allNewsList.documents[0].data.toString());
      newsList.value = allNewsList.documents;
      newsList.refresh();
    } catch (e) {
      debugPrint('error ${e.toString()}');
      // Get.toNamed('/login');
    }
  }

  @override
  void onInit() {
    getAllNews();
    super.onInit();
  }
}
