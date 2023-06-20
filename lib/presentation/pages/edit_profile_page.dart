import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:get/get.dart';

import '../../constants/constants.dart';
import '../../data/services/firebase_service.dart';

final FirebaseService _firebaseService = FirebaseService();

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormBuilderState>();
  var data = Get.arguments[0];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('แก้ไขโปรไฟล์'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  FormBuilder(
                    key: _formKey,
                    initialValue: {
                      "\$id": data["\$id"],
                      "name": data["name"],
                      "title": data["title"],
                      "firstname": data["firstname"],
                      "lastname": data["lastname"],
                      "address": data["address"],
                      "phone": data["phone"]
                    },
                    child: Container(
                      margin: const EdgeInsets.all(10),
                      child: Column(
                        children: [
                          FormBuilderTextField(
                            name: 'name',
                            decoration: customInputDecoration('ชื่อผู้ใช้'),
                            validator: FormBuilderValidators.required(),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          FormBuilderDropdown<String>(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(10)),
                            name: 'title',
                            decoration: customInputDecoration('คำนำหน้า'),
                            validator: FormBuilderValidators.required(),
                            items: Constants.titleOptions
                                .map((item) => DropdownMenuItem(
                                      alignment:
                                          AlignmentDirectional.centerStart,
                                      value: item["name"],
                                      child: Text(item["value"].toString()),
                                    ))
                                .toList(),
                            valueTransformer: (val) => val?.toString(),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          FormBuilderTextField(
                            name: 'firstname',
                            decoration: customInputDecoration('ชื่อ'),
                            validator: FormBuilderValidators.required(),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          FormBuilderTextField(
                            name: 'lastname',
                            decoration: customInputDecoration('นามสกุล'),
                            validator: FormBuilderValidators.required(),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          FormBuilderTextField(
                            name: 'address',
                            decoration: customInputDecoration('ที่อยู่'),
                            validator: FormBuilderValidators.required(),
                          ),
                          const SizedBox(
                            height: 16,
                          ),
                          FormBuilderTextField(
                            name: 'phone',
                            decoration: customInputDecoration('โทรศัพท์'),
                            validator: FormBuilderValidators.required(),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          TextButton(
                            style: TextButton.styleFrom(
                              backgroundColor: Colors.blue,
                            ),
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                _formKey.currentState?.save();
                                debugPrint(
                                    'phone ${_formKey.currentState!.value.toString()}');

                                await EasyLoading.show(
                                  status: 'กำลังโหลด...',
                                  maskType: EasyLoadingMaskType.black,
                                );
                                // ignore: use_build_context_synchronously
                                await _firebaseService
                                    .signInWithPhoneNumberNoRedirect(
                                  _formKey.currentState!.value["phone"],
                                  _formKey.currentState!,
                                  context,
                                );
                                await EasyLoading.dismiss();
                                // popup bottomsheet
                                // ignore: use_build_context_synchronously
                              }
                            },
                            child: const Text(
                              'ยืนยัน',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          FormBuilderField(
                            name: "\$id",
                            enabled: false,
                            builder: (FormFieldState<dynamic> field) {
                              //Empty widget
                              return const SizedBox.shrink();
                            },
                          ),
                          // FormBuilderTextField(
                          //   name: 'otp',
                          //   decoration: customInputDecoration('OTP'),
                          //   validator: FormBuilderValidators.required(),
                          // ),
                          // ElevatedButton(
                          //   child: const Text('ยืนยัน'),
                          //   onPressed: () async {
                          //     // update user name in appwrite
                          //     if (_formKey.currentState!.validate()) {
                          //       _formKey.currentState?.save();
                          //       // verify token
                          //       var verifyToken = await _firebaseService
                          //           .signInWithCredentialNoRedirect(
                          //         _formKey.currentState!.value["token"],
                          //         _formKey.currentState!.value["otp"],
                          //       );
                          //       if (verifyToken) {
                          //         await AppwriteService().updateUser(
                          //           data["\$id"],
                          //           {
                          //             "name":
                          //                 _formKey.currentState!.value["name"],
                          //             "address": _formKey
                          //                 .currentState!.value["address"],
                          //             "phone":
                          //                 _formKey.currentState!.value["phone"],
                          //             "title":
                          //                 _formKey.currentState!.value["title"],
                          //             "firstname": _formKey
                          //                 .currentState!.value["firstname"],
                          //             "lastname": _formKey
                          //                 .currentState!.value["lastname"],
                          //           },
                          //         );
                          //         Get.snackbar(
                          //           "ข้อมูล",
                          //           "อัปเดตโปรไฟล์สำเร็จ",
                          //           colorText: Colors.white,
                          //           icon: const Icon(Icons.check_circle),
                          //           snackPosition: SnackPosition.TOP,
                          //         );
                          //         Get.toNamed('/main');
                          //       } else {
                          //         Get.snackbar(
                          //           "ข้อผิดพลาด",
                          //           "OTP ไม่ถูกต้อง",
                          //           colorText: Colors.white,
                          //           icon: const Icon(Icons.cancel),
                          //           snackPosition: SnackPosition.TOP,
                          //         );
                          //       }
                          //     }
                          //   },
                          // ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  customInputDecoration(label) {
    return InputDecoration(
      contentPadding: const EdgeInsets.all(10),
      isDense: true,
      border: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.grey),
        borderRadius: BorderRadius.circular(8.0),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.blue),
        borderRadius: BorderRadius.circular(8.0),
      ),
      labelText: label,
    );
  }
}
