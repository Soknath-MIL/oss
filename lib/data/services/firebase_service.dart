import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:get/get.dart';

import '../../presentation/widgets/bottom_pin.dart';

class FirebaseService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  void signInWithCredential(String verificationId, String smsCode) async {
    PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId, smsCode: smsCode);
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);
      Get.offAllNamed('/home');
    } on FirebaseAuthException catch (e) {
      // Handle authentication failed error
      print(e.message);
    }
  }

  Future<bool> signInWithCredentialNoRedirect(
      String verificationId, String smsCode) async {
    PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId, smsCode: smsCode);
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);
      return true;
    } on FirebaseAuthException catch (e) {
      // Handle authentication failed error
      print(e.message);
      return false;
    }
  }

  Future<String?> signInWithPhoneNumber(String phoneNumber) async {
    try {
      await _firebaseAuth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await _firebaseAuth.signInWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          Get.snackbar(
            "ข้อผิดพลาด",
            "ส่ง ล้มเหลว",
            colorText: Colors.white,
            icon: const Icon(Icons.cancel),
            duration: const Duration(seconds: 1),
            snackPosition: SnackPosition.BOTTOM,
          );
          debugPrint(e.message);
        },
        codeSent: (String verificationId, int? resendToken) {
          Get.toNamed('/verify-otp', arguments: [phoneNumber, verificationId]);
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
      );
      return null;
    } catch (e) {
      Get.snackbar(
        "ข้อผิดพลาด",
        "ส่ง ล้มเหลว",
        colorText: Colors.white,
        icon: const Icon(Icons.cancel),
        duration: const Duration(seconds: 1),
        snackPosition: SnackPosition.BOTTOM,
      );
      debugPrint(e.toString());
    }
    return null;
  }

  Future<void> signInWithPhoneNumberNoRedirect(
      String phoneNumber, FormBuilderState data, BuildContext context) async {
    await _firebaseAuth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        await _firebaseAuth.signInWithCredential(credential);
      },
      verificationFailed: (FirebaseAuthException e) {
        debugPrint(e.message);
      },
      codeSent: (String verificationId, int? resendToken) {
        debugPrint('code sent $verificationId');
        showModalBottomSheet(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          backgroundColor: Colors.white,
          builder: (BuildContext context) {
            debugPrint('phone 2 ${data.value.toString()}');
            return BottomSheetPin(data: data, token: verificationId);
          },
          context: context,
        );
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
    return;
  }
}
