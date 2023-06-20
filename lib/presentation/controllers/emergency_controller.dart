import 'package:appwrite/appwrite.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:oss/constants/constants.dart';

import '../../data/services/appwrite_service.dart';

class EmergencyController extends GetxController {
  final Account account = Account(Appwrite.instance.client);
  final Databases database = Databases(Appwrite.instance.client);
  final contactList = [].obs;

  Future<void> getAllContracts() async {
    try {
      var allNewsList = await database.listDocuments(
        databaseId: Constants.databseId,
        collectionId: Constants.emergencyId,
      ); // add group ID filter
      contactList.value = allNewsList.documents;
      debugPrint('contact ${contactList[0].data.toString()}');
      contactList.refresh();
    } catch (e) {
      debugPrint('error ${e.toString()}');
      // Get.toNamed('/login');
    }
  }

  @override
  void onInit() {
    getAllContracts();
    super.onInit();
  }
}
