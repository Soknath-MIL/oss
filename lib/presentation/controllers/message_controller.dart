import 'dart:convert';

import 'package:appwrite/appwrite.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:oss/constants/constants.dart';

import '../../data/services/appwrite_service.dart';

class MessageConroller extends GetxController with StateMixin {
  final Account account = Account(Appwrite.instance.client);
  final Databases database = Databases(Appwrite.instance.client);
  final userId = ''.obs;
  final user$Id = ''.obs;
  final adminUnreadMessage = {}.obs;
  final unreadMessage = {}.obs;
  final accountData = {}.obs;

  Future<void> getUserId() async {
    await EasyLoading.show(
      status: 'ตรวจสอบผู้ใช้...',
      maskType: EasyLoadingMaskType.black,
    );
    try {
      change(null, status: RxStatus.loading());

      var accountObject = await account.get();

      userId.value = accountObject.$id;
      var userDetail = await database.getDocument(
        databaseId: Constants.databseId,
        collectionId: Constants.userId,
        documentId: accountObject.$id,
      );
      adminUnreadMessage.value = userDetail.data["adminUnreadMessage"] != null
          ? jsonDecode(userDetail.data["adminUnreadMessage"])
          : {};
      unreadMessage.value = userDetail.data["unreadMessage"] != null
          ? jsonDecode(userDetail.data["unreadMessage"])
          : {};
      user$Id.value = userDetail.$id.toString();
      accountData.value = userDetail.toMap();

      // if done, change status to success
      change(null, status: RxStatus.success());
    } catch (e) {
      debugPrint('check user error ${e.toString()}');
      EasyLoading.dismiss();
      return Get.offAndToNamed('/login');
    }

    EasyLoading.dismiss();
  }
}
