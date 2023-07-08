import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:get/get.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

import '../../data/services/appwrite_service.dart';
import '../../data/services/firebase_service.dart';

final FirebaseService _firebaseService = FirebaseService();

class BottomSheetPin extends StatefulWidget {
  final FormBuilderState data;
  final String token;
  const BottomSheetPin({super.key, required this.data, required this.token});

  @override
  State<BottomSheetPin> createState() => _BottomSheetPinState();
}

class _BottomSheetPinState extends State<BottomSheetPin> {
  final formKey = GlobalKey<FormBuilderState>();
  TextEditingController textEditingController = TextEditingController();

  // ignore: close_sinks
  StreamController<ErrorAnimationType>? errorController;

  bool hasError = false;
  String currentText = "";

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Form(
        key: formKey,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 8.0,
            horizontal: 30,
          ),
          child: SizedBox(
            height: 120,
            child: Column(
              children: [
                const Text('โปรดป้อน PIN เพื่อดำเนินการต่อ'),
                const SizedBox(
                  height: 20,
                ),
                Expanded(
                  child: PinCodeTextField(
                    autoDisposeControllers: false,
                    appContext: context,
                    pastedTextStyle: TextStyle(
                      color: Colors.green.shade600,
                      fontWeight: FontWeight.bold,
                    ),
                    length: 6,
                    obscureText: true,
                    blinkWhenObscuring: true,
                    animationType: AnimationType.fade,
                    validator: (v) {
                      if (v!.length < 3) {
                        return "I'm from validator";
                      } else {
                        return null;
                      }
                    },
                    pinTheme: PinTheme(
                      borderWidth: 1,
                      inactiveFillColor: Colors.grey[300],
                      shape: PinCodeFieldShape.box,
                      borderRadius: BorderRadius.circular(10),
                      fieldHeight: 50,
                      fieldWidth: 50,
                      activeFillColor: Colors.white,
                    ),

                    cursorColor: Colors.black,
                    animationDuration: const Duration(milliseconds: 300),
                    enableActiveFill: true,
                    errorAnimationController: errorController,
                    controller: textEditingController,
                    keyboardType: TextInputType.number,
                    boxShadows: const [
                      BoxShadow(
                        offset: Offset(0, 1),
                        color: Colors.black12,
                        blurRadius: 10,
                      )
                    ],
                    onCompleted: (v) async {
                      debugPrint("Completed, ${widget.token} $v");
                      // verified with google
                      var verifyToken =
                          await _firebaseService.signInWithCredentialNoRedirect(
                        widget.token,
                        v,
                      );
                      if (verifyToken) {
                        await AppwriteService().updateUser(
                          widget.data.value["\$id"],
                          {
                            "name":
                                '${widget.data.value["title"]} ${widget.data.value["firstname"]} ${widget.data.value["lastname"]}',
                            "address": widget.data.value["address"],
                            "phone": widget.data.value["phone"],
                            "title": widget.data.value["title"],
                            "firstname": widget.data.value["firstname"],
                            "lastname": widget.data.value["lastname"],
                          },
                        );
                        Get.snackbar(
                          "ข้อมูล",
                          "อัปเดตโปรไฟล์สำเร็จ",
                          colorText: Colors.white,
                          icon: const Icon(Icons.check_circle),
                          snackPosition: SnackPosition.TOP,
                        );
                        Get.offAllNamed('/main');
                      } else {
                        Get.snackbar(
                          "ข้อผิดพลาด",
                          "OTP ไม่ถูกต้อง",
                          colorText: Colors.white,
                          icon: const Icon(Icons.cancel),
                          snackPosition: SnackPosition.TOP,
                        );
                      }
                    },
                    // onTap: () {
                    //   print("Pressed");
                    // },
                    onChanged: (value) {
                      debugPrint(value);
                      setState(() {
                        currentText = value;
                      });
                    },
                    beforeTextPaste: (text) {
                      debugPrint("Allowing to paste $text");
                      //if you return true then it will show the paste confirmation dialog. Otherwise if false, then nothing will happen.
                      //but you can show anything you want here, like your pop up saying wrong paste format or etc
                      return true;
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    errorController = StreamController<ErrorAnimationType>();
    super.initState();
  }
}
