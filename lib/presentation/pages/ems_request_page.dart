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

class EmsRequestPage extends StatefulWidget {
  const EmsRequestPage({super.key});

  @override
  State<EmsRequestPage> createState() => _EmsRequestPageState();
}

class _EmsRequestPageState extends State<EmsRequestPage> {
  final ConfigController configController = Get.put(ConfigController());
  final MessageConroller _messageConroller = Get.put(MessageConroller());
  final ImagePicker imgpicker = ImagePicker();
  XFile? imageIDCard;
  XFile? imageIDHouse;
  List<XFile>? imageOthers = [];
  final _formKey = GlobalKey<FormBuilderState>();
  final String docName = 'ems';
  String address = "null";
  Location? location;
  String autocompletePlace = "null";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('บริการการแพทย์ฉุกเฉิน'),
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
                          FormBuilderDropdown(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(10)),
                            name: 'patientType',
                            decoration: customInputDecoration('ประเภทผู้ป่วย'),
                            validator: FormBuilderValidators.required(),
                            items: Constants.patientOptions
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
                            height: 16,
                          ),
                          FormBuilderDateTimePicker(
                            name: 'bookedDate',
                            initialEntryMode: DatePickerEntryMode.calendar,
                            // initialValue: DateTime.now(),
                            inputType: InputType.both,
                            firstDate: DateTime.now(),
                            decoration: customInputDecoration('วันที่จอง'),
                            validator: FormBuilderValidators.required(),
                            initialTime: const TimeOfDay(hour: 8, minute: 0),
                            // locale: const Locale.fromSubtags(languageCode: 'fr'),
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
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8.0),
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
                                    apiKey:
                                        "AIzaSyBB2X6grO8t8zyW6cktVqBs7duJP0mqN3A",
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
                                          address =
                                              result.formattedAddress ?? "";
                                        });
                                        Get.back();
                                      } else {
                                        debugPrint('No result');
                                        Get.snackbar("ไม่มีที่อยู่",
                                            "กรุณาเลือกตำแหน่งบนแผนที่",
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
          imageIDHouse!.path, imageIDHouse!.name, Constants.emsBucketId);

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
      var emsData = await AppwriteService().createEMSRequest({
        ...value,
        "coordinates":
            jsonEncode([location?.lng.toString(), location?.lat.toString()]),
        "bookedDate": value['bookedDate'].millisecondsSinceEpoch,
        "nationalIdImg": filesArrayIDCard,
        "houseCertImg": filesArrayIDHouse,
        "otherImages": filesArray
      });

      debugPrint('ems data ${emsData?.data["\$id"].toString()}');

      // create request
      var accunt = await AppwriteService().getAccount();
      DateTime now = DateTime.now();
      var epochTime = (now.millisecondsSinceEpoch / 1000).round();
      var lastTotal = await AppwriteService().countEms();
      var unitDetail = await AppwriteService()
          .getUnit(docExist.documents[0].data["docOwner"].toString());
      var currentYear = (DateTime.now().year + 543).toString();

      AppwriteService().createRequest({
        "docSeq":
            '${unitDetail?.data["unit_id"]}-E-${lastTotal?.total.toString().padLeft(4, '0')}/${currentYear.substring(currentYear.length - 2)}', // "E"
        "name": 'บริการการแพทย์ฉุกเฉิน',
        "docCode": docExist.documents[0].data["\$id"].toString(),
        "userId": accunt?.$id,
        "status": "new",
        "requestedAt": epochTime,
        "type": docName,
        "docId": emsData?.data["\$id"].toString(),
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
          heroTag: 'to_home_2',
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
