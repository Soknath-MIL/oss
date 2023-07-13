import 'dart:convert';

import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as model;
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:nanoid/nanoid.dart';
import 'package:uuid/uuid.dart';

import '../../constants/constants.dart';

const secureStorage = FlutterSecureStorage();
Dio dio = Dio();

class Appwrite {
  static final Appwrite instance = Appwrite._internal();

  late final Client client;

  factory Appwrite._() {
    return instance;
  }

  Appwrite._internal() {
    client = Client()
        .setEndpoint(Constants.appwriteEndpoint)
        .setProject(Constants.appwriteProjectId)
        .setSelfSigned(status: Constants.appwriteSelfSigned);
  }
}

class AppwriteService {
  final Databases databases = Databases(Appwrite.instance.client);
  final Account account = Account(Appwrite.instance.client);
  final Storage storage = Storage(Appwrite.instance.client);

  Future<void> addMessage(Map<String, dynamic> messageData) async {
    debugPrint('message $messageData');
    try {
      await databases.createDocument(
        collectionId: Constants.chatMessageCollectionId,
        databaseId: Constants.databseId,
        documentId: const Uuid().v4(),
        data: {
          ...messageData,
          "author": jsonEncode(messageData["author"]),
          "type": "text",
          "status": "sent"
        },
      );
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  // Future<bool> alreadyRegister(String phoneNumber) async {
  //   try {
  //     // still login;
  //     await account.get();
  //     makeOnline(true);
  //     return true;
  //   } catch (e) {
  //     // try to login
  //     try {
  //       // re-login
  //       model.Session session = await account.createEmailSession(
  //           email: '$phoneNumber@appwrite.io', password: 'password');
  //       await secureStorage.write(
  //           key: 'user', value: jsonEncode(session.toMap()));
  //       // make user online
  //       makeOnline(true);
  //       return true;
  //     } catch (e) {
  //       // no have account yet
  //       return false;
  //     }
  //   }
  // }

  Future<model.DocumentList?> checkDocMaster(id) async {
    debugPrint("doc id ${id.toString()}");
    var appealData = await databases.listDocuments(
      databaseId: Constants.databseId,
      collectionId: Constants.docMasterId,
      queries: [
        Query.equal('appeal_id', id),
      ],
    );
    if (appealData.total != 0) {
      return appealData;
    }
    return null;
  }

  Future<model.DocumentList?> checkDocMasterName(name) async {
    var appealData = await databases.listDocuments(
      databaseId: Constants.databseId,
      collectionId: Constants.docMasterId,
      queries: [
        Query.equal('docName', name),
      ],
    );
    if (appealData.total != 0) {
      return appealData;
    }
    return null;
  }

  Future<model.DocumentList?> countAppeal() async {
    var appealData = await databases.listDocuments(
      databaseId: Constants.databseId,
      collectionId: Constants.appealId,
    );
    return appealData;
  }

  Future<model.DocumentList?> countEms() async {
    var emsData = await databases.listDocuments(
      databaseId: Constants.databseId,
      collectionId: Constants.emsId,
    );
    return emsData;
  }

  Future<model.DocumentList?> countGeneral() async {
    var generalData = await databases.listDocuments(
      databaseId: Constants.databseId,
      collectionId: Constants.generalRequestId,
    );
    return generalData;
  }

  Future<model.DocumentList?> countOpenBusiness() async {
    var openBusinessData = await databases.listDocuments(
      databaseId: Constants.databseId,
      collectionId: Constants.openBusinessId,
    );
    return openBusinessData;
  }

  Future<model.DocumentList?> countTrash() async {
    var trashData = await databases.listDocuments(
      databaseId: Constants.databseId,
      collectionId: Constants.trashRequestId,
    );
    return trashData;
  }

  Future<model.Document?> createAppeal(values) async {
    var appealData = await databases.createDocument(
      databaseId: Constants.databseId,
      collectionId: Constants.appealId,
      documentId: ID.unique(),
      data: values,
    );
    return appealData;
  }

  Future<model.Document?> createEMSRequest(data) async {
    try {
      var emsData = await databases.createDocument(
        collectionId: Constants.emsId,
        databaseId: Constants.databseId,
        documentId: ID.unique(),
        data: data,
      );
      return emsData;
    } catch (e) {
      debugPrint('ems create error: ${e.toString()}');
      return null;
    }
  }

  Future<model.Document?> createGeneralRequest(data) async {
    try {
      var emsData = await databases.createDocument(
        collectionId: Constants.generalRequestId,
        databaseId: Constants.databseId,
        documentId: ID.unique(),
        data: data,
      );
      return emsData;
    } catch (e) {
      debugPrint('ems create error: ${e.toString()}');
      return null;
    }
  }

  Future<void> createMessageCount(unit$Id, data) async {
    try {
      await databases.createDocument(
        collectionId: Constants.adminMessageCountId,
        databaseId: Constants.databseId,
        documentId: unit$Id,
        data: data,
      );
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<model.Document?> createOpenBussinessRequest(data) async {
    try {
      var emsData = await databases.createDocument(
        collectionId: Constants.openBusinessId,
        databaseId: Constants.databseId,
        documentId: ID.unique(),
        data: data,
      );
      return emsData;
    } catch (e) {
      debugPrint('ems create error: ${e.toString()}');
      return null;
    }
  }

  Future<model.Document?> createRequest(values) async {
    var requestData = await databases.createDocument(
      databaseId: Constants.databseId,
      collectionId: Constants.requestId,
      documentId: ID.unique(),
      data: values,
    );

    // create notification here too

    // create user request notification
    createUserRequestNotification(
      {
        "name": '${values.name} ใหม่',
        "source": requestData.$id,
        "unitId": values.unitId
      },
    );
    return requestData;
  }

  Future<model.Document?> createTrashRequest(data) async {
    try {
      var emsData = await databases.createDocument(
        collectionId: Constants.trashRequestId,
        databaseId: Constants.databseId,
        documentId: ID.unique(),
        data: data,
      );
      return emsData;
    } catch (e) {
      debugPrint('ems create error: ${e.toString()}');
      return null;
    }
  }

  Future<void> createUser(int nationalId, String title, String firstname,
      String lastname, String address) async {
    // phone number get from firebase
    final user = FirebaseAuth.instance.currentUser;
    if (user?.phoneNumber != null) {
      var phoneNumber = user?.phoneNumber!;
      try {
        await account.create(
          userId: ID.unique(),
          email: '$phoneNumber@appwrite.io',
          password: phoneNumber!,
          name: '$title $firstname $lastname',
        );
      } catch (e) {
        debugPrint(
            "account creation error ${e.toString()} $phoneNumber $title $firstname $lastname $address");
      }

      // try login with phone number
      Future result = account.createEmailSession(
        email: '$phoneNumber@appwrite.io',
        password: phoneNumber!,
      );

      // check whitelist
      result.then((response) async {
        debugPrint('userID ${response.$id.toString()}');
        // store user data in storage
        secureStorage.write(key: 'userID', value: response.userId.toString());
        secureStorage.write(key: 'email', value: '$phoneNumber@appwrite.io');
        secureStorage.write(key: 'password', value: phoneNumber);

        print('login success 2 $response');
        var existLocal = await databases.listDocuments(
          databaseId: Constants.databseId,
          collectionId: Constants.citizenId,
          queries: [
            Query.equal('nationalId', nationalId),
          ],
        );

        debugPrint('white list ${existLocal.total.toString()}');
        // create user and register
        try {
          await databases.createDocument(
            databaseId: Constants.databseId,
            collectionId: Constants.userId,
            documentId: response.userId,
            data: {
              "phone": user?.phoneNumber!,
              "type": existLocal.total != 0
                  ? "local"
                  : "alien", // do check whitelist
              "role": "mobile",
              "online": true,
              "email": '${user?.phoneNumber!}@appwrite.io', //
              "name": '$title $firstname $lastname',
              "userId": response.userId,
              "title": title,
              "firstname": firstname,
              "lastname": lastname,
              "address": address
            },
          );
          Get.snackbar(
            "สำเร็จ",
            "สร้างบัญชีเรียบร้อยแล้ว",
            duration: const Duration(seconds: 1),
            colorText: Colors.white,
            icon: const Icon(Icons.check_circle),
            snackPosition: SnackPosition.BOTTOM,
          );
          return;
        } catch (e) {
          debugPrint(e.toString());
          Get.snackbar(
            "ข้อมูล",
            "ข้อมูลผู้ใช้มีอยู่แล้ว",
            colorText: Colors.white,
            icon: const Icon(Icons.cancel),
            duration: const Duration(seconds: 1),
            snackPosition: SnackPosition.BOTTOM,
          );
        }
      }).catchError((error) {
        print(error.response);
        return;
      });
    } else {
      Get.snackbar(
        "ข้อผิดพลาด",
        "ไม่พบหมายเลขโทรศัพท์มือถือ",
        duration: const Duration(seconds: 1),
        colorText: Colors.red,
        icon: const Icon(Icons.cancel),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<model.Document?> createUserRequestNotification(values) async {
    var requestData = await databases.createDocument(
      databaseId: Constants.databseId,
      collectionId: Constants.userRequestNotificationId,
      documentId: ID.unique(),
      data: values,
    );
    return requestData;
  }

  Future<model.Account?> getAccount() async {
    return await account.get();
  }

  Future<model.Document?> getAppeal(id) async {
    var appealData = await databases.getDocument(
      databaseId: Constants.databseId,
      collectionId: Constants.appealId,
      documentId: id,
    );
    return appealData;
  }

  Future<model.Document?> getEms(id) async {
    var emsData = await databases.getDocument(
      databaseId: Constants.databseId,
      collectionId: Constants.emsId,
      documentId: id,
    );
    return emsData;
  }

  Future<model.DocumentList?> getMessage(String userId, String admin) async {
    try {
      var data = await databases.listDocuments(
        collectionId: Constants.chatMessageCollectionId,
        databaseId: Constants.databseId,
        queries: [
          Query.orderDesc("\$createdAt"),
          Query.equal('senderId', [userId, admin]),
          Query.equal('receiverId', [userId, admin]),
        ],
      );
      return data;
    } catch (e) {
      debugPrint(e.toString());
      return null;
    }
  }

  Future<model.Document?> getMessageCount(id) async {
    var messageCountData = await databases.getDocument(
      databaseId: Constants.databseId,
      collectionId: Constants.adminMessageCountId,
      documentId: id,
    );
    return messageCountData;
  }

  Future<model.Document?> getNews(String news$Id) async {
    try {
      var newsData = await databases.getDocument(
        collectionId: Constants.newsId,
        databaseId: Constants.databseId,
        documentId: news$Id,
      );
      return newsData;
    } catch (e) {
      return null;
    }
  }

  Future<model.Document?> getOpenBusiness(id) async {
    var trashData = await databases.getDocument(
      databaseId: Constants.databseId,
      collectionId: Constants.openBusinessId,
      documentId: id,
    );
    return trashData;
  }

  Future<model.Document?> getRequest(id) async {
    var requestData = await databases.getDocument(
      databaseId: Constants.databseId,
      collectionId: Constants.requestId,
      documentId: id,
    );
    return requestData;
  }

  Future<model.Document?> getTrash(id) async {
    var trashData = await databases.getDocument(
      databaseId: Constants.databseId,
      collectionId: Constants.trashRequestId,
      documentId: id,
    );
    return trashData;
  }

  Future<model.DocumentList?> getTrashTax(nationalId) async {
    var trashTaxData = await databases.listDocuments(
      databaseId: Constants.databseId,
      collectionId: Constants.taxTrashId,
      queries: [
        Query.equal('nationalId', nationalId),
      ],
    );

    if (trashTaxData.total != 0) {
      return trashTaxData;
    }
    return null;
  }

  Future<model.Document?> getUnit(unitId) async {
    var unitData = await databases.getDocument(
        databaseId: Constants.databseId,
        collectionId: Constants.unitId,
        documentId: unitId);
    return unitData;
  }

  Future<void> logout() async {
    try {
      model.Session session = await account.getSession(sessionId: 'current');
      await account.deleteSession(sessionId: session.$id);
      Get.snackbar(
        "ออกจากระบบ",
        "เรียบร้อยแล้ว",
        colorText: Colors.white,
        icon: const Icon(Icons.check_circle),
        duration: const Duration(seconds: 1),
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      debugPrint('logout error ${e.toString()}');
      Get.snackbar(
        "ออกจากระบบ",
        "เรียบร้อยแล้ว",
        colorText: Colors.white,
        icon: const Icon(Icons.check),
        duration: const Duration(seconds: 1),
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
  }

  makeOnline(bool status) async {
    var userData = await secureStorage.read(key: 'userData');
    if (userData != null) {
      Map<String, dynamic> userObject = jsonDecode(userData);
      await AppwriteService().setOnline(userObject['\$id'], status);
    }
  }

  // qr-login
  Future<bool> qrLogin(data) async {
    var headers = {
      'X-Appwrite-Project': '6415b01eb0d9b1892d1a',
      'Content-Type': 'application/json',
    };
    var request = await dio.post(
        'https://oss.moevedigital.com/v1/functions/qr-login/executions',
        data: {"data": data},
        options: Options(headers: headers));

    debugPrint('request ${request.statusCode.toString()}');
    if (request.statusCode == 201) {
      print(request.data);
      return true;
    } else {
      print(request.data);
      return false;
    }
  }

  Future<Object?> searchTrashTax(nationalId, address, year) async {
    model.DocumentList trashTaxData1;
    model.DocumentList trashTaxData2;

    debugPrint('nationalId: $nationalId');

    if (nationalId != null && nationalId != "") {
      trashTaxData1 = await databases.listDocuments(
        databaseId: Constants.databseId,
        collectionId: Constants.taxTrashId,
        queries: [Query.equal('nationalId', int.parse(nationalId))],
      );

      if (trashTaxData1.total != 0) {
        Get.snackbar(
          "ข้อผิดพลาด",
          "มี บัตรประจำตัวประชาชนซ้ำ",
          colorText: Colors.white,
          icon: const Icon(
            Icons.check_circle_rounded,
            color: Colors.green,
          ),
          duration: const Duration(seconds: 1),
          snackPosition: SnackPosition.BOTTOM,
        );
        return null;
      }
      if (trashTaxData1.total != 0) {
        // filter only selected year
        var selectYearTrash1 = trashTaxData1.documents
            .where((i) => i.data["year"] == year)
            .toList();
        debugPrint('data ${selectYearTrash1.toString()}');
        return selectYearTrash1.isNotEmpty ? selectYearTrash1[0].data : null;
      }
    }
    if (address != null && address != "") {
      trashTaxData2 = await databases.listDocuments(
        databaseId: Constants.databseId,
        collectionId: Constants.taxTrashId,
        queries: [Query.equal('address', address)],
      );
      if (trashTaxData2.total != 0) {
        Get.snackbar(
          "ข้อผิดพลาด",
          "มีที่อยู่ซ้ำ",
          colorText: Colors.white,
          icon: const Icon(
            Icons.check_circle_rounded,
            color: Colors.green,
          ),
          duration: const Duration(seconds: 1),
          snackPosition: SnackPosition.BOTTOM,
        );
        return null;
      }
      if (trashTaxData2.total != 0) {
        var selectYearTrash2 = trashTaxData2.documents
            .where((i) => i.data["year"] == year)
            .toList();
        debugPrint('data ${selectYearTrash2.toString()}');
        return selectYearTrash2.isNotEmpty ? selectYearTrash2[0].data : null;
      }
    }
    return null;
  }

  Future<void> setOnline(String userId, bool status) async {
    try {
      await databases.updateDocument(
        collectionId: Constants.userId,
        databaseId: Constants.databseId,
        documentId: userId,
        data: {"online": status},
      );
    } catch (e) {
      return;
    }
  }

  Future<Object?> tryLogin() async {
    // phone number get from firebase
    final user = FirebaseAuth.instance.currentUser;
    print('user $user');
    if (user?.phoneNumber != null) {
      var phoneNumber = user?.phoneNumber!;
      try {
        // try login
        Future result = account.createEmailSession(
          email: '${phoneNumber!}@appwrite.io',
          password: phoneNumber,
        );

        return result.then((response) async {
          // check use in the list
          try {
            await databases.getDocument(
              databaseId: Constants.databseId,
              collectionId: Constants.userId,
              documentId: response.userId,
            );
          } catch (e) {
            return null;
            // debugPrint('erro not user fount ${e.toString()}');
          }
          debugPrint('userID ${response.userId.toString()}');
          // store user data in storage
          secureStorage.write(key: 'userID', value: response.userId.toString());
          secureStorage.write(key: 'email', value: '$phoneNumber@appwrite.io');
          secureStorage.write(key: 'password', value: phoneNumber);

          Get.snackbar(
            "สำเร็จ",
            "คุณมีบัญชีอยู่แล้ว",
            colorText: Colors.white,
            icon: const Icon(
              Icons.check_circle_rounded,
              color: Colors.green,
            ),
            duration: const Duration(seconds: 1),
            snackPosition: SnackPosition.BOTTOM,
          );
          print('login sucess 1 $response');
          return response;
        }).catchError((error) async {
          print(error.response);
          return null;
        });
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  Future<void> updateMessageCount(unit$Id, data) async {
    try {
      await databases.updateDocument(
        collectionId: Constants.adminMessageCountId,
        databaseId: Constants.databseId,
        documentId: unit$Id,
        data: data,
      );
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> updateTrashTax(taxId, data) async {
    try {
      await databases.updateDocument(
        collectionId: Constants.taxTrashId,
        databaseId: Constants.databseId,
        documentId: taxId,
        data: data,
      );
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> updateUser(user$Id, data) async {
    try {
      await databases.updateDocument(
        collectionId: Constants.userId,
        databaseId: Constants.databseId,
        documentId: user$Id,
        data: data,
      );
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<model.File?> uploadPicture(
      String filePath, String imgName, String bucketId) async {
    try {
      model.File? result = await storage.createFile(
        bucketId: bucketId,
        file: InputFile.fromPath(
            path: filePath,
            filename:
                "${imgName.split(".")[0]}_${nanoid()}.${imgName.split(".")[1]}", // make image name unique
            contentType: 'file'),
        fileId: 'unique()',
        // Make sure to give [role:all]
        // So that every authenticated user can access it
        // If you don't give any read permissions, by default the sole user
        // can access it.
        // We are keeping write function blank. It by defaults gives write permissions
        // to the user only and that's what we only want.
      );
      return result;
    } catch (e) {
      debugPrint('upload picture $e');
      rethrow;
    }
  }
}
