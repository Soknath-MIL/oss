import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:map_location_picker/map_location_picker.dart';
import 'package:oss/presentation/controllers/config_controller.dart';
import 'package:oss/presentation/controllers/message_controller.dart';

import '../../constants/constants.dart';
import '../../data/services/appwrite_service.dart';

class ContinueBusinessRequestPage extends StatefulWidget {
  const ContinueBusinessRequestPage({super.key});

  @override
  State<ContinueBusinessRequestPage> createState() =>
      _ContinueBusinessRequestPageState();
}

class _ContinueBusinessRequestPageState
    extends State<ContinueBusinessRequestPage> {
  int currentStep = 0;
  bool showRoom = false;
  bool showDetail = false;
  List<String> allowPayment = [];
  final ConfigController configController = Get.put(ConfigController());
  final MessageConroller _messageConroller = Get.put(MessageConroller());
  final ImagePicker imgpicker = ImagePicker();
  XFile? imageIDCard;
  XFile? imageIDHouse;
  XFile? imageOldCert;
  List<XFile>? imageOthers = [];
  Color step1 = Colors.black;
  Color step2 = Colors.black;
  Color step3 = Colors.black;
  final _formKeyGeneralCont = GlobalKey<FormBuilderState>();
  final _formKeyDetailCont = GlobalKey<FormBuilderState>();
  final _formKeyUploadCont = GlobalKey<FormBuilderState>();
  final String docName = 'continueBusiness';
  String address = "null";
  Location? location;
  String autocompletePlace = "null";
  String type = 'สถานที่จำหน่ายอาหารหรือสะสมอาหาร';
  String title = 'mr';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stepper(
        physics: const ClampingScrollPhysics(),
        controlsBuilder: (context, _) {
          return Row(
            children: <Widget>[
              TextButton(
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all<Color>(Colors.green),
                ),
                onPressed: _.onStepContinue,
                child: const Text(
                  'ต่อไป',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              TextButton(
                onPressed: _.onStepCancel,
                child: const Text('กลับ'),
              ),
            ],
          );
        },
        type: StepperType.vertical,
        currentStep: currentStep,
        onStepCancel: () => currentStep == 0
            ? null
            : setState(() {
                currentStep -= 1;
              }),
        onStepContinue: () {
          bool isLastStep = (currentStep == getSteps().length - 1);
          if (isLastStep) {
            //Do something with this information
            var isGeneralError = _formKeyGeneralCont.currentState?.validate();
            debugPrint('general $isGeneralError');

            if (isGeneralError!) {
              setState(() {
                step1 = Colors.black;
              });
              _formKeyGeneralCont.currentState?.save();
            } else {
              Get.snackbar(
                "ข้อผิดพลาด",
                "ข้อมูลยังไม่สมบูรณ์",
                colorText: Colors.white,
                icon: const Icon(Icons.cancel),
                snackPosition: SnackPosition.TOP,
              );
              setState(() {
                step1 = Colors.red;
              });
              return;
            }
            var isDetailError = _formKeyDetailCont.currentState?.validate();
            if (isDetailError!) {
              setState(() {
                step2 = Colors.black;
              });
              _formKeyDetailCont.currentState?.save();
            } else {
              Get.snackbar(
                "ข้อผิดพลาด",
                "ข้อมูลยังไม่สมบูรณ์",
                colorText: Colors.white,
                icon: const Icon(Icons.cancel),
                snackPosition: SnackPosition.TOP,
              );
              setState(() {
                step2 = Colors.red;
              });
              return;
            }
            var isUploadError = _formKeyUploadCont.currentState?.validate();
            if (isUploadError!) {
              setState(() {
                step3 = Colors.black;
              });
              _formKeyUploadCont.currentState?.save();
            } else {
              setState(() {
                step3 = Colors.red;
              });
              return;
            }
            var generalData = _formKeyGeneralCont.currentState?.value;
            var detailData = _formKeyDetailCont.currentState?.value;

            handleSubmit(generalData!, detailData!);
          } else {
            setState(() {
              currentStep += 1;
            });
          }
        },
        onStepTapped: (step) => setState(() {
          currentStep = step;
        }),
        steps: getSteps(),
      ),
    );
  }

  void checkLogin() async {
    await _messageConroller.getUserId();
  }

  customInputDecoration(label) {
    return InputDecoration(
        contentPadding:
            const EdgeInsets.only(left: 10, right: 10, top: 8, bottom: 8),
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
        labelStyle: const TextStyle(fontSize: 12));
  }

  List<Step> getSteps() {
    return <Step>[
      Step(
        state: currentStep > 0 ? StepState.complete : StepState.indexed,
        isActive: currentStep >= 0,
        title: Text(
          "ข้อมูลทั่วไป",
          style: TextStyle(color: step1),
        ),
        content: configController.obx(
          (state) {
            // list to map
            var dataMap = {};
            for (var each in configController.configList) {
              if (each.data["value"] == null || each.data["value"] == "") {
                dataMap[each.data["name"]] = each.data["image"];
              } else {
                dataMap[each.data["name"]] = each.data["value"];
              }
            }
            return Obx(() {
              return Column(
                children: [
                  const SizedBox(
                    height: 10,
                  ),
                  FormBuilder(
                    key: _formKeyGeneralCont,
                    initialValue: {
                      "title": _messageConroller.accountData["data"]["title"],
                      "firstname": _messageConroller.accountData["data"]
                          ["firstname"],
                      "lastname": _messageConroller.accountData["data"]
                          ["lastname"],
                      "address": _messageConroller.accountData["data"]
                          ["address"],
                      // "moo": _messageConroller.accountData["data"]["moo"],
                      // "soi": _messageConroller.accountData["data"]["soi"],
                      // "road": _messageConroller.accountData["data"]["road"],
                      "phone": _messageConroller.accountData["data"]["phone"],
                      "tambon": dataMap["tambon"],
                      "amphoe": dataMap["amphoe"],
                      "province": dataMap["province"],
                      "postcode": dataMap["postcode"],
                      "workplace": "",
                      "position": "",
                      "purpose": ""
                    },
                    child: Column(
                      children: [
                        SizedBox(
                          child: FormBuilderDropdown<String>(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(10)),
                            name: 'title',
                            decoration: customInputDecoration('คำนำหน้า'),
                            validator: FormBuilderValidators.required(
                                errorText: 'กรุณากรอกข้อมูล'),
                            items: Constants.titleOptions
                                .map((item) => DropdownMenuItem(
                                      alignment:
                                          AlignmentDirectional.centerStart,
                                      value: item["name"],
                                      child: Text(
                                        item["value"].toString(),
                                        style: const TextStyle(
                                          fontSize: 13,
                                        ),
                                      ),
                                    ))
                                .toList(),
                            valueTransformer: (val) => val?.toString(),
                          ),
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        Row(
                          children: [
                            SizedBox(
                              width: MediaQuery.of(context).size.width / 4,
                              child: FormBuilderTextField(
                                name: 'firstname',
                                decoration: customInputDecoration('ชื่อ'),
                                validator: FormBuilderValidators.required(
                                    errorText: 'กรุณากรอกข้อมูล'),
                              ),
                            ),
                            const SizedBox(
                              width: 8,
                            ),
                            Expanded(
                              child: FormBuilderTextField(
                                name: 'lastname',
                                decoration: customInputDecoration('นามสกุล'),
                                validator: FormBuilderValidators.required(
                                    errorText: 'กรุณากรอกข้อมูล'),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        // Row(
                        //   children: [
                        //     Expanded(
                        //       child: FormBuilderTextField(
                        //         name: 'address',
                        //         decoration:
                        //             customInputDecoration("ที่อยู่"),
                        //         validator: FormBuilderValidators.required(errorText: 'กรุณากรอกข้อมูล'),
                        //       ),
                        //     ),
                        //   ],
                        // ),

                        Row(
                          children: [
                            // SizedBox(
                            //   width: MediaQuery.of(context).size.width / 3,
                            //   child: FormBuilderTextField(
                            //     name: 'houseNo',
                            //     decoration:
                            //         customInputDecoration("บ้านเลขที่"),
                            //     validator: FormBuilderValidators.required(
                            //         errorText: 'กรุณากรอกข้อมูล'),
                            //   ),
                            // ),
                            // const SizedBox(
                            //   width: 8,
                            // ),
                            Expanded(
                              child: FormBuilderTextField(
                                name: 'address',
                                decoration: customInputDecoration("ที่อยู่"),
                                validator: FormBuilderValidators.required(
                                    errorText: 'กรุณากรอกข้อมูล'),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        // Row(
                        //   children: [
                        //     SizedBox(
                        //       width: MediaQuery.of(context).size.width / 3,
                        //       child: FormBuilderTextField(
                        //         name: 'soi',
                        //         decoration:
                        //             customInputDecoration("ตรอก/ซอย"),
                        //         validator: FormBuilderValidators.required(
                        //             errorText: 'กรุณากรอกข้อมูล'),
                        //       ),
                        //     ),
                        //     const SizedBox(
                        //       width: 8,
                        //     ),
                        //     Expanded(
                        //       child: FormBuilderTextField(
                        //         name: 'road',
                        //         decoration: customInputDecoration("ถนน"),
                        //         validator: FormBuilderValidators.required(
                        //             errorText: 'กรุณากรอกข้อมูล'),
                        //       ),
                        //     ),
                        //   ],
                        // ),
                        // const SizedBox(
                        //   height: 10,
                        // ),
                        Row(
                          children: [
                            SizedBox(
                              width: MediaQuery.of(context).size.width / 3,
                              child: FormBuilderTextField(
                                name: 'tambon',
                                decoration: customInputDecoration('ตำบล'),
                                validator: FormBuilderValidators.required(
                                    errorText: 'กรุณากรอกข้อมูล'),
                              ),
                            ),
                            const SizedBox(
                              width: 8,
                            ),
                            Expanded(
                              child: FormBuilderTextField(
                                name: 'amphoe',
                                decoration: customInputDecoration('อำเภอ'),
                                validator: FormBuilderValidators.required(
                                    errorText: 'กรุณากรอกข้อมูล'),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Row(
                          children: [
                            SizedBox(
                              width: MediaQuery.of(context).size.width / 2,
                              child: FormBuilderTextField(
                                name: 'province',
                                decoration: customInputDecoration('จังหวัด'),
                                validator: FormBuilderValidators.required(
                                    errorText: 'กรุณากรอกข้อมูล'),
                              ),
                            ),
                            const SizedBox(
                              width: 8,
                            ),
                            Expanded(
                              child: FormBuilderTextField(
                                name: 'postcode',
                                decoration:
                                    customInputDecoration('รหัสไปรษณีย์'),
                                validator: FormBuilderValidators.required(
                                    errorText: 'กรุณากรอกข้อมูล'),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Row(
                          children: [
                            SizedBox(
                              width: MediaQuery.of(context).size.width / 3,
                              child: FormBuilderTextField(
                                name: 'phone',
                                decoration: customInputDecoration('โทรศัพท์'),
                                validator: FormBuilderValidators.required(
                                    errorText: 'กรุณากรอกข้อมูล'),
                              ),
                            ),
                            const SizedBox(
                              width: 8,
                            ),
                            Expanded(
                              child: FormBuilderTextField(
                                name: 'workplace',
                                decoration:
                                    customInputDecoration('สถานที่ทำงาน'),
                                validator: FormBuilderValidators.required(
                                    errorText: 'กรุณากรอกข้อมูล'),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        FormBuilderTextField(
                          name: 'position',
                          decoration: customInputDecoration('ตำแหน่ง'),
                          validator: FormBuilderValidators.required(
                              errorText: 'กรุณากรอกข้อมูล'),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        FormBuilderTextField(
                          maxLines: 3,
                          name: 'purpose',
                          decoration: customInputDecoration('วัตถุประสงค์'),
                          validator: FormBuilderValidators.required(
                              errorText: 'กรุณากรอกข้อมูล'),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            });
          },
          onLoading: const Center(
              child: Column(
            children: [CircularProgressIndicator()],
          )),
        ),
      ),
      Step(
        state: currentStep > 1 ? StepState.complete : StepState.indexed,
        isActive: currentStep >= 1,
        title: Text(
          "รายละเอียดคำขอ",
          style: TextStyle(
            color: step2,
          ),
        ),
        content: FormBuilder(
          key: _formKeyDetailCont,
          initialValue: {
            'title': title,
            'firstname': '',
            'lastname': '',
            'houseNo': '',
            'moo': '',
            'soi': '',
            'road': '',
            'nationality': '',
            'permissionBookNo': '',
            'permissionNo': '',
            'permissionDate': DateTime.now(),
            'officer': '',
            'type': type
          },
          child: Column(
            children: [
              const SizedBox(
                height: 8,
              ),
              SizedBox(
                child: FormBuilderDropdown<String>(
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                  name: 'title',
                  decoration: customInputDecoration('คำนำหน้า'),
                  validator: FormBuilderValidators.required(
                      errorText: 'กรุณากรอกข้อมูล'),
                  onChanged: (value) {
                    setState(() {
                      title = value!;
                    });
                  },
                  items: Constants.titleOptions
                      .map((item) => DropdownMenuItem(
                            alignment: AlignmentDirectional.centerStart,
                            value: item["name"],
                            child: Text(
                              item["value"].toString(),
                              style: const TextStyle(
                                fontSize: 13,
                              ),
                            ),
                          ))
                      .toList(),
                  valueTransformer: (val) => val?.toString(),
                ),
              ),
              const SizedBox(
                height: 8,
              ),
              Row(
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width / 4,
                    child: FormBuilderTextField(
                      name: 'firstname',
                      decoration: customInputDecoration('ชื่อ'),
                      validator: FormBuilderValidators.required(
                          errorText: 'กรุณากรอกข้อมูล'),
                    ),
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  Expanded(
                    child: FormBuilderTextField(
                      name: 'lastname',
                      decoration: customInputDecoration('นามสกุล'),
                      validator: FormBuilderValidators.required(
                          errorText: 'กรุณากรอกข้อมูล'),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 8,
              ),
              Row(
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width / 4,
                    child: FormBuilderTextField(
                      name: 'age',
                      decoration: customInputDecoration('อายุ'),
                      validator:
                          FormBuilderValidators.required(errorText: 'อายุ'),
                    ),
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width / 4,
                    child: FormBuilderTextField(
                      name: 'houseNo',
                      decoration: customInputDecoration('บ้านเลขที่'),
                      validator: FormBuilderValidators.required(
                          errorText: 'บ้านเลขที่'),
                    ),
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  Expanded(
                    child: FormBuilderTextField(
                      name: 'moo',
                      decoration: customInputDecoration('มู'),
                      validator:
                          FormBuilderValidators.required(errorText: 'มู'),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 8,
              ),
              Row(
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width / 4,
                    child: FormBuilderTextField(
                      name: 'soi',
                      decoration: customInputDecoration('ซอย'),
                      validator:
                          FormBuilderValidators.required(errorText: 'ซอย'),
                    ),
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  Expanded(
                    child: FormBuilderTextField(
                      name: 'road',
                      decoration: customInputDecoration('ถนน'),
                      validator:
                          FormBuilderValidators.required(errorText: 'ถนน'),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  Expanded(
                    child: FormBuilderTextField(
                      name: 'nationality',
                      decoration: customInputDecoration('สัญชาติ'),
                      validator: FormBuilderValidators.required(
                          errorText: 'กรุณากรอกข้อมูล'),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              FormBuilderDropdown<String>(
                borderRadius: const BorderRadius.all(Radius.circular(10)),
                name: 'type',
                decoration: customInputDecoration('ประเภทธุรกิจ'),
                validator: FormBuilderValidators.required(
                  errorText: 'กรุณากรอกข้อมูล',
                ),
                onChanged: (value) {
                  setState(() {
                    type = value!;
                  });
                },
                items: Constants.businessTypes
                    .map((item) => DropdownMenuItem(
                          alignment: AlignmentDirectional.centerStart,
                          value: item["name"],
                          child: Text(
                            item["value"].toString(),
                            style: const TextStyle(
                              fontSize: 13,
                            ),
                          ),
                        ))
                    .toList(),
                valueTransformer: (val) => val?.toString(),
              ),
              const SizedBox(
                height: 10,
              ),
              FormBuilderTextField(
                name: 'permissionBookNo',
                decoration: customInputDecoration('ตามใบอนุญาตเล่มที่'),
                validator: FormBuilderValidators.required(
                    errorText: 'กรุณากรอกข้อมูล'),
              ),
              const SizedBox(
                height: 10,
              ),
              FormBuilderTextField(
                name: 'permissionNo',
                decoration: customInputDecoration('เลขที่'),
                validator: FormBuilderValidators.required(
                    errorText: 'กรุณากรอกข้อมูล'),
              ),
              const SizedBox(
                height: 10,
              ),
              FormBuilderDateTimePicker(
                name: 'permissionDate',
                initialEntryMode: DatePickerEntryMode.calendar,
                // initialValue: DateTime.now(),
                inputType: InputType.date,
                firstDate: DateTime.now(),
                decoration: customInputDecoration('ออกให้เมื่อวันที่'),
                validator: FormBuilderValidators.required(),
                // initialTime: const TimeOfDay(hour: 8, minute: 0),
              ),
              const SizedBox(
                height: 10,
              ),
              FormBuilderTextField(
                name: 'officer',
                decoration: customInputDecoration('ต่อ (เจ้าพนักงานท้องถิ่น)'),
                validator: FormBuilderValidators.required(
                    errorText: 'กรุณากรอกข้อมูล'),
              ),
              const SizedBox(
                height: 20,
              ),
            ],
          ),
        ),
      ),
      Step(
        state: currentStep > 2 ? StepState.complete : StepState.indexed,
        isActive: currentStep >= 2,
        title: Text(
          "อัปโหลดเอกสาร",
          style: TextStyle(
            color: step3,
          ),
        ),
        content: FormBuilder(
          key: _formKeyUploadCont,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('เลือกรูปภาพ บัตรประชาชน'),
                  ElevatedButton(
                    onPressed: () {
                      debugPrint('image tab');
                      showModalBottomSheet(
                        context: context,
                        builder: (context) {
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              ListTile(
                                leading: const Icon(Icons.image,
                                    color: Colors.green),
                                title: const Text('แกลลอรี่'),
                                onTap: () {
                                  pickImageGallery("ID");
                                  Navigator.pop(context);
                                },
                              ),
                              ListTile(
                                leading: const Icon(
                                  Icons.camera_alt,
                                  color: Colors.green,
                                ),
                                title: const Text('กล้อง'),
                                onTap: () {
                                  pickImageCamera("ID");
                                  Navigator.pop(context);
                                },
                              ),
                            ],
                          );
                        },
                      );
                    },
                    child: const Icon(Icons.image),
                  ),
                ],
              ),
              imageIDCard != null
                  ? Card(
                      child: SizedBox(
                        height: 100,
                        width: 100,
                        child: Image.file(File(imageIDCard!.path)),
                      ),
                    )
                  : Container(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('เลือกรูปภาพ ทะเบียนบ้าน'),
                  ElevatedButton(
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        builder: (context) {
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              ListTile(
                                leading: const Icon(Icons.image,
                                    color: Colors.green),
                                title: const Text('แกลลอรี่'),
                                onTap: () {
                                  pickImageGallery("House");
                                  Navigator.pop(context);
                                },
                              ),
                              ListTile(
                                leading: const Icon(
                                  Icons.camera_alt,
                                  color: Colors.green,
                                ),
                                title: const Text('กล้อง'),
                                onTap: () {
                                  pickImageCamera("House");
                                  Navigator.pop(context);
                                },
                              ),
                            ],
                          );
                        },
                      );
                    },
                    child: const Icon(Icons.image),
                  ),
                ],
              ),
              imageIDHouse != null
                  ? Card(
                      child: SizedBox(
                        height: 100,
                        width: 100,
                        child: Image.file(File(imageIDHouse!.path)),
                      ),
                    )
                  : Container(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(
                    width: 200,
                    child: Text(
                      'สำเนาใบอนุญาตประกอบกิจการที่เป็นอันตราย หรือสะสมอาหารตัวเก่า',
                      softWrap: true,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      debugPrint('image tab');
                      showModalBottomSheet(
                        context: context,
                        builder: (context) {
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              ListTile(
                                leading: const Icon(Icons.image,
                                    color: Colors.green),
                                title: const Text('แกลลอรี่'),
                                onTap: () {
                                  pickImageGallery("oldCert");
                                  Navigator.pop(context);
                                },
                              ),
                              ListTile(
                                leading: const Icon(
                                  Icons.camera_alt,
                                  color: Colors.green,
                                ),
                                title: const Text('กล้อง'),
                                onTap: () {
                                  pickImageCamera("oldCert");
                                  Navigator.pop(context);
                                },
                              ),
                            ],
                          );
                        },
                      );
                    },
                    child: const Icon(Icons.image),
                  ),
                ],
              ),
              imageOldCert != null
                  ? Card(
                      child: SizedBox(
                        height: 100,
                        width: 100,
                        child: Image.file(File(imageOldCert!.path)),
                      ),
                    )
                  : Container(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('เลือกรูปภาพ อื่น'),
                  ElevatedButton(
                    onPressed: () {
                      pickMultiImageGallery();
                    },
                    child: const Icon(Icons.image),
                  ),
                ],
              ),
              imageOthers!.isNotEmpty
                  ? Container(
                      height: 130,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: imageOthers?.length,
                        itemBuilder: (BuildContext context, int index) {
                          debugPrint(imageOthers![index].path);
                          return Center(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Image.file(
                                File(imageOthers![index].path),
                                height: 120,
                              ),
                            ),
                          );
                        },
                      ),
                    )
                  : Container(),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('ปักหมุดตำแหน่ง'),
                      // ignore: unnecessary_null_comparison

                      location != null
                          ? Text(
                              'ละติจูดและลองจิจูด:  ${location!.lat.toStringAsFixed(6)}, ${location!.lng.toStringAsFixed(6)}',
                              style: const TextStyle(fontSize: 10),
                            )
                          : Container(),
                    ],
                  ),
                  GestureDetector(
                    child: Image.asset(
                      "assets/images/pin-map.png",
                      width: 60,
                    ),
                    onTap: () async {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          maintainState: true,
                          builder: (context) {
                            return MapLocationPicker(
                              language: "th",
                              apiKey: "AIzaSyBB2X6grO8t8zyW6cktVqBs7duJP0mqN3A",
                              canPopOnNextButtonTaped: false,
                              currentLatLng: const LatLng(14, 100),
                              mapType: MapType.satellite,
                              onCurrentLocation: (LatLng currentLatLng) {
                                setState(() {
                                  location = Location(
                                    lat: currentLatLng.latitude,
                                    lng: currentLatLng.longitude,
                                  );
                                });
                              },
                              onTap: (LatLng selectedLatLng) {
                                setState(() {
                                  location = Location(
                                      lat: selectedLatLng.latitude,
                                      lng: selectedLatLng.longitude);
                                });
                              },
                              onNext: (GeocodingResult? result) {
                                if (result != null && location != null) {
                                  setState(() {
                                    address = result.formattedAddress ?? "";
                                  });
                                  Get.back();
                                } else {
                                  debugPrint('No result');
                                  Get.snackbar("ไม่มีที่อยู่",
                                      "กรุณาเลือกตำแหน่งบนแผนที่",
                                      titleText: const Text(
                                        "No address",
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      messageText: const Text(
                                        "Please pick location on map",
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      snackPosition: SnackPosition.BOTTOM,
                                      duration: const Duration(seconds: 1),
                                      icon: const Icon(Icons.info));
                                }
                              },
                              onSuggestionSelected:
                                  (PlacesDetailsResponse? result) {
                                if (result != null) {
                                  setState(() {
                                    autocompletePlace =
                                        result.result.formattedAddress ?? "";
                                  });
                                }
                              },
                            );
                          },
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ];
  }

  void handleSubmit(
    Map<String, dynamic> general,
    Map<String, dynamic> detail,
  ) async {
    if (location == null) {
      Get.snackbar(
        "ข้อผิดพลาด",
        "ไม่มีสถานที่",
        colorText: Colors.white,
        icon: const Icon(Icons.cancel),
        snackPosition: SnackPosition.TOP,
      );
      return null;
    }

    if (imageIDCard == null) {
      Get.snackbar(
        "ข้อผิดพลาด",
        "ไม่มีการอัปโหลดบัตรประชาชน",
        colorText: Colors.white,
        icon: const Icon(Icons.cancel),
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    if (imageIDHouse == null) {
      Get.snackbar(
        "ข้อผิดพลาด",
        "ไม่มีใบรับรองบ้าน",
        colorText: Colors.white,
        icon: const Icon(Icons.cancel),
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    await EasyLoading.show(
      status: 'กำลังโหลด...',
      maskType: EasyLoadingMaskType.black,
    );
    // check doc exist
    var docExist = await AppwriteService().checkDocMasterName(docName);

    if (docExist == null) {
      Get.snackbar(
        "ข้อผิดพลาด",
        "ไม่มีเวิร์กโฟลว์ ของเอกสาร",
        colorText: Colors.white,
        icon: const Icon(Icons.cancel),
        snackPosition: SnackPosition.TOP,
      );
    } else {
      String filesArrayIDCard;
      var result = await AppwriteService().uploadPicture(
          imageIDCard!.path, imageIDCard!.name, Constants.conBusinessBucketId);

      var fileMap = result?.toMap();
      // remove permission from image
      fileMap?.removeWhere((key, value) =>
          ["\$permissions", "\$createdAt", "\$updatedAt"].contains(key));

      filesArrayIDCard = jsonEncode([
        {
          ...fileMap!,
          "url":
              '${Constants.appwriteEndpoint}/storage/buckets/${result?.bucketId}/files/${result?.$id}/view?project=${Constants.appwriteProjectId}&mode=admin'
        }
      ]);

      String filesArrayIDHouse;
      var resultUpload = await AppwriteService().uploadPicture(
          imageIDHouse!.path,
          imageIDHouse!.name,
          Constants.openBusinessBucketId);

      var fileMapUpload = resultUpload?.toMap();
      // remove permission from image
      fileMapUpload?.removeWhere((key, value) =>
          ["\$permissions", "\$createdAt", "\$updatedAt"].contains(key));

      filesArrayIDHouse = jsonEncode([
        {
          ...fileMapUpload!,
          "url":
              '${Constants.appwriteEndpoint}/storage/buckets/${resultUpload?.bucketId}/files/${resultUpload?.$id}/view?project=${Constants.appwriteProjectId}&mode=admin'
        }
      ]);
      String? filesArrayOldCertHouse;

      if (imageOldCert != null) {
        var resultOldCertUpload = await AppwriteService().uploadPicture(
          imageOldCert!.path,
          imageOldCert!.name,
          Constants.conBusinessBucketId,
        );

        var fileMap = resultOldCertUpload?.toMap();
        // remove permission from image
        fileMap?.removeWhere((key, value) =>
            ["\$permissions", "\$createdAt", "\$updatedAt"].contains(key));

        filesArrayOldCertHouse = jsonEncode([
          {
            ...fileMap!,
            "url":
                '${Constants.appwriteEndpoint}/storage/buckets/${resultOldCertUpload?.bucketId}/files/${resultOldCertUpload?.$id}/view?project=${Constants.appwriteProjectId}&mode=admin'
          }
        ]);
      }

      var filesArray = [];
      if (imageOthers != null) {
        for (var item in imageOthers!) {
          // upload image
          var result = await AppwriteService().uploadPicture(
            item.path,
            item.name,
            Constants.conBusinessBucketId,
          );

          var fileMap = result?.toMap();

          // remove permission from image
          fileMap?.removeWhere(
            (key, value) =>
                ["\$permissions", "\$createdAt", "\$updatedAt"].contains(key),
          );

          filesArray.add(
            jsonEncode({
              ...fileMap!,
              "url":
                  '${Constants.appwriteEndpoint}/storage/buckets/${result?.bucketId}/files/${result?.$id}/view?project=${Constants.appwriteProjectId}&mode=admin'
            }),
          );
        }
      }

      // create appeal record
      var generalRequest = await AppwriteService().createGeneralRequest({
        ...general,
      });

      // create appeal record
      var continueBusinessData =
          await AppwriteService().createContinueBussinessRequest({
        ...detail,
        "permissionDate": detail['permissionDate'].millisecondsSinceEpoch,
        "coordinates":
            jsonEncode([location?.lng.toString(), location?.lat.toString()]),
        "nationalIdImg": filesArrayIDCard,
        "houseCertImg": filesArrayIDHouse,
        "oldCertImg": filesArrayOldCertHouse,
        "generalFormId": generalRequest?.data["\$id"].toString(),
        "otherImages": filesArray
      });

      debugPrint('continueBusinessData ${continueBusinessData.toString()}');

      // // create request
      var accunt = await AppwriteService().getAccount();
      DateTime now = DateTime.now();
      var epochTime = (now.millisecondsSinceEpoch / 1000).round();
      var lastTotal = await AppwriteService().countOpenBusiness();
      var unitDetail = await AppwriteService()
          .getUnit(docExist.documents[0].data["docOwner"].toString());
      var currentYear = (DateTime.now().year + 543).toString();

      AppwriteService().createRequest({
        "docSeq":
            '${unitDetail?.data["unit_id"]}-B-${lastTotal?.total.toString().padLeft(4, '0')}/${currentYear.substring(currentYear.length - 2)}', // "E"
        "name": 'คำขอต่อใบอนุญาตประกอบกิจการ',
        "docCode": docExist.documents[0].data["\$id"].toString(),
        "userId": accunt?.$id,
        "status": "new",
        "requestedAt": epochTime,
        "type": docName,
        "docId": continueBusinessData?.data["\$id"].toString(),
        "unitId": docExist.documents[0].data["docOwner"].toString(),
      });
      await EasyLoading.dismiss();
      // display dialog to ask user to confirm
      Get.defaultDialog(
        title: "ข้อความ",
        content: const Text("อัปโหลดการร้องเรียนำเร็จ"),
        backgroundColor: Colors.white,
        titleStyle: const TextStyle(color: Colors.black54),
        radius: 10,
        confirm: FloatingActionButton.extended(
          heroTag: 'to_home_6',
          onPressed: () {
            Get.toNamed("/main");
          },
          label: const Text(
            'ไปที่หน้าแรก',
          ),
        ),
      );
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkLogin();
  }

  Future pickImageCamera(String type) async {
    try {
      final image = await ImagePicker().pickImage(
        source: ImageSource.camera,
        imageQuality: 25,
      );
      if (image == null) return;
      if (type == "ID") {
        setState(() {
          imageIDCard = image;
        });
      } else if (type == "oldCert") {
        setState(() {
          imageOldCert = image;
        });
      } else {
        setState(() {
          imageIDHouse = image;
        });
      }
    } on PlatformException catch (e) {
      debugPrint('Failed to pick image: $e');
    }
  }

  Future pickImageGallery(String type) async {
    try {
      final image = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 25,
      );
      if (image == null) return;
      if (type == "ID") {
        setState(() {
          imageIDCard = image;
        });
      } else if (type == "oldCert") {
        setState(() {
          imageOldCert = image;
        });
      } else {
        setState(() {
          imageIDHouse = image;
        });
      }
    } on PlatformException catch (e) {
      debugPrint('Failed to pick image: $e');
    }
  }

  Future pickMultiImageGallery() async {
    try {
      final image = await ImagePicker().pickMultiImage();
      // ignore: unnecessary_null_comparison
      if (image.isEmpty) return;

      if (image.length < 4) {
        setState(() {
          imageOthers = image;
        });
      }
      if (image.length >= 4) {
        Get.snackbar(
          "ข้อผิดพลาด",
          "ไม่สามารถเลือก มากกว่า 3 ภาพ",
          colorText: Colors.white,
          icon: const Icon(Icons.cancel),
          snackPosition: SnackPosition.TOP,
        );
      }
    } on PlatformException catch (e) {
      debugPrint('Failed to pick image: $e');
    }
  }

  void _onChanged(dynamic val) => debugPrint(val.toString());
}
