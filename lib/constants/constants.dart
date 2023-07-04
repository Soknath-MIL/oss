import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

class Constants {
  static const Color primaryColor = Color(0xffFBFBFB);
  static const String otpGifImage = "assets/images/otp.gif";
  static const appwriteEndpoint = 'https://oss.moevedigital.com/v1';
  static const appwriteProjectId = '6415b01eb0d9b1892d1a';
  static const userId = '64180e476b35c9af5bde';
  static const citizenId = 'citizens';
  static const appealCategoryId = 'appealCategories';
  static const appwriteSelfSigned = true;
  static const chatMessageCollectionId = 'chatMessages';
  static const databseId = '6417c7d66de4c5eca58a';
  static const boardId = 'board';
  static const notificationId = 'notifications';
  static const requestId = "641972b19ec7387acac0";
  static const newsId = "6417c7dd86bb50348654";
  static const emergencyId = "emergencies";
  static const contactId = "contacts";
  static const journalId = "journal";
  static const openAccessId = "openAccessDocs";
  static const managementTeamId = "managementTeam";
  static const poiId = "pois";
  static const unitId = "64196b07a9858b443b4d";
  static const appealId = "appeals";
  static const docMasterId = "641967e71e3bbe717877";
  static const tambonHistoryId = "tambonHistory";
  static const profileBucketId = "profiles";
  static const appealBucketId = "appeals";
  static const taxTrashId = "taxs";
  static const slipBucketId = "slips";
  static const configId = "tambonConfigs";
  static const emsId = "emsRequests";
  static const generalRequestId = "generalRequests";
  static const trashRequestId = "trashRequests";
  static const emsBucketId = "ems";
  static const generalBucketId = "generalRequests";
  static const openBusinessBucketId = "openBusiness";
  static const openBusinessId = "openBusiness";
  static const trashBucketId = "trashRequests";
  static const docTypesId = "docTypes";
  static const adminMessageCountId = "adminMessageCount";

  static const requestStatus = {
    "new": "ใหม่",
    "progress": "กำลังดำเนินการ",
    "done": "เสร็จสิ้นเอกสาร",
    "complete": "เสร็จสิ้น",
    "confirm": "ยืนยัน",
    "reject": "ปฏิเสธ"
  };
  static const taxPaymentStatus = {
    "new": "ยังไม่จ่าย",
    "complete": "รอการยืนยัน",
    "confirm": "จ่ายแล้ว"
  };
  static const title = {"mr": "นาย", "mrs": "นางสาว", "miss": "นาง"};
  static const titleOptions = [
    {
      "name": "mr",
      "value": "นาย",
    },
    {
      "name": "mrs",
      "value": "นางสาว",
    },
    {
      "name": "miss",
      "value": "นาง",
    }
  ];

  static const String mapBoxAccessToken =
      'sk.eyJ1Ijoic29rbmF0aC1taWwiLCJhIjoiY2xjcWRldmYwMDRzYzNucDE5Mzlxcm01ayJ9.U3X6mOm0zpf1Zv6cq40tNA';

  static const String mapBoxStyleId = "mapbox.satellite";
  static final tambonLocation = LatLng(14.3697014, 100.8423626);
  static const patient = {
    "bedriddenPatient": "ผู้ป่วยติดเตียง",
    "unablePatient": "ผู้ป่วยที่ไม่สามารถช่วยเหลือตัวเองได้",
    "diasbled_1": "พิการทางสายตาทั้ง 2 ข้าง",
    "diasbled_2": "เคลื่อนไหวร่างกายไม่ได้",
    "diasbled_3": "เคลื่อนไหวร่างการได้น้อย",
    "no_vehicle": "ผู้ป่วยที่ไม่มียานพาหนะ",
  };
  static const houseType = [
    {
      "name": "บ้าน",
      "value": "บ้าน",
    },
    {
      "name": "ร้านอาหาร",
      "value": "ร้านอาหาร",
    },
    {
      "name": "อาคารพาณิชย์",
      "value": "อาคารพาณิชย์",
    },
    {
      "name": "ร้านขายของชำ",
      "value": "ร้านขายของชำ",
    },
    {
      "name": "โรงแรม",
      "value": "โรงแรม",
    },
    {
      "name": "ร้านค้า",
      "value": "ร้านค้า",
    },
    {
      "name": "ห้องเช่า/อพาร์ทเม้นท์",
      "value": "ห้องเช่า/อพาร์ทเม้นท์",
    },
    {
      "name": "อื่นๆ",
      "value": "อื่นๆ",
    },
  ];
  static const patientOptions = [
    {
      "name": "bedriddenPatient",
      "value": "ผู้ป่วยติดเตียง",
    },
    {
      "name": "unablePatient",
      "value": "ผู้ป่วยที่ไม่สามารถช่วยเหลือตัวเองได้",
    },
    {
      "name": "diasbled_1",
      "value": "พิการทางสายตาทั้ง 2 ข้าง",
    },
    {
      "name": "diasbled_2",
      "value": "เคลื่อนไหวร่างกายไม่ได้",
    },
    {
      "name": "diasbled_3",
      "value": "เคลื่อนไหวร่างการได้น้อย",
    },
    {
      "name": "no_vehicle",
      "value": "ผู้ป่วยที่ไม่มียานพาหนะ",
    }
  ];
}
