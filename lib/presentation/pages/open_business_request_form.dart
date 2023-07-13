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

class OpenBusinessRequestPage extends StatefulWidget {
  const OpenBusinessRequestPage({super.key});

  @override
  State<OpenBusinessRequestPage> createState() =>
      _OpenBusinessRequestPageState();
}

class _OpenBusinessRequestPageState extends State<OpenBusinessRequestPage> {
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
  final _formKeyGeneral = GlobalKey<FormBuilderState>();
  final _formKeyDetail = GlobalKey<FormBuilderState>();
  final _formKeyUpload = GlobalKey<FormBuilderState>();
  final String docName = 'openBusiness';
  String address = "null";
  Location? location;
  String autocompletePlace = "null";
  String type = 'สถานที่จำหน่ายอาหารหรือสะสมอาหาร';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ขอรับใบอนุญาต'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(
              height: 10,
            ),
            const Text(
              'ขอรับใบอนุญาตประกอบกิจการ',
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
        content: Column(
          children: [
            configController.obx(
              (state) {
                debugPrint(
                    'debug print ${_messageConroller.accountData["data"]}');
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
                          "address": _messageConroller.accountData["data"]
                              ["address"],
                          // "moo": _messageConroller.accountData["data"]["moo"],
                          // "soi": _messageConroller.accountData["data"]["soi"],
                          // "road": _messageConroller.accountData["data"]["road"],
                          "phone": _messageConroller.accountData["data"]
                              ["phone"],
                          "tambon": dataMap["tambon"],
                          "amphoe": dataMap["amphoe"],
                          "province": dataMap["province"],
                          "postcode": dataMap["postcode"],
                          "workplace": "",
                          "purpose": ""
                        },
                        child: Column(
                          children: [
                            const SizedBox(
                              height: 16,
                            ),
                            Row(
                              children: [
                                SizedBox(
                                  width: MediaQuery.of(context).size.width / 4,
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
                                                  fontSize: 13,
                                                ),
                                              ),
                                            ))
                                        .toList(),
                                    valueTransformer: (val) => val?.toString(),
                                  ),
                                ),
                                const SizedBox(
                                  width: 8,
                                ),
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
                                    decoration:
                                        customInputDecoration('นามสกุล'),
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
                                    decoration:
                                        customInputDecoration("ที่อยู่"),
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
                              height: 10,
                            ),
                            Row(
                              children: [
                                SizedBox(
                                  width: MediaQuery.of(context).size.width / 3,
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
        content: SingleChildScrollView(
          child: FormBuilder(
            key: _formKeyDetail,
            initialValue: const {
              'nationality': '',
              'corporation': '',
              'typeB1': '',
              'areaB1': '',
              'totalPersonB1': '',
              'nameB1': '',
              'addressB1': '',
              'typeB2': '',
              'totalPersonB2': '',
              'machineSizeB2': '',
              'nameB2': '',
              'totalRoomB2': '',
              'addressB2': '',
              'typeB3': '',
              'addressB3': '',
              'methodB3': '',
              'nameB4_1': '',
              'nameB4_2': '',
              'nameB4_3': '',
              'nameB4_4': '',
              'type': 'สถานที่จำหน่ายอาหารหรือสะสมอาหาร'
            },
            child: Column(
              children: [
                const SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width / 3,
                      child: FormBuilderTextField(
                        name: 'nationality',
                        decoration: customInputDecoration('สัญชาติ'),
                        validator: FormBuilderValidators.required(
                            errorText: 'กรุณากรอกข้อมูล'),
                      ),
                    ),
                    const SizedBox(
                      width: 4,
                    ),
                    Expanded(
                      child: FormBuilderTextField(
                        name: 'corporation',
                        decoration: customInputDecoration('กรณีเป็นนิติบุคคล'),
                        validator: FormBuilderValidators.required(
                            errorText: 'กรุณากรอกข้อมูล'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: FormBuilderDropdown<String>(
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
                    items:
                        Constants.BusinessTypes.map((item) => DropdownMenuItem(
                              alignment: AlignmentDirectional.centerStart,
                              value: item["name"],
                              child: Text(
                                item["value"].toString(),
                                style: const TextStyle(
                                  fontSize: 13,
                                ),
                              ),
                            )).toList(),
                    valueTransformer: (val) => val?.toString(),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                const Divider(),
                type == 'สถานที่จำหน่ายอาหารหรือสะสมอาหาร'
                    ? Column(
                        children: [
                          const Text(
                            'สถานที่จำหน่ายอาหารหรือสะสมอาหาร',
                          ),
                          SizedBox(
                            child: FormBuilderTextField(
                              name: 'typeB1',
                              decoration: customInputDecoration('ประเภท'),
                              validator:
                                  type == 'สถานที่จำหน่ายอาหารหรือสะสมอาหาร'
                                      ? FormBuilderValidators.required(
                                          errorText: 'กรุณากรอกข้อมูล')
                                      : null,
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width,
                            child: FormBuilderTextField(
                              name: 'areaB1',
                              decoration: customInputDecoration(
                                  'โดยมีพื้นที่ประกอบการ (ตารางเมตร)'),
                              validator:
                                  type == 'สถานที่จำหน่ายอาหารหรือสะสมอาหาร'
                                      ? FormBuilderValidators.required(
                                          errorText: 'กรุณากรอกข้อมูล')
                                      : null,
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Row(
                            children: [
                              const SizedBox(
                                width: 4,
                              ),
                              Expanded(
                                child: FormBuilderTextField(
                                  name: 'totalPersonB1',
                                  decoration: customInputDecoration(
                                      'มีบุคคลที่เกี่ยวข้องรวม (คน)'),
                                  validator:
                                      type == 'สถานที่จำหน่ายอาหารหรือสะสมอาหาร'
                                          ? FormBuilderValidators.required(
                                              errorText: 'กรุณากรอกข้อมูล')
                                          : null,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          SizedBox(
                            child: FormBuilderTextField(
                              name: 'nameB1',
                              decoration:
                                  customInputDecoration('โดยใช้ชื่อว่า'),
                              validator:
                                  type == 'สถานที่จำหน่ายอาหารหรือสะสมอาหาร'
                                      ? FormBuilderValidators.required(
                                          errorText: 'กรุณากรอกข้อมูล')
                                      : null,
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          SizedBox(
                            child: FormBuilderTextField(
                              name: 'addressB1',
                              decoration:
                                  customInputDecoration('ตั้งอยู่เลขที่'),
                              validator:
                                  type == 'สถานที่จำหน่ายอาหารหรือสะสมอาหาร'
                                      ? FormBuilderValidators.required(
                                          errorText: 'กรุณากรอกข้อมูล')
                                      : null,
                            ),
                          ),
                        ],
                      )
                    : Container(),
                type == 'กิจการที่เป็นอันตรายต่อสุขภาพ'
                    ? Column(
                        children: [
                          const Text(
                            'กิจการที่เป็นอันตรายต่อสุขภาพ',
                          ),
                          SizedBox(
                            child: FormBuilderTextField(
                              name: 'typeB2',
                              decoration: customInputDecoration('ประเภท'),
                              validator: type == 'กิจการที่เป็นอันตรายต่อสุขภาพ'
                                  ? FormBuilderValidators.required(
                                      errorText: 'กรุณากรอกข้อมูล')
                                  : null,
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Row(
                            children: [
                              SizedBox(
                                width: MediaQuery.of(context).size.width / 3,
                                child: FormBuilderTextField(
                                  name: 'totalPersonB2',
                                  decoration:
                                      customInputDecoration('มีคนงาน (คน)'),
                                  validator:
                                      type == 'กิจการที่เป็นอันตรายต่อสุขภาพ'
                                          ? FormBuilderValidators.required(
                                              errorText: 'กรุณากรอกข้อมูล')
                                          : null,
                                ),
                              ),
                              const SizedBox(
                                width: 4,
                              ),
                              Expanded(
                                child: FormBuilderTextField(
                                  name: 'machineSizeB2',
                                  decoration: customInputDecoration(
                                      'ใช้เครื่องจักรขนาด (แรงม้า)'),
                                  validator:
                                      type == 'กิจการที่เป็นอันตรายต่อสุขภาพ'
                                          ? FormBuilderValidators.required(
                                              errorText: 'กรุณากรอกข้อมูล')
                                          : null,
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
                                  name: 'nameB2',
                                  decoration:
                                      customInputDecoration('โดยใช้ชื่อว่า'),
                                  validator:
                                      type == 'กิจการที่เป็นอันตรายต่อสุขภาพ'
                                          ? FormBuilderValidators.required(
                                              errorText: 'กรุณากรอกข้อมูล')
                                          : null,
                                ),
                              ),
                              const SizedBox(
                                width: 4,
                              ),
                              Expanded(
                                child: FormBuilderTextField(
                                  name: 'totalRoomB2',
                                  decoration:
                                      customInputDecoration('จำนวน(ห้อง)'),
                                  validator:
                                      type == 'กิจการที่เป็นอันตรายต่อสุขภาพ'
                                          ? FormBuilderValidators.required(
                                              errorText: 'กรุณากรอกข้อมูล')
                                          : null,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          SizedBox(
                            child: FormBuilderTextField(
                              name: 'addressB2',
                              decoration:
                                  customInputDecoration('ตั้งอยู่เลขที่'),
                              validator: type == 'กิจการที่เป็นอันตรายต่อสุขภาพ'
                                  ? FormBuilderValidators.required(
                                      errorText: 'กรุณากรอกข้อมูล')
                                  : null,
                            ),
                          ),
                        ],
                      )
                    : Container(),
                type == 'กิจกรรมจำหน่ายสินค้าในที่ / ทางสาธารณะ จำหน่ายสินค้า'
                    ? Column(
                        children: [
                          const Text(
                            'กิจกรรมจำหน่ายสินค้าในที่ / ทางสาธารณะ จำหน่ายสินค้า',
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          SizedBox(
                            child: FormBuilderTextField(
                              name: 'typeB3',
                              decoration: customInputDecoration('ประเภท'),
                              validator: type ==
                                      'กิจกรรมจำหน่ายสินค้าในที่ / ทางสาธารณะ จำหน่ายสินค้า'
                                  ? FormBuilderValidators.required(
                                      errorText: 'กรุณากรอกข้อมูล')
                                  : null,
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Row(
                            children: [
                              SizedBox(
                                width: MediaQuery.of(context).size.width / 3,
                                child: FormBuilderTextField(
                                  name: 'addressB3',
                                  decoration: customInputDecoration('ณ บริเวณ'),
                                  validator: type ==
                                          'กิจกรรมจำหน่ายสินค้าในที่ / ทางสาธารณะ จำหน่ายสินค้า'
                                      ? FormBuilderValidators.required(
                                          errorText: 'กรุณากรอกข้อมูล')
                                      : null,
                                ),
                              ),
                              const SizedBox(
                                width: 4,
                              ),
                              Expanded(
                                child: FormBuilderTextField(
                                  name: 'methodB3',
                                  decoration:
                                      customInputDecoration('โดยวิธีการ'),
                                  validator: type ==
                                          'กิจกรรมจำหน่ายสินค้าในที่ / ทางสาธารณะ จำหน่ายสินค้า'
                                      ? FormBuilderValidators.required(
                                          errorText: 'กรุณากรอกข้อมูล')
                                      : null,
                                ),
                              ),
                            ],
                          ),
                        ],
                      )
                    : Container(),
                type == 'กิจการรับทำการเก็บ ขนหรือกำจัดสิ่งปฏิกูลมูลฝอย'
                    ? Column(
                        children: [
                          const Text(
                            'กิจการรับทำการเก็บ ขนหรือกำจัดสิ่งปฏิกูลมูลฝอยโดยทำเป็นธุรกิจ ประเภท',
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          SizedBox(
                            child: FormBuilderTextField(
                              name: 'nameB4_1',
                              decoration: customInputDecoration(
                                  'เก็บขนสิ่งปฏิกูล โดยมีแหล่งจำกัดที่'),
                              validator: type ==
                                      'กิจการรับทำการเก็บ ขนหรือกำจัดสิ่งปฏิกูลมูลฝอย'
                                  ? FormBuilderValidators.required(
                                      errorText: 'กรุณากรอกข้อมูล')
                                  : null,
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          SizedBox(
                            child: FormBuilderTextField(
                              name: 'nameB4_2',
                              decoration: customInputDecoration(
                                  'เก็บขนและกำจัดสิ่งปฏิกูล โดยมีระบบกำจัดอยู่ที่'),
                              validator: type ==
                                      'กิจการรับทำการเก็บ ขนหรือกำจัดสิ่งปฏิกูลมูลฝอย'
                                  ? FormBuilderValidators.required(
                                      errorText: 'กรุณากรอกข้อมูล')
                                  : null,
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          SizedBox(
                            child: FormBuilderTextField(
                              name: 'nameB4_3',
                              decoration: customInputDecoration(
                                  'เก็บขนขยะมูลฝอย โดยมีแหล่งกำจัดที่'),
                              validator: type ==
                                      'กิจการรับทำการเก็บ ขนหรือกำจัดสิ่งปฏิกูลมูลฝอย'
                                  ? FormBuilderValidators.required(
                                      errorText: 'กรุณากรอกข้อมูล')
                                  : null,
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          SizedBox(
                            child: FormBuilderTextField(
                              name: 'nameB4_4',
                              decoration: customInputDecoration(
                                  'เก็บขนและกำจัดมูลฝอย โดยมีระบบกำจัดอยู่ที่'),
                              validator: type ==
                                      'กิจการรับทำการเก็บ ขนหรือกำจัดสิ่งปฏิกูลมูลฝอย'
                                  ? FormBuilderValidators.required(
                                      errorText: 'กรุณากรอกข้อมูล')
                                  : null,
                            ),
                          ),
                        ],
                      )
                    : Container(),
                const SizedBox(
                  height: 20,
                ),
              ],
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('เลือกรูปภาพ ใบรับรองบ้าน'),
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
          imageIDCard!.path, imageIDCard!.name, Constants.openBusinessBucketId);

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
          Constants.openBusinessBucketId,
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
            Constants.openBusinessBucketId,
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
      var openBusinessData =
          await AppwriteService().createOpenBussinessRequest({
        ...detail,
        "coordinates":
            jsonEncode([location?.lng.toString(), location?.lat.toString()]),
        "nationalIdImg": filesArrayIDCard,
        "houseCertImg": filesArrayIDHouse,
        "oldCertImg": filesArrayOldCertHouse,
        "generalFormId": generalRequest?.data["\$id"].toString(),
        "otherImages": filesArray
      });

      // create request
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
        "name": 'คำขอใบอนุญาตประกอบกิจการ',
        "docCode": docExist.documents[0].data["\$id"].toString(),
        "userId": accunt?.$id,
        "status": "new",
        "requestedAt": epochTime,
        "type": docName,
        "docId": openBusinessData?.data["\$id"].toString(),
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
      final image = await ImagePicker().pickImage(source: ImageSource.camera);
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
      final image = await ImagePicker().pickImage(source: ImageSource.gallery);
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
