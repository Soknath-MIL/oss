import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_shimmer/flutter_shimmer.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../constants/constants.dart';
import '../../data/services/appwrite_service.dart';
import '../controllers/message_controller.dart';

const storage = FlutterSecureStorage();

class ProfilePage extends StatefulWidget {
  final Function onLogoutPressed;
  const ProfilePage({super.key, required this.onLogoutPressed});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final MessageConroller _messageConroller = Get.put(MessageConroller());
  File? image;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: _messageConroller.obx(
          (state) {
            var data = _messageConroller.accountData["data"];
            return Column(
              children: [
                Container(
                  height: 140,
                  padding: const EdgeInsets.only(left: 10, right: 10),
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    boxShadow: [
                      BoxShadow(
                        offset: Offset(0, 3),
                        color: Colors.black12,
                        blurRadius: 10,
                      )
                    ],
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                  ),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            builder: (context) {
                              return Column(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  ListTile(
                                    leading: const Icon(Icons.image,
                                        color: Colors.green),
                                    title: const Text('Gallery'),
                                    onTap: () {
                                      pickImageGallery();
                                      Navigator.pop(context);
                                    },
                                  ),
                                  ListTile(
                                    leading: const Icon(
                                      Icons.camera_alt,
                                      color: Colors.green,
                                    ),
                                    title: const Text('Photo'),
                                    onTap: () {
                                      pickImageCamera();
                                      Navigator.pop(context);
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        child: data["avatar"] != null
                            ? CircleAvatar(
                                radius: 50.0, // Set the desired radius
                                backgroundImage: NetworkImage(
                                  jsonDecode(data["avatar"])[0]["url"],
                                ),
                              )
                            : const CircleAvatar(
                                radius: 50.0, // Set the desired radius
                                backgroundImage:
                                    AssetImage("assets/images/avatar.png"),
                              ),
                      ),
                      Expanded(
                        child: Container(
                          margin: const EdgeInsets.only(left: 30),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(
                                height: 10,
                              ),
                              Text(
                                '${Constants.title[data["title"]] ?? "ไม่มีข้อมูล"} ${data["firstname"] ?? ""} ${data["lastname"] ?? ""}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Text(
                                  'ที่อยู่: ${data["address"] ?? "ไม่มีข้อมูล"}'),
                              const SizedBox(
                                height: 10,
                              ),
                              Text('โทรศัพท์: ${data["phone"]}'),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(top: 10, bottom: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            FloatingActionButton(
                              heroTag: 'profile',
                              mini: true,
                              elevation: 2,
                              backgroundColor: Colors.grey,
                              child: const Icon(
                                Icons.edit,
                                color: Colors.white,
                                size: 20,
                              ),
                              onPressed: () async {
                                // GOTO edit login page
                                debugPrint('click');
                                Get.toNamed("/edit-profile", arguments: [data]);
                              },
                            ),
                            FloatingActionButton(
                              heroTag: 'profile_1',
                              mini: true,
                              elevation: 2,
                              backgroundColor: Colors.grey,
                              child: const Icon(
                                Icons.logout,
                                color: Colors.white,
                                size: 20,
                              ),
                              onPressed: () async {
                                // Confirm Button

                                Get.defaultDialog(
                                  title: "ยืนยัน",
                                  content:
                                      const Text("คุณแน่ใจไหม, จะออกจากระบบ?"),
                                  backgroundColor: Colors.white,
                                  titleStyle:
                                      const TextStyle(color: Colors.black54),
                                  radius: 10,
                                  confirm: FloatingActionButton.extended(
                                    heroTag: 'to_home',
                                    onPressed: () async {
                                      await FirebaseAuth.instance.signOut();
                                      // delete session only
                                      await storage.delete(key: 'user');
                                      AppwriteService().logout();
                                      widget.onLogoutPressed(0);
                                      Get.back();
                                    },
                                    label: const Text('ออกจากระบบ'),
                                  ),
                                );
                              },
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Container(
                          margin: const EdgeInsets.only(top: 8, bottom: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                ' ติดตามผล',
                                textAlign: TextAlign.start,
                              ),
                              GestureDetector(
                                onTap: () {
                                  Get.toNamed("/request");
                                },
                                child: Container(
                                  padding: const EdgeInsets.only(
                                      left: 16, right: 10),
                                  color: Colors.white,
                                  child: ListTile(
                                    iconColor: Colors.green,
                                    leading: Image.asset(
                                      "assets/images/compaign.png",
                                      width: 30,
                                    ),
                                    title: const Text("ติดตามเรื่องร้องเรียน"),
                                    dense: true,
                                    trailing: const Icon(
                                        Icons.arrow_forward_ios_rounded),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.only(top: 8, bottom: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                ' ข้อมูลเกี่ยวกับเทศบาล',
                                textAlign: TextAlign.start,
                              ),
                              Container(
                                padding:
                                    const EdgeInsets.only(left: 16, right: 10),
                                color: Colors.white,
                                child: GestureDetector(
                                  onTap: () {
                                    Get.toNamed("/vision");
                                  },
                                  child: const ListTile(
                                    iconColor: Colors.green,
                                    leading: Icon(Icons.info),
                                    title: Text("ข้อมูลทั่วไปของ อบต."),
                                    dense: true,
                                    trailing:
                                        Icon(Icons.arrow_forward_ios_rounded),
                                  ),
                                ),
                              ),
                              Container(
                                padding:
                                    const EdgeInsets.only(left: 16, right: 10),
                                color: Colors.white,
                                child: GestureDetector(
                                  onTap: () {
                                    Get.toNamed("/staff");
                                  },
                                  child: ListTile(
                                    iconColor: Colors.green,
                                    leading: Image.asset(
                                      "assets/images/people.png",
                                      width: 30,
                                    ),
                                    title: const Text("คณะผู้บริหาร"),
                                    dense: true,
                                    trailing: const Icon(
                                        Icons.arrow_forward_ios_rounded),
                                  ),
                                ),
                              ),
                              Container(
                                padding:
                                    const EdgeInsets.only(left: 16, right: 10),
                                color: Colors.white,
                                child: GestureDetector(
                                  onTap: () {
                                    Get.toNamed("/news");
                                  },
                                  child: ListTile(
                                    iconColor: Colors.green,
                                    leading: Image.asset(
                                      "assets/images/activity.png",
                                      width: 30,
                                    ),
                                    title: const Text("กิจกรรมของเรา"),
                                    dense: true,
                                    trailing: const Icon(
                                        Icons.arrow_forward_ios_rounded),
                                  ),
                                ),
                              ),
                              Container(
                                padding:
                                    const EdgeInsets.only(left: 16, right: 10),
                                color: Colors.white,
                                child: GestureDetector(
                                  onTap: () {
                                    Get.toNamed("/open-access");
                                  },
                                  child: ListTile(
                                    iconColor: Colors.green,
                                    leading: Image.asset(
                                      "assets/images/document.png",
                                      width: 30,
                                    ),
                                    title: const Text("เอกสารดาวน์โหลด"),
                                    dense: true,
                                    trailing: const Icon(
                                        Icons.arrow_forward_ios_rounded),
                                  ),
                                ),
                              ),
                              Container(
                                padding:
                                    const EdgeInsets.only(left: 16, right: 10),
                                color: Colors.white,
                                child: GestureDetector(
                                  onTap: () {
                                    Get.toNamed("/journal");
                                  },
                                  child: ListTile(
                                    iconColor: Colors.green,
                                    leading: Image.asset(
                                      "assets/images/journal.png",
                                      width: 30,
                                    ),
                                    title: const Text("วารสาร"),
                                    dense: true,
                                    trailing: const Icon(
                                        Icons.arrow_forward_ios_rounded),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.only(top: 8, bottom: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                ' แนะนำสถานที่',
                                textAlign: TextAlign.start,
                              ),
                              Container(
                                padding:
                                    const EdgeInsets.only(left: 16, right: 10),
                                color: Colors.white,
                                child: GestureDetector(
                                  onTap: () {
                                    Get.toNamed("/pois", arguments: [0]);
                                  },
                                  child: ListTile(
                                    leading: Image.asset(
                                      "assets/images/food.png",
                                      width: 30,
                                    ),
                                    title: const Text("กิน"),
                                    dense: true,
                                    trailing: const Icon(
                                        Icons.arrow_forward_ios_rounded),
                                  ),
                                ),
                              ),
                              Container(
                                padding:
                                    const EdgeInsets.only(left: 16, right: 10),
                                color: Colors.white,
                                child: GestureDetector(
                                  onTap: () {
                                    Get.toNamed("/pois", arguments: [1]);
                                  },
                                  child: ListTile(
                                    iconColor: Colors.green,
                                    leading: Image.asset(
                                      "assets/images/tour.png",
                                      width: 30,
                                    ),
                                    dense: true,
                                    title: const Text("ท่องเที่ยว"),
                                    trailing: const Icon(
                                        Icons.arrow_forward_ios_rounded),
                                  ),
                                ),
                              ),
                              Container(
                                padding:
                                    const EdgeInsets.only(left: 16, right: 10),
                                color: Colors.white,
                                child: GestureDetector(
                                  onTap: () {
                                    Get.toNamed("/pois", arguments: [2]);
                                  },
                                  child: ListTile(
                                    iconColor: Colors.green,
                                    leading: Image.asset(
                                      "assets/images/hotel.png",
                                      width: 30,
                                    ),
                                    title: const Text("ที่พัก"),
                                    dense: true,
                                    trailing: const Icon(
                                        Icons.arrow_forward_ios_rounded),
                                  ),
                                ),
                              ),
                              Container(
                                padding:
                                    const EdgeInsets.only(left: 16, right: 10),
                                color: Colors.white,
                                child: GestureDetector(
                                  onTap: () {
                                    Get.toNamed("/pois", arguments: [3]);
                                  },
                                  child: ListTile(
                                    iconColor: Colors.green,
                                    leading: Image.asset(
                                      "assets/images/shopping.png",
                                      width: 30,
                                    ),
                                    title: const Text("ซื้อของ"),
                                    dense: true,
                                    trailing: const Icon(
                                        Icons.arrow_forward_ios_rounded),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.only(top: 8, bottom: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                ' ติดต่อเรา',
                                textAlign: TextAlign.start,
                              ),
                              GestureDetector(
                                onTap: () {
                                  Get.toNamed("/contact");
                                },
                                child: Container(
                                  padding: const EdgeInsets.only(
                                      left: 16, right: 10),
                                  color: Colors.white,
                                  child: const ListTile(
                                    iconColor: Colors.green,
                                    leading: Icon(Icons.home),
                                    title: Text("ที่อยู่ อบต."),
                                    dense: true,
                                    trailing:
                                        Icon(Icons.arrow_forward_ios_rounded),
                                  ),
                                ),
                              ),
                              Container(
                                padding:
                                    const EdgeInsets.only(left: 16, right: 10),
                                color: Colors.white,
                                child: const ListTile(
                                    iconColor: Colors.green,
                                    leading: Icon(Icons.verified),
                                    title: Text("version 1.0.6"),
                                    dense: true),
                              ),
                              // GestureDetector(
                              //   onTap: () {
                              //     // scan to login
                              //     Get.toNamed("/qr-scanner");
                              //   },
                              //   child: Container(
                              //     padding: const EdgeInsets.only(
                              //         left: 16, right: 10),
                              //     color: Colors.white,
                              //     child: const ListTile(
                              //       iconColor: Colors.green,
                              //       leading: Icon(Icons.qr_code),
                              //       title: Text(
                              //           "สแกนเพื่อเข้าสู่ระบบผ่านคอมพิวเตอร์"),
                              //       dense: true,
                              //       trailing:
                              //           Icon(Icons.arrow_forward_ios_rounded),
                              //     ),
                              //   ),
                              // )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
          onLoading: const Center(child: ProfilePageShimmer()),
        ),
      ),
    );
  }

  void checkLogin() async {
    await _messageConroller.getUserId();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkLogin();
  }

  Future pickImageCamera() async {
    try {
      final image = await ImagePicker().pickImage(source: ImageSource.camera);
      if (image == null) return;
      var filesArray = [];
      var result = await AppwriteService()
          .uploadPicture(image.path, image.name, Constants.profileBucketId);
      debugPrint(result.toString());
      filesArray.add(jsonEncode({
        ...result!.toMap(),
        "url":
            '${Constants.appwriteEndpoint}/storage/buckets/${result.bucketId}/files/${result.$id}/view?project=${Constants.appwriteProjectId}&mode=admin'
      }));

      // create user colletion
      await AppwriteService()
          .updateUser(_messageConroller.accountData["data"]["\$id"], {
        "avatar": filesArray.toString(),
      });

      // refresh controller
      _messageConroller.getUserId();
    } on PlatformException catch (e) {
      debugPrint('Failed to pick image: $e');
    }
  }

  Future pickImageGallery() async {
    try {
      final image = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (image == null) return;
      var filesArray = [];
      var result = await AppwriteService()
          .uploadPicture(image.path, image.name, Constants.profileBucketId);
      debugPrint(result.toString());
      filesArray.add(jsonEncode({
        ...result!.toMap(),
        "url":
            '${Constants.appwriteEndpoint}/storage/buckets/${result.bucketId}/files/${result.$id}/view?project=${Constants.appwriteProjectId}&mode=admin'
      }));

      // create user colletion
      await AppwriteService()
          .updateUser(_messageConroller.accountData["data"]["\$id"], {
        "avatar": filesArray.toString(),
      });

      // refresh controller
      _messageConroller.getUserId();
    } on PlatformException catch (e) {
      debugPrint('Failed to pick image: $e');
    }
  }
}
