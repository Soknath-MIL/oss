import 'package:appwrite/appwrite.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:oss/constants/constants.dart';

import '../../data/services/appwrite_service.dart';

class ManagementController extends GetxController {
  final Account account = Account(Appwrite.instance.client);
  final Databases database = Databases(Appwrite.instance.client);
  final mngtList = [].obs;

  Future<void> getAllManagement() async {
    try {
      var allManagementList = await database.listDocuments(
        databaseId: Constants.databseId,
        collectionId: Constants.managementTeamId,
      ); // add group ID filter
      debugPrint(allManagementList.documents[0].data.toString());
      mngtList.value = allManagementList.documents;
      mngtList.refresh();
    } catch (e) {
      debugPrint('error ${e.toString()}');
      // Get.toNamed('/login');
    }
  }

  @override
  void onInit() {
    getAllManagement();
    super.onInit();
  }
}
