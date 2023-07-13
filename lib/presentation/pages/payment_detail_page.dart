import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_shimmer/flutter_shimmer.dart';
import 'package:get/get.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:image_picker/image_picker.dart';
import 'package:oss/presentation/pages/tax_payment_page.dart';
import 'package:path_provider/path_provider.dart';

import '../../constants/constants.dart';
import '../../data/services/appwrite_service.dart';
import '../../utils/general_utils.dart';
import '../controllers/config_controller.dart';

class PaymentDetailPage extends StatefulWidget {
  const PaymentDetailPage({super.key});

  @override
  State<PaymentDetailPage> createState() => _PaymentDetailPageState();
}

class _PaymentDetailPageState extends State<PaymentDetailPage> {
  final ConfigController configController = Get.put(ConfigController());
  XFile? image;
  var data = Get.arguments[0];
  List<bool> isChecked = Get.arguments[1];
  var totalPrice = Get.arguments[2];

  @override
  Widget build(BuildContext context) {
    var selectedMonths = [];
    for (var i = 0; i < isChecked.length; i++) {
      if (isChecked[i]) {
        selectedMonths.add(months[i]);
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('ชำระค่าบริการ'),
      ),
      body: SingleChildScrollView(
        child: configController.obx(
          (state) {
            var dataMap = {};
            for (var each in configController.configList) {
              if (each.data["value"] == null || each.data["value"] == "") {
                dataMap[each.data["name"]] = each.data["image"];
              } else {
                dataMap[each.data["name"]] = each.data["value"];
              }
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(top: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: const [
                      Text(
                        'ชำระค่าธรรมเนียมจัดเก็บขยะ',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  margin: const EdgeInsets.only(left: 10),
                  child: const Text(
                    'กรุณาตรวจสอบความถูกต้องของรายการ',
                    textAlign: TextAlign.start,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Colors.green,
                      fontSize: 14,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(10),
                  margin: const EdgeInsets.only(left: 10, right: 10),
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(
                      Radius.circular(
                        10,
                      ),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          '${data["title"]} ${data["firstname"]} ${data["lastname"]} ประเภท ${data["type"]}'),
                      Text(
                        '${data["address"]}',
                      ),
                      Row(
                        children: [
                          const Text(
                            'เดือน:',
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Text(
                            selectedMonths.join(", "),
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Text(
                            'ประจำปี ${data["year"]} เป็นจำนววนเงินทั้งสิ้น ',
                          ),
                          Text(
                            '$totalPrice บาท',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(left: 10, top: 10),
                  child: const Text(
                    'โอนเงินเข้าบัญชีธนาคาร',
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: Colors.green),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 16),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        CachedNetworkImage(
                            imageUrl: jsonDecode(dataMap["promtpay"])[0]["url"],
                            width: MediaQuery.of(context).size.width * 0.5),
                        FloatingActionButton(
                          elevation: 3,
                          mini: true,
                          onPressed: () {
                            downloadImage(
                                jsonDecode(dataMap["promtpay"])[0]["url"]);
                          },
                          child: const Icon(Icons.download),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.all(10),
                  child: const Text(
                    'อัพโหลดรูปสลิปโอนเงิน (เป็นไฟล์ .jpg .png)',
                    style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 18,
                        color: Colors.green),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(left: 20, top: 10),
                  child: Row(children: [
                    TextButton(
                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all<Color>(Colors.blue),
                      ),
                      onPressed: () {
                        // upload image from gallery
                        pickImageGallery();
                      },
                      child: const Text(
                        'เลือกไฟล์',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                    image != null
                        ? Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        HeroPhotoViewRouteWrapper(
                                      imageProvider: Image.file(
                                        //to show image, you type like this.
                                        File(image!.path),
                                        fit: BoxFit.fitWidth,
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.6,
                                        height: 150,
                                      ).image,
                                    ),
                                  ),
                                );
                              },
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(
                                  //to show image, you type like this.
                                  File(image!.path),
                                  fit: BoxFit.cover,
                                  width:
                                      MediaQuery.of(context).size.width * 0.6,
                                  height: 150,
                                ),
                              ),
                            ),
                          )
                        : const Text('ยังไม่ได้เลือกไฟล์อับโหลด')
                  ]),
                ),
                const SizedBox(
                  height: 20,
                ),
                Center(
                  child: SizedBox(
                    height: 40.0,
                    width: 120.0,
                    child: FittedBox(
                      child: FloatingActionButton.extended(
                        heroTag: 'upload',
                        elevation: 0,
                        onPressed: () {
                          // upload image
                          uploadImage();
                        },
                        label: const Text('อัพโหลด',
                            style: TextStyle(fontSize: 18)),
                      ),
                    ),
                  ),
                )
              ],
            );
          },
          onLoading: const Center(child: PlayStoreShimmer()),
        ),
      ),
    );
  }

  Future<void> downloadImage(String imageUrl) async {
    try {
      var response = await Dio()
          .get(imageUrl, options: Options(responseType: ResponseType.bytes));
      await ImageGallerySaver.saveImage(
        Uint8List.fromList(response.data),
      );
      // The image is downloaded and saved to the device's local storage
      Get.snackbar(
        "การมีส่วนร่วม",
        "ดาวน์โหลด QR SuccessVully",
        colorText: Colors.white,
        backgroundColor: Colors.green,
        icon: const Icon(Icons.check_circle),
        duration: const Duration(seconds: 1),
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      // Handle any errors that occurred during the download process
      print('Error while downloading image: $e');
    }
  }

  Future pickImageGallery() async {
    final file = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (file == null) return;
    setState(() {
      image = file;
    });
  }

  void uploadImage() async {
    // TODO check if no file upload then error
    if (image == null) {
      Get.snackbar(
        "ข้อผิดพลาด",
        "ไม่พบสลิปที่แนบมา",
        colorText: Colors.white,
        icon: const Icon(Icons.cancel),
        snackPosition: SnackPosition.TOP,
      );
      return;
    }
    // upload to the image to all slected month
    // get all selected box
    try {
      await EasyLoading.show(
        status: 'ตรวจสอบผู้ใช้...',
        maskType: EasyLoadingMaskType.black,
      );
      var filesArray = [];
      var result = await AppwriteService()
          .uploadPicture(image!.path, image!.name, Constants.slipBucketId);

      var fileMap = result?.toMap();
      // remove permission from image
      fileMap?.removeWhere((key, value) =>
          ["\$permissions", "\$createdAt", "\$updatedAt"].contains(key));

      filesArray.add({
        ...fileMap!,
        "url":
            '${Constants.appwriteEndpoint}/storage/buckets/${result?.bucketId}/files/${result?.$id}/view?project=${Constants.appwriteProjectId}&mode=admin'
      });

      List<String> newDetails = [...data["detail"]];
      for (var i = 0; i < isChecked.length; i++) {
        if (isChecked[i]) {
          Map<String, dynamic> currentDetail = jsonDecode(newDetails[i]);
          newDetails[i] = jsonEncode(
            {...currentDetail, "status": "complete", "slip": filesArray},
          );
        }
      }

      // check if all payment made
      var newStatus = data["status"];
      if (isChecked.contains(true)) {
        newStatus = "progress";
      }
      var allTrue = isChecked.every((element) => element == true);
      if (allTrue) {
        newStatus = "complete";
      }

      // update tax colletion
      await AppwriteService().updateTrashTax(data["\$id"], {
        "detail": newDetails,
        "status": newStatus,
      });
      EasyLoading.dismiss();
      Get.defaultDialog(
        title: "ข้อความ",
        content: const Text("อัพโหลดสลิปสำเร็จ"),
        backgroundColor: Colors.white,
        titleStyle: const TextStyle(color: Colors.black54),
        radius: 10,
        confirm: FloatingActionButton.extended(
            heroTag: 'to_home_3',
            onPressed: () {
              Get.toNamed("/main");
            },
            label: const Text('ไปที่หน้าแรก')),
      );
    } on PlatformException catch (e) {
      debugPrint('Failed to pick image: $e');
    }
  }

  Future<File> _localFile(String fileName) async {
    final directory = await getDownloadsDirectory();
    return File('${directory?.path}/$fileName');
  }
}
