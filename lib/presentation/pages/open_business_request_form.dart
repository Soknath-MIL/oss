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
            const EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
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
                          "houseNo": _messageConroller.accountData["data"]
                              ["houseNo"],
                          "moo": _messageConroller.accountData["data"]["moo"],
                          "soi": _messageConroller.accountData["data"]["soi"],
                          "road": _messageConroller.accountData["data"]["road"],
                          "phone": _messageConroller.accountData["data"]
                              ["phone"],
                          "tambon": dataMap["tambon"],
                          "amphoe": dataMap["amphoe"],
                          "province": dataMap["province"],
                          "postcode": dataMap["postcode"],
                          "workplace": "xx",
                          "purpose": "xx"
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
                                  width: MediaQuery.of(context).size.width / 4,
                                  child: FormBuilderDropdown<String>(
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(10)),
                                    name: 'title',
                                    decoration:
                                        customInputDecoration('คำนำหน้า'),
                                    validator: FormBuilderValidators.required(),
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
                                    validator: FormBuilderValidators.required(),
                                  ),
                                ),
                                const SizedBox(
                                  width: 8,
                                ),
                                Expanded(
                                  child: FormBuilderTextField(
                                    name: 'lastname',
                                    style: const TextStyle(fontSize: 13),
                                    decoration:
                                        customInputDecoration('นามสกุล'),
                                    validator: FormBuilderValidators.required(),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 8,
                            ),
                            // Row(
                            //   children: [
                            //     Expanded(
                            //       child: FormBuilderTextField(
                            //         name: 'address',
                            //         decoration:
                            //             customInputDecoration("ที่อยู่"),
                            //         validator: FormBuilderValidators.required(),
                            //       ),
                            //     ),
                            //   ],
                            // ),

                            Row(
                              children: [
                                SizedBox(
                                  width: MediaQuery.of(context).size.width / 3,
                                  child: FormBuilderTextField(
                                    name: 'houseNo',
                                    decoration:
                                        customInputDecoration("บ้านเลขที่"),
                                    validator: FormBuilderValidators.required(),
                                  ),
                                ),
                                const SizedBox(
                                  width: 8,
                                ),
                                Expanded(
                                  child: FormBuilderTextField(
                                    name: 'moo',
                                    decoration:
                                        customInputDecoration("หมู่ที่"),
                                    validator: FormBuilderValidators.required(),
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
                                  width: MediaQuery.of(context).size.width / 3,
                                  child: FormBuilderTextField(
                                    name: 'soi',
                                    decoration:
                                        customInputDecoration("ตรอก/ซอย"),
                                    validator: FormBuilderValidators.required(),
                                  ),
                                ),
                                const SizedBox(
                                  width: 8,
                                ),
                                Expanded(
                                  child: FormBuilderTextField(
                                    name: 'road',
                                    decoration: customInputDecoration("ถนน"),
                                    validator: FormBuilderValidators.required(),
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
                                  width: MediaQuery.of(context).size.width / 3,
                                  child: FormBuilderTextField(
                                    name: 'tambon',
                                    decoration: customInputDecoration('ตำบล'),
                                    validator: FormBuilderValidators.required(),
                                  ),
                                ),
                                const SizedBox(
                                  width: 8,
                                ),
                                Expanded(
                                  child: FormBuilderTextField(
                                    name: 'amphoe',
                                    decoration: customInputDecoration('อำเภอ'),
                                    validator: FormBuilderValidators.required(),
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
                                  width: MediaQuery.of(context).size.width / 2,
                                  child: FormBuilderTextField(
                                    name: 'province',
                                    decoration:
                                        customInputDecoration('จังหวัด'),
                                    validator: FormBuilderValidators.required(),
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
                                    validator: FormBuilderValidators.required(),
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
                                  width: MediaQuery.of(context).size.width / 3,
                                  child: FormBuilderTextField(
                                    name: 'phone',
                                    decoration:
                                        customInputDecoration('โทรศัพท์'),
                                    validator: FormBuilderValidators.required(),
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
                                    validator: FormBuilderValidators.required(),
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
                              decoration: customInputDecoration('วัตถุประสงค์'),
                              validator: FormBuilderValidators.required(),
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
        content: SizedBox(
          height: 500,
          child: SingleChildScrollView(
            child: FormBuilder(
              key: _formKeyDetail,
              initialValue: const {
                'nationality': 'xx',
                'corporation': 'xx',
                'typeB1': 'xx',
                'areaB1': 'xx',
                'totalPersonB1': 'xx',
                'nameB1': 'xx',
                'addressB1': 'xx',
                'typeB2': 'xx',
                'totalPersonB2': 'xx',
                'machineSizeB2': 'xx',
                'nameB2': 'xx',
                'totalRoomB2': 'xx',
                'addressB2': 'xx',
                'typeB3': 'xx',
                'addressB3': 'xx',
                'methodB3': 'xx',
                'nameB4_1': 'xx',
                'nameB4_2': 'xx',
                'nameB4_3': 'xx',
                'nameB4_4': 'xx',
              },
              child: Column(
                children: [
                  Row(
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width / 3,
                        child: FormBuilderTextField(
                          name: 'nationality',
                          decoration: customInputDecoration('สัญชาติ'),
                          validator: FormBuilderValidators.required(),
                        ),
                      ),
                      const SizedBox(
                        width: 4,
                      ),
                      Expanded(
                        child: FormBuilderTextField(
                          name: 'corporation',
                          decoration:
                              customInputDecoration('กรณีเป็นนิติบุคคล'),
                          validator: FormBuilderValidators.required(),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  const Text(
                    'สถานที่จำหน่ายอาหารหรือสะสมอาหาร ',
                  ),
                  SizedBox(
                    child: FormBuilderTextField(
                      name: 'typeB1',
                      decoration: customInputDecoration('ประเภท'),
                      validator: FormBuilderValidators.required(),
                    ),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  Row(
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width / 3,
                        child: FormBuilderTextField(
                          name: 'areaB1',
                          decoration: customInputDecoration(
                              'โดยมีพื้นที่ประกอบการ (ตารางเมตร)'),
                          validator: FormBuilderValidators.required(),
                        ),
                      ),
                      const SizedBox(
                        width: 4,
                      ),
                      Expanded(
                        child: FormBuilderTextField(
                          name: 'totalPersonB1',
                          decoration: customInputDecoration(
                              'มีบุคคลที่เกี่ยวข้องรวม (คน)'),
                          validator: FormBuilderValidators.required(),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  SizedBox(
                    child: FormBuilderTextField(
                      name: 'nameB1',
                      decoration: customInputDecoration('โดยใช้ชื่อว่า'),
                      validator: FormBuilderValidators.required(),
                    ),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  SizedBox(
                    child: FormBuilderTextField(
                      name: 'addressB1',
                      decoration: customInputDecoration('ตั้งอยู่เลขที่'),
                      validator: FormBuilderValidators.required(),
                    ),
                  ),
                  const Divider(),
                  const Text(
                    'กิจการที่เป็นอันตรายต่อสุขภาพ',
                  ),
                  SizedBox(
                    child: FormBuilderTextField(
                      name: 'typeB2',
                      decoration: customInputDecoration('ประเภท'),
                      validator: FormBuilderValidators.required(),
                    ),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  Row(
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width / 3,
                        child: FormBuilderTextField(
                          name: 'totalPersonB2',
                          decoration: customInputDecoration('มีคนงาน (คน)'),
                          validator: FormBuilderValidators.required(),
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
                          validator: FormBuilderValidators.required(),
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
                        width: MediaQuery.of(context).size.width / 3,
                        child: FormBuilderTextField(
                          name: 'nameB2',
                          decoration: customInputDecoration('โดยใช้ชื่อว่า'),
                          validator: FormBuilderValidators.required(),
                        ),
                      ),
                      const SizedBox(
                        width: 4,
                      ),
                      Expanded(
                        child: FormBuilderTextField(
                          name: 'totalRoomB2',
                          decoration: customInputDecoration('จำนวน(ห้อง)'),
                          validator: FormBuilderValidators.required(),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  SizedBox(
                    child: FormBuilderTextField(
                      name: 'addressB2',
                      decoration: customInputDecoration('ตั้งอยู่เลขที่'),
                      validator: FormBuilderValidators.required(),
                    ),
                  ),
                  const Divider(),
                  const Text(
                    'กิจกรรมจำหน่ายสินค้าในที่ / ทางสาธารณะ จำหน่ายสินค้า',
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  SizedBox(
                    child: FormBuilderTextField(
                      name: 'typeB3',
                      decoration: customInputDecoration('ประเภท'),
                      validator: FormBuilderValidators.required(),
                    ),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  Row(
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width / 3,
                        child: FormBuilderTextField(
                          name: 'addressB3',
                          decoration: customInputDecoration('ณ บริเวณ'),
                          validator: FormBuilderValidators.required(),
                        ),
                      ),
                      const SizedBox(
                        width: 4,
                      ),
                      Expanded(
                        child: FormBuilderTextField(
                          name: 'methodB3',
                          decoration: customInputDecoration('โดยวิธีการ'),
                          validator: FormBuilderValidators.required(),
                        ),
                      ),
                    ],
                  ),
                  const Divider(),
                  const Text(
                    'กิจการรับทำการเก็บ ขนหรือกำจัดสิ่งปฏิกูลมูลฝอยโดยทำเป็นธุรกิจ ประเภท',
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  SizedBox(
                    child: FormBuilderTextField(
                      name: 'nameB4_1',
                      decoration: customInputDecoration(
                          'เก็บขนสิ่งปฏิกูล โดยมีแหล่งจำกัดที่'),
                      validator: FormBuilderValidators.required(),
                    ),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  SizedBox(
                    child: FormBuilderTextField(
                      name: 'nameB4_2',
                      decoration: customInputDecoration(
                          'เก็บขนและกำจัดสิ่งปฏิกูล โดยมีระบบกำจัดอยู่ที่'),
                      validator: FormBuilderValidators.required(),
                    ),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  SizedBox(
                    child: FormBuilderTextField(
                      name: 'nameB4_3',
                      decoration: customInputDecoration(
                          'เก็บขนขยะมูลฝอย โดยมีแหล่งกำจัดที่'),
                      validator: FormBuilderValidators.required(),
                    ),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  SizedBox(
                    child: FormBuilderTextField(
                      name: 'nameB4_4',
                      decoration: customInputDecoration(
                          'เก็บขนและกำจัดมูลฝอย โดยมีระบบกำจัดอยู่ที่'),
                      validator: FormBuilderValidators.required(),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
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
                              onNext: (GeocodingResult? result) {
                                if (result != null) {
                                  setState(() {
                                    address = result.formattedAddress ?? "";
                                    location = result.geometry.location;
                                  });
                                  Get.back();
                                } else {
                                  debugPrint('No result');
                                  Get.snackbar("No address",
                                      "Please pick location on map",
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
      filesArrayIDCard = jsonEncode([
        {
          ...result!.toMap(),
          "url":
              '${Constants.appwriteEndpoint}/storage/buckets/${result.bucketId}/files/${result.$id}/view?project=${Constants.appwriteProjectId}&mode=admin'
        }
      ]);
      String filesArrayIDHouse;
      var resultUpload = await AppwriteService().uploadPicture(
          imageIDHouse!.path,
          imageIDHouse!.name,
          Constants.openBusinessBucketId);
      filesArrayIDHouse = jsonEncode([
        {
          ...resultUpload!.toMap(),
          "url":
              '${Constants.appwriteEndpoint}/storage/buckets/${resultUpload.bucketId}/files/${resultUpload.$id}/view?project=${Constants.appwriteProjectId}&mode=admin'
        }
      ]);
      String? filesArrayOldCertHouse;
      if (imageOldCert != null) {
        var resultOldCertUpload = await AppwriteService().uploadPicture(
          imageOldCert!.path,
          imageOldCert!.name,
          Constants.openBusinessBucketId,
        );
        filesArrayOldCertHouse = jsonEncode([
          {
            ...resultOldCertUpload!.toMap(),
            "url":
                '${Constants.appwriteEndpoint}/storage/buckets/${resultUpload.bucketId}/files/${resultUpload.$id}/view?project=${Constants.appwriteProjectId}&mode=admin'
          }
        ]);
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
      });

      // create request
      var accunt = await AppwriteService().getAccount();
      DateTime now = DateTime.now();
      var epochTime = (now.millisecondsSinceEpoch / 1000).round();
      AppwriteService().createRequest({
        "docSeq": 'คำขอใบอนุญาตประกอบกิจการ',
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

  void _onChanged(dynamic val) => debugPrint(val.toString());
}
