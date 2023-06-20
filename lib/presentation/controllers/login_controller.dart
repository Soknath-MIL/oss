import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:oss/data/services/appwrite_service.dart';

import '../../data/services/firebase_service.dart';

class LoginController extends GetxController {
  final FirebaseService _firebaseService = FirebaseService();

  final phoneNumber = '+66830232090'.obs;

  void onPhoneNumberChanged(String value) {
    phoneNumber.value = value;
  }

  void signInWithCredential(String verificationId, smsCode) async {
    PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId, smsCode: smsCode);
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);
      // validate account
      var user = await AppwriteService().tryLogin();
      await EasyLoading.show(
        status: 'ตรวจสอบผู้ใช้...',
        maskType: EasyLoadingMaskType.black,
      );
      if (user != null) {
        EasyLoading.dismiss();
        return Get.toNamed("/main");
      }
      EasyLoading.dismiss();
      Get.snackbar(
        "ไม่พบผู้ใช้",
        "โปรดเพิ่มข้อมูลเพิ่มเติม",
        colorText: Colors.white,
        backgroundColor: Colors.lightBlue,
        icon: const Icon(Icons.cancel),
        duration: const Duration(seconds: 1),
        snackPosition: SnackPosition.BOTTOM,
      );
      Get.toNamed('validate-account', arguments: [phoneNumber]);
    } on FirebaseAuthException catch (e) {
      // Handle authentication failed error
      print(e.message);
    }
  }

  void signInWithPhoneNumber(String number) async {
    await EasyLoading.show(
      status: 'กำลังโหลด...',
      maskType: EasyLoadingMaskType.black,
    );
    await _firebaseService.signInWithPhoneNumber(number);
    await EasyLoading.dismiss();
  }
}
