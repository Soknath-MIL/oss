import 'package:appwrite/appwrite.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:oss/constants/constants.dart';

import '../../data/services/appwrite_service.dart';

class ContactUsController extends GetxController with StateMixin {
  final Account account = Account(Appwrite.instance.client);
  final Databases database = Databases(Appwrite.instance.client);
  final contactsList = [].obs;

  Future<void> getAllContact() async {
    try {
      change(null, status: RxStatus.loading());

      var allContactList = await database.listDocuments(
        databaseId: Constants.databseId,
        collectionId: Constants.contactId,
      );
      contactsList.value = allContactList.documents;
      contactsList.refresh();

      // if done, change status to success
      change(null, status: RxStatus.success());
    } catch (e) {
      debugPrint('error ${e.toString()}');
      // Get.toNamed('/login');
    }
  }

  @override
  void onInit() {
    getAllContact();
    super.onInit();
  }
}
