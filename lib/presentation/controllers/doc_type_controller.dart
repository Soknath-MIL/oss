import 'package:appwrite/appwrite.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:oss/constants/constants.dart';

import '../../data/services/appwrite_service.dart';

class DocTypesController extends GetxController with StateMixin {
  final Account account = Account(Appwrite.instance.client);
  final Databases database = Databases(Appwrite.instance.client);
  final docTyesList = [].obs;
  final docTyesGroupList = [].obs;

  Future<void> getAllDocTypes() async {
    try {
      change(null, status: RxStatus.loading());

      var allDocTypesList = await database.listDocuments(
          databaseId: Constants.databseId,
          collectionId: Constants.docTypesId,
          queries: [
            Query.notEqual("link", "sarabun"),
            Query.notEqual("link", "appeal"),
            Query.notEqual("link", "test"),
            Query.equal("show", true),
          ]); // add group ID filter
      // add group ID filter

      debugPrint("docType data ${allDocTypesList.toString()}");
      for (var e in allDocTypesList.documents) {
        docTyesGroupList.add({...e.data});
      }

      docTyesList.value = allDocTypesList.documents;
      docTyesList.refresh();

      // if done, change status to success
      change(null, status: RxStatus.success());
    } catch (e) {
      debugPrint('this error ${e.toString()}');
      // Get.toNamed('/login');
    }
  }

  @override
  void onInit() {
    getAllDocTypes();
    super.onInit();
  }
}
