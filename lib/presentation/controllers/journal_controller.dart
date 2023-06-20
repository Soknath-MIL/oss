import 'package:appwrite/appwrite.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:oss/constants/constants.dart';

import '../../data/services/appwrite_service.dart';

class JournalController extends GetxController {
  final Account account = Account(Appwrite.instance.client);
  final Databases database = Databases(Appwrite.instance.client);
  final journalList = [].obs;

  Future<void> getAllJournal() async {
    try {
      var allJournalList = await database.listDocuments(
        databaseId: Constants.databseId,
        collectionId: Constants.journalId,
      ); // add group ID filter
      // debugPrint('journal ${allJournalList.documents[0].data.toString()}');
      journalList.value = allJournalList.documents;
      journalList.refresh();
    } catch (e) {
      debugPrint('error ${e.toString()}');
      // Get.toNamed('/login');
    }
  }

  @override
  void onInit() {
    getAllJournal();
    super.onInit();
  }
}
