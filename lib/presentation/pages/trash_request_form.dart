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

class TrashRequestPage extends StatefulWidget {
  const TrashRequestPage({super.key});

  @override
  State<TrashRequestPage> createState() => _TrashRequestPageState();
}

class _TrashRequestPageState extends State<TrashRequestPage> {
  int currentStep = 0;
  bool showRoom = false;
  bool showDetail = false;
  List<String> allowPayment = [];
  final ConfigController configController = Get.put(ConfigController());
  final MessageConroller _messageConroller = Get.put(MessageConroller());
  final ImagePicker imgpicker = ImagePicker();
  XFile? imageIDCard;
  XFile? imageIDHouse;
  List<XFile>? imageOthers = [];
  Color step1 = Colors.black;
  Color step2 = Colors.black;
  Color step3 = Colors.black;
  final _formKeyGeneral = GlobalKey<FormBuilderState>();
  final _formKeyDetail = GlobalKey<FormBuilderState>();
  final _formKeyUpload = GlobalKey<FormBuilderState>();
  final String docName = 'trash';
  String address = "null";
  Location? location;
  String autocompletePlace = "null";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ขอถังขยะ'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(
              height: 10,
            ),
            const Text(
              'แบบสำรวจความต้องการให้เก็บขยะมูลฝอยตำบลหนองปลาหมอ',
              maxLines: 2,
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
            ),
            Stepper(
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
                  var isGeneralError = _formKeyGeneral.currentState?.validate();
                  debugPrint('general $isGeneralError');

                  if (isGeneralError!) {
                    setState(() {
                      step1 = Colors.black;
                    });
                    _formKeyGeneral.currentState?.save();
                  } else {
                    setState(() {
                      step1 = Colors.red;
                    });
                    return;
                  }
                  var isDetailError = _formKeyDetail.currentState?.validate();
                  if (isDetailError!) {
                    setState(() {
                      step2 = Colors.black;
                    });
                    _formKeyDetail.currentState?.save();
                  } else {
                    setState(() {
                      step2 = Colors.red;
                    });
                    return;
                  }
                  var isUploadError = _formKeyUpload.currentState?.validate();
                  if (isUploadError!) {
                    setState(() {
                      step3 = Colors.black;
                    });
                    _formKeyUpload.currentState?.save();
                  } else {
                    setState(() {
                      step3 = Colors.red;
                    });
                    return;
                  }
                  var generalData = _formKeyGeneral.currentState?.value;
                  var detailData = _formKeyDetail.currentState?.value;
                  var uploadData = _formKeyUpload.currentState?.value;

                  // debugPrint('data submit ${{
                  //   ...generalData!,
                  //   ...detailData!
                  // }.toString()}');

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
          ],
        ),
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
      labelStyle: const TextStyle(fontSize: 12),
    );
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
        content: Column(
          children: [
            configController.obx(
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
                  return Container(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      children: [
                        FormBuilder(
                          key: _formKeyGeneral,
                          initialValue: {
                            "title": _messageConroller.accountData["data"]
                                ["title"],
                            "firstname": _messageConroller.accountData["data"]
                                ["firstname"],
                            "lastname": _messageConroller.accountData["data"]
                                ["lastname"],
                            // "address": _messageConroller.accountData["data"]
                            //     ["address"],
                            "houseNo": _messageConroller.accountData["data"]
                                ["houseNo"],
                            "moo": _messageConroller.accountData["data"]["moo"],
                            "soi": _messageConroller.accountData["data"]["soi"],
                            "road": _messageConroller.accountData["data"]
                                ["road"],
                            "phone": _messageConroller.accountData["data"]
                                ["phone"],
                            "tambon": dataMap["tambon"],
                            "amphoe": dataMap["amphoe"],
                            "province": dataMap["province"],
                            "postcode": dataMap["postcode"],
                          },
                          child: Column(
                            children: [
                              const SizedBox(
                                height: 16,
                              ),
                              Row(
                                children: [
                                  SizedBox(
                                    height: 35,
                                    width:
                                        MediaQuery.of(context).size.width / 4,
                                    child: FormBuilderDropdown<String>(
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(10)),
                                      name: 'title',
                                      decoration:
                                          customInputDecoration('คำนำหน้า'),
                                      validator: FormBuilderValidators.required(
                                          errorText: 'กรุณากรอกข้อมูล'),
                                      items: Constants.titleOptions
                                          .map((item) => DropdownMenuItem(
                                                alignment: AlignmentDirectional
                                                    .centerStart,
                                                value: item["name"],
                                                child: Text(
                                                  item["value"].toString(),
                                                  style: const TextStyle(
                                                      fontSize: 13),
                                                ),
                                              ))
                                          .toList(),
                                      valueTransformer: (val) =>
                                          val?.toString(),
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 8,
                                  ),
                                  SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width / 4,
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
                                      decoration:
                                          customInputDecoration('นามสกุล'),
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
                                  Expanded(
                                    child: FormBuilderTextField(
                                      name: 'address',
                                      style: const TextStyle(fontSize: 13),
                                      decoration:
                                          customInputDecoration("ที่อยู่"),
                                      validator: FormBuilderValidators.required(
                                          errorText: 'กรุณากรอกข้อมูล'),
                                    ),
                                  ),
                                ],
                              ),
                              // Row(
                              //   children: [
                              //     SizedBox(
                              //       width:
                              //           MediaQuery.of(context).size.width / 3,
                              //       child: FormBuilderTextField(
                              //         name: 'houseNo',
                              //         decoration:
                              //             customInputDecoration("บ้านเลขที่"),
                              //         validator: FormBuilderValidators.required(
                              //             errorText: 'กรุณากรอกข้อมูล'),
                              //       ),
                              //     ),
                              //     const SizedBox(
                              //       width: 8,
                              //     ),
                              //     Expanded(
                              //       child: FormBuilderTextField(
                              //         name: 'moo',
                              //         style: const TextStyle(fontSize: 13),
                              //         decoration:
                              //             customInputDecoration("หมู่ที่"),
                              //         validator: FormBuilderValidators.required(
                              //             errorText: 'กรุณากรอกข้อมูล'),
                              //       ),
                              //     ),
                              //   ],
                              // ),
                              // const SizedBox(
                              //   height: 8,
                              // ),
                              // Row(
                              //   children: [
                              //     SizedBox(
                              //       width:
                              //           MediaQuery.of(context).size.width / 3,
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
                              const SizedBox(
                                height: 8,
                              ),
                              Row(
                                children: [
                                  SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width / 3,
                                    child: FormBuilderTextField(
                                      name: 'tambon',
                                      decoration:
                                          customInputDecoration('แขวง/ตำบล'),
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
                                      decoration:
                                          customInputDecoration('เขต/อำเภอ'),
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
                                    width:
                                        MediaQuery.of(context).size.width / 2,
                                    child: FormBuilderTextField(
                                      name: 'province',
                                      decoration:
                                          customInputDecoration('จังหวัด'),
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
                                height: 8,
                              ),
                              Row(
                                children: [
                                  SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width / 3,
                                    child: FormBuilderTextField(
                                      name: 'phone',
                                      decoration:
                                          customInputDecoration('โทรศัพท์'),
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
                                height: 8,
                              ),
                              FormBuilderTextField(
                                maxLines: 3,
                                name: 'purpose',
                                decoration:
                                    customInputDecoration('วัตถุประสงค์'),
                                validator: FormBuilderValidators.required(
                                    errorText: 'กรุณากรอกข้อมูล'),
                              ),
                            ],
                          ),
                        ),
                        // Container(
                        //   margin: const EdgeInsets.all(16),
                        //   child: Row(
                        //       mainAxisAlignment: MainAxisAlignment.center,
                        //       children: [
                        //         SizedBox(
                        //           height: 40,
                        //           child: FittedBox(
                        //             child: FloatingActionButton.extended(
                        //               shape: RoundedRectangleBorder(
                        //                 borderRadius: BorderRadius.circular(10),
                        //               ),
                        //               backgroundColor: Colors.grey,
                        //               heroTag: 'reset',
                        //               onPressed: () {},
                        //               icon: const Icon(Icons.refresh),
                        //               label: const Text(
                        //                 'รีเซ็ต',
                        //                 style: TextStyle(fontSize: 18),
                        //               ),
                        //             ),
                        //           ),
                        //         ),
                        // const Divider(
                        //   height: 10,
                        // ),
                        // SizedBox(
                        //   height: 40,
                        //   child: FittedBox(
                        //     child: FloatingActionButton.extended(
                        //         shape: RoundedRectangleBorder(
                        //           borderRadius:
                        //               BorderRadius.circular(10),
                        //         ),
                        //         backgroundColor: Colors.green,
                        //         heroTag: 'submit',
                        //         onPressed: () {
                        //           if (_formKey.currentState!
                        //               .validate()) {
                        //             _formKey.currentState!.save();
                        //             handleSubmit(
                        //                 _formKey.currentState!.value);
                        //           }
                        //         },
                        //         icon: const Icon(Icons.upload),
                        //         label: const Text(
                        //           'ส่ง',
                        //           style: TextStyle(fontSize: 18),
                        //         )),
                        //   ),
                        // ),
                        //       ]),
                        // )
                      ],
                    ),
                  );
                });
              },
              onLoading: Center(
                  child: Column(
                children: const [CircularProgressIndicator()],
              )),
            ),
          ],
        ),
      ),
      Step(
        state: currentStep > 1 ? StepState.complete : StepState.indexed,
        isActive: currentStep >= 1,
        title: Text(
          "คำขอรายละเอียด",
          style: TextStyle(
            color: step2,
          ),
        ),
        content: SizedBox(
          height: 500,
          child: SingleChildScrollView(
            child: FormBuilder(
              key: _formKeyDetail,
              child: Column(
                children: [
                  const SizedBox(
                    height: 4,
                  ),
                  Row(
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width / 4,
                        child: FormBuilderTextField(
                          name: 'trashAddress',
                          decoration: customInputDecoration('สถานที่ตั้งขยะ'),
                          validator: FormBuilderValidators.required(
                              errorText: 'กรุณากรอกข้อมูล'),
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: FormBuilderDropdown(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(10)),
                          name: 'houseType',
                          decoration:
                              customInputDecoration('ประเภทของที่อยู่อาศัย'),
                          validator: FormBuilderValidators.required(
                              errorText: 'กรุณากรอกข้อมูล'),
                          items: Constants.houseType
                              .map((item) => DropdownMenuItem(
                                    alignment: AlignmentDirectional.centerStart,
                                    value: item["name"],
                                    child: Text(
                                      item["value"].toString(),
                                    ),
                                  ))
                              .toList(),
                          valueTransformer: (val) => val?.toString(),
                          onChanged: (val) {
                            if (["โรงแรม", "ห้องเช่า/อพาร์ทเม้นท์"]
                                .contains(val)) {
                              setState(() {
                                showRoom = true;
                                showDetail = false;
                              });
                            } else if (val == "อื่นๆ") {
                              setState(() {
                                showDetail = true;
                                showRoom = false;
                              });
                            } else {
                              setState(() {
                                showRoom = false;
                                showDetail = false;
                              });
                            }
                          },
                        ),
                      ),
                      const SizedBox(
                        width: 12,
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  showRoom
                      ? SizedBox(
                          width: MediaQuery.of(context).size.width / 4,
                          child: FormBuilderTextField(
                            name: 'noOfRoom',
                            decoration: customInputDecoration('จำนวนห้อง'),
                            validator: FormBuilderValidators.required(
                                errorText: 'กรุณากรอกข้อมูล'),
                          ),
                        )
                      : Container(),
                  const SizedBox(
                    height: 8,
                  ),
                  showDetail
                      ? FormBuilderTextField(
                          name: 'noOfRoom',
                          maxLines: 3,
                          minLines: 3,
                          decoration: customInputDecoration('อื่น'),
                          validator: FormBuilderValidators.required(
                              errorText: 'กรุณากรอกข้อมูล'),
                        )
                      : const SizedBox(),
                  const Text(
                    'ปริมาณขยะมูลฝอย',
                    style: TextStyle(fontSize: 13),
                  ),
                  const SizedBox(
                    height: 4,
                  ),
                  Row(
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width / 4,
                        child: FormBuilderTextField(
                          name: 'quantityDailyLitre',
                          decoration: customInputDecoration('ลิตร รายวัน'),
                          validator: FormBuilderValidators.required(
                              errorText: 'กรุณากรอกข้อมูล'),
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width / 4,
                        child: FormBuilderTextField(
                          name: 'quantityWeeklyLitre',
                          decoration: customInputDecoration('ลิตร รายสัปดาห์'),
                          validator: FormBuilderValidators.required(
                              errorText: 'กรุณากรอกข้อมูล'),
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: FormBuilderTextField(
                          name: 'pricePerMonth',
                          decoration: customInputDecoration('ราคาต่อเดือน'),
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
                          name: 'trashNo',
                          decoration: customInputDecoration('หมายเลข ถัง'),
                          validator: FormBuilderValidators.required(
                              errorText: 'กรุณากรอกข้อมูล'),
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: FormBuilderTextField(
                          name: 'trashColor',
                          decoration: customInputDecoration('สี'),
                          validator: FormBuilderValidators.required(
                              errorText: 'กรุณากรอกข้อมูล'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  const Text(
                    'จำนวนถังขยะ',
                    style: TextStyle(fontSize: 13),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  FormBuilderTextField(
                    name: 'totalBin',
                    decoration: customInputDecoration('จำนวนถังขยะที่ขอใหม่'),
                    validator: FormBuilderValidators.required(
                        errorText: 'กรุณากรอกข้อมูล'),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  Row(
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width / 4,
                        child: FormBuilderTextField(
                          name: 'totalOldBin',
                          decoration: customInputDecoration('จำนวนของเดิม'),
                          validator: FormBuilderValidators.required(
                              errorText: 'กรุณากรอกข้อมูล'),
                        ),
                      ),
                      const SizedBox(
                        width: 8,
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width / 8,
                        child: FormBuilderTextField(
                          name: 'totalUsedBin',
                          decoration: customInputDecoration('ใช้ได้'),
                          validator: FormBuilderValidators.required(
                              errorText: 'กรุณากรอกข้อมูล'),
                        ),
                      ),
                      const SizedBox(
                        width: 8,
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width / 8,
                        child: FormBuilderTextField(
                          name: 'totalBrokenBin',
                          decoration: customInputDecoration('ชำรุด'),
                          validator: FormBuilderValidators.required(
                              errorText: 'กรุณากรอกข้อมูล'),
                        ),
                      ),
                      const SizedBox(
                        width: 8,
                      ),
                      Expanded(
                        child: FormBuilderTextField(
                          name: 'yearRecOldBin',
                          decoration: customInputDecoration('พ.ศ. ที่ได้รับ'),
                          validator: FormBuilderValidators.required(
                              errorText: 'กรุณากรอกข้อมูล'),
                        ),
                      ),
                    ],
                  ),
                  FormBuilderSwitch(
                    title: const Text(
                      'ยินยอมให้จัดวางถังขยะบริเวณบ้านและดูแลทำความสะอาดถังขยะ และบริเวณที่จัดวางถังขยะให้สะอาด',
                      style: TextStyle(fontSize: 13),
                    ),
                    name: 'allowPlaceBin',
                    initialValue: true,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  const Text(
                    'ต้องการให้องค์การบริหารส่วนตำบลหนองปลาหมอจัดเก็บขยะมูลฝอยและยินดีชำระค่าบริการจัดเก็บขยะตามราคาของข้อบังคับตำบลว่าด้วยการจัดเก็บขยะมูลฝอยและสิ่งปฏิกูล พ.ศ. 2546',
                    style: TextStyle(fontSize: 13),
                  ),
                  FormBuilderCheckboxGroup<String>(
                    wrapDirection: Axis.vertical,
                    name: 'allowPayment',
                    initialValue: const ['ต้องการ'],
                    options: const [
                      FormBuilderFieldOption(value: 'ต้องการ'),
                      FormBuilderFieldOption(value: 'แบบจ่ายรายเดือน'),
                    ],
                    separator: const Divider(
                      thickness: 5,
                      color: Colors.black,
                    ),
                    onChanged: (val) {
                      debugPrint("$val");
                      setState(() {
                        allowPayment = val!;
                      });
                    },
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.minLength(1),
                      FormBuilderValidators.maxLength(2),
                    ]),
                  ),
                  allowPayment.contains("แบบจ่ายรายเดือน")
                      ? FormBuilderTextField(
                          name: 'monthlyPrice',
                          decoration: const InputDecoration(labelText: 'Baht'),
                          validator: FormBuilderValidators.required(
                              errorText: 'กรุณากรอกข้อมูล'),
                          style: const TextStyle(fontSize: 12),
                        )
                      : Container(),
                  FormBuilderSwitch(
                    title: const Text(
                      'หากไม่ชำระค่าบริการจัดเก็บขยะภายใน 2 เดือน ยินยอมให้ทางองค์การบริหารส่วนตำบลหนองปลาหมอดำเนินการจัดเก็บถังขยะคืน',
                      style: TextStyle(fontSize: 12),
                    ),
                    name: 'allowReturnBin',
                    initialValue: true,
                  ),
                ],
              ),
            ),
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
          key: _formKeyUpload,
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
              const Divider(),
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
                        child: Image.file(File(imageIDCard!.path)),
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('ปักหมุดตำแหน่ง'),
                      // ignore: unnecessary_null_comparison
                      location != null
                          ? Text(location.toString())
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
                              apiKey: "AIzaSyBB2X6grO8t8zyW6cktVqBs7duJP0mqN3A",
                              canPopOnNextButtonTaped: false,
                              currentLatLng: const LatLng(14, 100),
                              mapType: MapType.satellite,
                              onTap: (LatLng selectedLatLng) {
                                setState(() {
                                  location = Location(
                                    lat: selectedLatLng.latitude,
                                    lng: selectedLatLng.longitude,
                                  );
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
        "ไม่มีทะเบียนบ้าน",
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
          imageIDCard!.path, imageIDCard!.name, Constants.trashBucketId);

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
          imageIDHouse!.path, imageIDHouse!.name, Constants.trashBucketId);

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

      var filesArray = [];
      if (imageOthers != null) {
        for (var item in imageOthers!) {
          // upload image
          var result = await AppwriteService().uploadPicture(
            item.path,
            item.name,
            Constants.trashBucketId,
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
      var trashData = await AppwriteService().createTrashRequest({
        ...detail,
        "coordinates":
            jsonEncode([location?.lng.toString(), location?.lat.toString()]),
        "nationalIdImg": filesArrayIDCard,
        "houseCertImg": filesArrayIDHouse,
        "generalFormId": generalRequest?.data["\$id"].toString(),
        "otherImages": filesArray
      });

      // create request
      var accunt = await AppwriteService().getAccount();
      DateTime now = DateTime.now();
      var epochTime = (now.millisecondsSinceEpoch / 1000).round();
      var lastTotal = await AppwriteService().countTrash();
      var unitDetail = await AppwriteService()
          .getUnit(docExist.documents[0].data["docOwner"].toString());
      var currentYear = (DateTime.now().year + 543).toString();
      AppwriteService().createRequest({
        "docSeq":
            '${unitDetail?.data["unit_id"]}-T-${lastTotal?.total.toString().padLeft(4, '0')}/${currentYear.substring(currentYear.length - 2)}', // "T"
        "name": 'ความต้องการให้เก็บขยะมูลฝอยตำบลหนองปลาหมอ',
        "docCode": docExist.documents[0].data["\$id"].toString(),
        "userId": accunt?.$id,
        "status": "new",
        "requestedAt": epochTime,
        "type": docName,
        "docId": trashData?.data["\$id"].toString(),
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
          heroTag: 'to_home_7',
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
      final image = await ImagePicker().pickImage(source: ImageSource.camera);
      if (image == null) return;
      if (type == "ID") {
        setState(() {
          imageIDCard = image;
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
      final image = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (image == null) return;
      if (type == "ID") {
        setState(() {
          imageIDCard = image;
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
