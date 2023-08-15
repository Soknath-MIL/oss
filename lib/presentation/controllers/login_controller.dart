import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:oss/data/services/appwrite_service.dart';

import '../../data/services/firebase_service.dart';

class LoginController extends GetxController {
  final FirebaseService _firebaseService = FirebaseService();

  final phoneNumber = ''.obs;

  void onPhoneNumberChanged(String value) {
    debugPrint(value);
    phoneNumber.value =
        value.replaceAll("+660", "+66"); // remove 0 from phone number
  }

  void signInWithCredential(String verificationId, smsCode) async {
    PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId, smsCode: smsCode);
    try {
      await FirebaseAuth.instance.signInWithCredential(credential);
      debugPrint('Credential $credential');
      Get.snackbar(
        "สำเร็จ",
        "OTP ถูกต้อง",
        colorText: Colors.white,
        icon: const Icon(Icons.check_circle),
        duration: const Duration(seconds: 1),
        snackPosition: SnackPosition.BOTTOM,
      );
      // validate account
      var user = await AppwriteService().tryLogin(phoneNumber);
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
        icon: const Icon(Icons.cancel),
        duration: const Duration(seconds: 1),
        snackPosition: SnackPosition.BOTTOM,
      );
      Get.toNamed('validate-account', arguments: [phoneNumber]);
    } on FirebaseAuthException {
      // Handle authentication failed error
      Get.snackbar(
        "ข้อผิดพลาด",
        "OTP ไม่ถูกต้อง",
        colorText: Colors.white,
        icon: const Icon(Icons.cancel),
        duration: const Duration(seconds: 1),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> signInWithPhoneNumber(String number) async {
    await _firebaseService.signInWithPhoneNumber(number);
  }
}
