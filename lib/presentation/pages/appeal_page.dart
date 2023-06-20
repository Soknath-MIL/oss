import 'dart:convert';
import 'dart:io';

import 'package:appwrite/appwrite.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:map_location_picker/map_location_picker.dart';
import 'package:oss/constants/constants.dart';

import '../../data/services/appwrite_service.dart';
import '../controllers/message_controller.dart';

class AppealPage extends StatefulWidget {
  const AppealPage({super.key});

  @override
  State<AppealPage> createState() => _AppealPageState();
}

class _AppealPageState extends State<AppealPage>
    with AutomaticKeepAliveClientMixin {
  final MessageConroller _messageConroller = Get.put(MessageConroller());
  String address = "null";
  Location? location;
  String autocompletePlace = "null";
  Prediction? initialValue;
  final ImagePicker imgpicker = ImagePicker();
  List<XFile>? imagefiles;
  final formKey = GlobalKey<FormBuilderState>();
  var formData = <String, dynamic>{};
  List<Map<String, dynamic>> dropdownValues = [];
  var docMasterId = Get.arguments[0];
  var appealId = Get.arguments[1];
  var appealName = Get.arguments[2];
  var unitId = Get.arguments[3];

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    debugPrint('docMaster ${docMasterId.toString()}');
    super.build(context);
    openImages() async {
      try {
        var pickedfiles = await imgpicker.pickMultiImage();
        //you can use ImageCourse.camera for Camera capture
        // ignore: unnecessary_null_comparison
        if (pickedfiles != null) {
          setState(() {
            imagefiles = pickedfiles;
          });
        } else {
          print("No image is selected.");
        }
      } catch (e) {
        print("error while picking file.");
      }
    }

    void submit() async {
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

      if (imagefiles == null) {
        Get.snackbar(
          "ข้อผิดพลาด",
          "ไม่มีภาพ",
          colorText: Colors.white,
          icon: const Icon(Icons.cancel),
          snackPosition: SnackPosition.TOP,
        );
        return null;
      }

      if (formKey.currentState!.validate()) {
        await EasyLoading.show(
          status: 'กำลังโหลด...',
          maskType: EasyLoadingMaskType.black,
        );
        formKey.currentState?.save();
        var filesArray = [];
        for (var imageone in imagefiles!) {
          var result = await AppwriteService().uploadPicture(
              imageone.path, imageone.name, Constants.appealBucketId);
          filesArray.add(jsonEncode({
            ...result!.toMap(),
            "url":
                '${Constants.appwriteEndpoint}/storage/buckets/${result.bucketId}/files/${result.$id}/view?project=${Constants.appwriteProjectId}&mode=admin'
          }));
        }

        // create appeal record
        var appealData = await AppwriteService().createAppeal({
          "address": address,
          ...formKey.currentState!.value,
          "appealCategory": appealId,
          "coordinates":
              jsonEncode([location?.lng.toString(), location?.lat.toString()]),
          "images": filesArray,
          "status": "new"
        });

        // create request
        var accunt = await AppwriteService().getAccount();
        DateTime now = DateTime.now();
        var epochTime = (now.millisecondsSinceEpoch / 1000).round();
        debugPrint(epochTime.toString());
        AppwriteService().createRequest({
          "docSeq": 'การร้องเรียน [${formKey.currentState!.value["name"]}]',
          "docCode": docMasterId.toString(),
          "userId": accunt?.$id,
          "status": "new",
          "requestedAt": epochTime,
          "type": "appeal",
          "docId": appealData?.$id,
          "unitId": unitId
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
              heroTag: 'to_home',
              onPressed: () {
                Get.toNamed("/main");
              },
              label: const Text('ไปที่หน้าแรก')),
        );
        // Get.back();
      }
    }

    Future<List<Map<String, dynamic>>> fetchDropdownValues() async {
      final database = Databases(Appwrite.instance.client);
      var data = await database.listDocuments(
        databaseId: Constants.databseId,
        collectionId: Constants.appealCategoryId,
      );
      final List<Map<String, dynamic>> values = data.documents
          .map<Map<String, dynamic>>(
              (value) => {...value.data, "id": value.$id})
          .toList();
      return values;
    }

    return Scaffold(
      appBar: AppBar(
          title: Text('การร้องเรียน - $appealName'),
          backgroundColor: Colors.green),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              FormBuilder(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FormBuilderTextField(
                      name: 'name',
                      decoration: customInputDecoration('หัวข้อ'),
                      validator: FormBuilderValidators.required(),
                    ),
                    // FutureBuilder<List<Map<String, dynamic>>>(
                    //   future: fetchDropdownValues(),
                    //   builder: (context, snapshot) {
                    //     if (snapshot.hasData) {
                    //       dropdownValues = snapshot.data!;
                    //       return FormBuilderDropdown(
                    //         name: 'appealCategory',
                    //         decoration: customInputDecoration('หมวดหมู่'),
                    //         items: dropdownValues
                    //             .map((value) => DropdownMenuItem(
                    //                   value: value["id"],
                    //                   child: Text(value["name_t"]),
                    //                 ))
                    //             .toList(),
                    //         validator: FormBuilderValidators.required(),
                    //       );
                    //     } else if (snapshot.hasError) {
                    //       return Text('${snapshot.error}');
                    //     }
                    //     return const Center(child: CircularProgressIndicator());
                    //   },
                    // ),

                    const SizedBox(height: 10.0),
                    FormBuilderTextField(
                      maxLines: 4,
                      name: 'detail',
                      decoration: customInputDecoration('รายละเอียด'),
                      validator: FormBuilderValidators.required(),
                    ),
                    const SizedBox(height: 10.0),
                    FormBuilderTextField(
                      name: 'address',
                      decoration: customInputDecoration('ที่อยู่'),
                      validator: FormBuilderValidators.required(),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 16,
              ),
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
                              apiKey: "AIzaSyBB2X6grO8t8zyW6cktVqBs7duJP0mqN3A",
                              canPopOnNextButtonTaped: false,
                              currentLatLng: const LatLng(14, 100),
                              mapType: MapType.satellite,
                              onNext: (GeocodingResult? result) {
                                debugPrint('result $result');
                                debugPrint(
                                    'result ${result?.formattedAddress}');
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
              const Divider(),
              // ignore: unnecessary_null_comparison
              location != null
                  ? Text('ละติจูดและลองจิจูด:  ${location.toString()}')
                  : Container(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('เลือกรูปภาพ'),
                  ElevatedButton(
                    onPressed: () {
                      openImages();
                    },
                    child: const Icon(Icons.image),
                  ),
                ],
              ),
              imagefiles != null
                  ? Wrap(
                      children: imagefiles!.map((imageone) {
                        return Card(
                          child: SizedBox(
                            height: 100,
                            width: 100,
                            child: Image.file(File(imageone.path)),
                          ),
                        );
                      }).toList(),
                    )
                  : Container(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: GestureDetector(
          onTap: () {
            submit();
          },
          child: Container(
            height: 60.0,
            color: Colors.green,
            child: const Center(
                child: Text(
              "ส่งการร้องเรียน",
              style: TextStyle(color: Colors.white),
            )),
          ),
        ),
      ),
    );
  }

  void checkLogin() async {
    await _messageConroller.getUserId();
  }

  customInputDecoration(label) {
    return InputDecoration(
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
