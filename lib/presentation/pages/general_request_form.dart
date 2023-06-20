import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_shimmer/flutter_shimmer.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:map_location_picker/map_location_picker.dart';
import 'package:oss/presentation/controllers/config_controller.dart';
import 'package:oss/presentation/controllers/message_controller.dart';

import '../../constants/constants.dart';
import '../../data/services/appwrite_service.dart';

class GeneralRequestPage extends StatefulWidget {
  const GeneralRequestPage({super.key});

  @override
  State<GeneralRequestPage> createState() => _GeneralRequestPageState();
}

class _GeneralRequestPageState extends State<GeneralRequestPage> {
  final ConfigController configController = Get.put(ConfigController());
  final MessageConroller _messageConroller = Get.put(MessageConroller());
  final ImagePicker imgpicker = ImagePicker();
  XFile? imageIDCard;
  XFile? imageIDHouse;
  final _formKey = GlobalKey<FormBuilderState>();
  final String docName = 'ems';
  String address = "null";
  Location? location;
  String autocompletePlace = "null";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('คำร้องทั่วไป'),
      ),
      body: SingleChildScrollView(
        child: configController.obx(
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
                      key: _formKey,
                      initialValue: {
                        "title": _messageConroller.accountData["data"]["title"],
                        "firstname": _messageConroller.accountData["data"]
                            ["firstname"],
                        "lastname": _messageConroller.accountData["data"]
                            ["lastname"],
                        "address": _messageConroller.accountData["data"]
                            ["address"],
                        "phone": _messageConroller.accountData["data"]["phone"],
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
                                width: MediaQuery.of(context).size.width / 4,
                                child: FormBuilderDropdown<String>(
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(10)),
                                  name: 'title',
                                  decoration: customInputDecoration('คำนำหน้า'),
                                  validator: FormBuilderValidators.required(),
                                  items: Constants.titleOptions
                                      .map((item) => DropdownMenuItem(
                                            alignment: AlignmentDirectional
                                                .centerStart,
                                            value: item["name"],
                                            child:
                                                Text(item["value"].toString()),
                                          ))
                                      .toList(),
                                  valueTransformer: (val) => val?.toString(),
                                ),
                              ),
                              const SizedBox(
                                width: 8,
                              ),
                              SizedBox(
                                width: MediaQuery.of(context).size.width / 3,
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
                                  decoration: customInputDecoration('นามสกุล'),
                                  validator: FormBuilderValidators.required(),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 16,
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: FormBuilderTextField(
                                  name: 'address',
                                  decoration: customInputDecoration("ที่อยู่"),
                                  validator: FormBuilderValidators.required(),
                                ),
                              ),
                              const SizedBox(
                                width: 8,
                              ),
                              SizedBox(
                                width: MediaQuery.of(context).size.width / 3,
                                child: FormBuilderTextField(
                                  name: 'tambon',
                                  decoration: customInputDecoration('ตำบล'),
                                  validator: FormBuilderValidators.required(),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 16,
                          ),
                          Row(
                            children: [
                              SizedBox(
                                width: MediaQuery.of(context).size.width / 4,
                                child: FormBuilderTextField(
                                  name: 'amphoe',
                                  decoration: customInputDecoration('อำเภอ'),
                                  validator: FormBuilderValidators.required(),
                                ),
                              ),
                              const SizedBox(
                                width: 8,
                              ),
                              SizedBox(
                                width: MediaQuery.of(context).size.width / 3,
                                child: FormBuilderTextField(
                                  name: 'province',
                                  decoration: customInputDecoration('จังหวัด'),
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
                            height: 16,
                          ),
                          Row(
                            children: [
                              SizedBox(
                                width: MediaQuery.of(context).size.width / 3,
                                child: FormBuilderTextField(
                                  name: 'phone',
                                  decoration: customInputDecoration('โทรศัพท์'),
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
                            height: 16,
                          ),
                          FormBuilderTextField(
                            name: 'requestName',
                            decoration: customInputDecoration('ชื่อ'),
                            validator: FormBuilderValidators.required(),
                          ),
                          const SizedBox(
                            height: 16,
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
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('ปักหมุดตำแหน่ง'),
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
                                    apiKey:
                                        "AIzaSyBB2X6grO8t8zyW6cktVqBs7duJP0mqN3A",
                                    canPopOnNextButtonTaped: false,
                                    currentLatLng: const LatLng(14, 100),
                                    mapType: MapType.satellite,
                                    onNext: (GeocodingResult? result) {
                                      debugPrint('result $result');
                                      debugPrint(
                                          'result ${result?.formattedAddress}');
                                      if (result != null) {
                                        setState(() {
                                          address =
                                              result.formattedAddress ?? "";
                                          location = result.geometry.location;
                                        });
                                        Get.back();
                                      } else {
                                        debugPrint('No result');
                                        Get.snackbar("No address",
                                            "Please pick location on map",
                                            titleText: const Text(
                                              "No address",
                                              style: TextStyle(
                                                  color: Colors.white),
                                            ),
                                            messageText: const Text(
                                              "Please pick location on map",
                                              style: TextStyle(
                                                  color: Colors.white),
                                            ),
                                            snackPosition: SnackPosition.BOTTOM,
                                            duration:
                                                const Duration(seconds: 1),
                                            icon: const Icon(Icons.info));
                                      }
                                    },
                                    onSuggestionSelected:
                                        (PlacesDetailsResponse? result) {
                                      if (result != null) {
                                        setState(() {
                                          autocompletePlace =
                                              result.result.formattedAddress ??
                                                  "";
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
                    Container(
                      margin: const EdgeInsets.all(16),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              height: 40,
                              child: FittedBox(
                                child: FloatingActionButton.extended(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  backgroundColor: Colors.grey,
                                  heroTag: 'reset',
                                  onPressed: () {},
                                  icon: const Icon(Icons.refresh),
                                  label: const Text(
                                    'รีเซ็ต',
                                    style: TextStyle(fontSize: 18),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            SizedBox(
                              height: 40,
                              child: FittedBox(
                                child: FloatingActionButton.extended(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    backgroundColor: Colors.green,
                                    heroTag: 'submit',
                                    onPressed: () {
                                      if (_formKey.currentState!.validate()) {
                                        _formKey.currentState!.save();
                                        handleSubmit(
                                            _formKey.currentState!.value);
                                      }
                                    },
                                    icon: const Icon(Icons.upload),
                                    label: const Text(
                                      'ส่ง',
                                      style: TextStyle(fontSize: 18),
                                    )),
                              ),
                            ),
                          ]),
                    )
                  ],
                ),
              );
            });
          },
          onLoading: Center(
              child: Column(
            children: const [
              ListTileShimmer(),
              ListTileShimmer(),
              ListTileShimmer(),
            ],
          )),
        ),
      ),
    );
  }

  void checkLogin() async {
    await _messageConroller.getUserId();
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

  void handleSubmit(Map<String, dynamic> value) async {
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
          imageIDCard!.path, imageIDCard!.name, Constants.emsBucketId);
      filesArrayIDCard = jsonEncode([
        {
          ...result!.toMap(),
          "url":
              '${Constants.appwriteEndpoint}/storage/buckets/${result.bucketId}/files/${result.$id}/view?project=${Constants.appwriteProjectId}&mode=admin'
        }
      ]);
      String filesArrayIDHouse;
      var resultUpload = await AppwriteService().uploadPicture(
          imageIDHouse!.path, imageIDHouse!.name, Constants.generalBucketId);
      filesArrayIDHouse = jsonEncode([
        {
          ...resultUpload!.toMap(),
          "url":
              '${Constants.appwriteEndpoint}/storage/buckets/${resultUpload.bucketId}/files/${resultUpload.$id}/view?project=${Constants.appwriteProjectId}&mode=admin'
        }
      ]);

      // create appeal record
      var emsData = await AppwriteService().createGeneralRequest({
        ...value,
        "coordinates":
            jsonEncode([location?.lng.toString(), location?.lat.toString()]),
        "nationalIdImg": filesArrayIDCard,
        "houseCertImg": filesArrayIDHouse,
      });

      debugPrint('request data ${emsData?.data["\$id"].toString()}');

      // create request
      var accunt = await AppwriteService().getAccount();
      DateTime now = DateTime.now();
      var epochTime = (now.millisecondsSinceEpoch / 1000).round();
      AppwriteService().createRequest({
        "docSeq": 'คำร้องทั่วไป',
        "docCode": docExist.documents[0].data["\$id"].toString(),
        "userId": accunt?.$id,
        "status": "new",
        "requestedAt": epochTime,
        "type": docName,
        "docId": emsData?.data["\$id"].toString(),
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
          heroTag: 'to_home_4',
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

  void _onChanged(dynamic val) => debugPrint(val.toString());
}
