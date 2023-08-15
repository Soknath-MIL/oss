import 'dart:convert';

import 'package:appwrite/models.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_shimmer/flutter_shimmer.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:oss/data/services/appwrite_service.dart';

import '../../constants/constants.dart';
import '../widgets/full_map_google.dart';
import '../widgets/process_timeline.dart';

class RequestDetailPage extends StatefulWidget {
  const RequestDetailPage({super.key});

  @override
  State<RequestDetailPage> createState() => _RequestDetailPageState();
}

class _RequestDetailPageState extends State<RequestDetailPage> {
  var data = Get.arguments[0];
  Map<String, dynamic>? detail;
  List<Document>? commentData;
  int current = 0;
  final CarouselController controller = CarouselController();

  late int processIndex;

  @override
  Widget build(BuildContext context) {
    if (data['workStatus'] == "complete") {
      processIndex = 3;
    } else if (data['status'] == "new") {
      processIndex = 1;
    } else {
      processIndex = 2;
    }

    return Scaffold(
      appBar: AppBar(title: const Text('รายละเอียดข้อมูล')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(
              height: 10,
            ),
            Text(
              'หมายเลขเอกสาร: ${data['docSeq']}',
            ),
            data["status"] != "reject"
                ? Column(
                    children: [
                      Container(
                        margin:
                            const EdgeInsets.only(top: 10, left: 10, right: 10),
                        padding: const EdgeInsets.only(top: 10),
                        color: Colors.white,
                        height: 150,
                        child: ProcessTimelinePage(processIndex),
                      ),
                    ],
                  )
                : Container(),
            Container(
              padding: const EdgeInsets.all(10),
              margin: const EdgeInsets.all(10),
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                color: data["status"] == 'reject'
                    ? Colors.redAccent.shade100
                    : Colors.grey,
                borderRadius: const BorderRadius.all(
                  Radius.circular(10),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'สถานะ: ',
                        style: TextStyle(color: Colors.white),
                      ),
                      Text(
                        '${Constants.requestStatus[data["status"]]}',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'ความคิดเห็นล่าสุด: ',
                        style: TextStyle(color: Colors.white),
                      ),
                      commentData != null
                          ? Text(
                              commentData?[0].data["comment"],
                              style: const TextStyle(color: Colors.white),
                            )
                          : Container(),
                    ],
                  ),
                ],
              ),
            ),
            data["type"] == "appeal"
                ? Column(
                    children: [
                      detail != null
                          ? Container(
                              margin: const EdgeInsets.only(
                                  top: 10, left: 10, right: 10),
                              padding: const EdgeInsets.all(10),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.all(
                                  Radius.circular(
                                    10,
                                  ),
                                ),
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Text(
                                          'เมื่อ ${DateFormat.yMMMMEEEEd('th').format(DateTime.fromMillisecondsSinceEpoch(data["requestedAt"] * 1000).toLocal())}'),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'หัวข้อ:',
                                      ),
                                      Text(
                                        '${detail?['name']}',
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'รายละเอียด:',
                                      ),
                                      Text(
                                        '${detail?['detail']}',
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'ที่อยู่:',
                                      ),
                                      Text(
                                        '${detail?['address']}',
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            )
                          : const PlayStoreShimmer(),
                      detail != null
                          ? Container(
                              margin:
                                  const EdgeInsets.only(top: 10, bottom: 10),
                              child: CarouselSlider(
                                items: getCarouseSlider(detail!["images"]),
                                carouselController: controller,
                                options: CarouselOptions(
                                    autoPlay: true,
                                    viewportFraction: 0.98,
                                    enlargeCenterPage: true,
                                    aspectRatio: 16 / 9,
                                    onPageChanged: (index, reason) {
                                      setState(() {
                                        current = index;
                                      });
                                    }),
                              ),
                            )
                          : const PlayStoreShimmer(),
                      detail != null
                          ? SizedBox(
                              height: 250,
                              child: MapGoogle(
                                lat: jsonDecode(detail!["coordinates"])[1],
                                lng: jsonDecode(detail!["coordinates"])[0],
                                label: "สถานที่ร้องเรียน",
                              ),
                            )
                          : const PlayStoreShimmer(),
                    ],
                  )
                : Container(),
            data["type"] == "ems"
                ? Column(
                    children: [
                      detail != null
                          ? Container(
                              margin: const EdgeInsets.only(
                                  top: 10, left: 10, right: 10),
                              padding: const EdgeInsets.all(10),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.all(
                                  Radius.circular(
                                    10,
                                  ),
                                ),
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Text(
                                          'เมื่อ ${DateFormat.yMMMMEEEEd('th').format(DateTime.fromMillisecondsSinceEpoch(data["requestedAt"] * 1000).toLocal())}'),
                                    ],
                                  ),
                                  const Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'หัวข้อ:',
                                      ),
                                      Text(
                                        'บริการการแพทย์ฉุกเฉิน',
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'ประเภทผู้ป่วย:',
                                      ),
                                      Text(
                                        '${Constants.patient[detail?['patientType']]}',
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'เวลานัดหมาย:',
                                      ),
                                      Text(
                                        DateFormat.yMMMMd('th').add_jm().format(
                                            DateTime.fromMillisecondsSinceEpoch(
                                                detail?['bookedDate'])),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'รายละเอียด:',
                                      ),
                                      Text(
                                        '${detail?['purpose']}',
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'ที่อยู่:',
                                      ),
                                      Text(
                                        '${detail?['address']}',
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            )
                          : const PlayStoreShimmer(),
                      detail != null
                          ? Container(
                              margin:
                                  const EdgeInsets.only(top: 10, bottom: 10),
                              child: CarouselSlider(
                                items: getCarouseSlider([
                                  jsonEncode(
                                      jsonDecode(detail!["nationalIdImg"])[0]),
                                  jsonEncode(
                                      jsonDecode(detail!["houseCertImg"])[0])
                                ]),
                                carouselController: controller,
                                options: CarouselOptions(
                                    autoPlay: true,
                                    viewportFraction: 0.98,
                                    enlargeCenterPage: true,
                                    aspectRatio: 16 / 9,
                                    onPageChanged: (index, reason) {
                                      setState(() {
                                        current = index;
                                      });
                                    }),
                              ),
                            )
                          : const PlayStoreShimmer(),
                      detail != null
                          ? SizedBox(
                              height: 250,
                              child: MapGoogle(
                                lat: jsonDecode(detail!["coordinates"])[1],
                                lng: jsonDecode(detail!["coordinates"])[0],
                                label: "สถานที่ร้องเรียน",
                              ))
                          : const PlayStoreShimmer()
                    ],
                  )
                : Container(),
            data["type"] == "trash"
                ? Column(
                    children: [
                      detail != null
                          ? Container(
                              margin: const EdgeInsets.only(
                                  top: 10, left: 10, right: 10),
                              padding: const EdgeInsets.all(10),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.all(
                                  Radius.circular(
                                    10,
                                  ),
                                ),
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Text(
                                          'เมื่อ ${DateFormat.yMMMMEEEEd('th').format(DateTime.fromMillisecondsSinceEpoch(data["requestedAt"] * 1000).toLocal())}'),
                                    ],
                                  ),
                                  const Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'หัวข้อ:',
                                      ),
                                      Text(
                                        'ความต้องการให้เก็บขยะมูลฝอยตำบลหนองปลาหมอ',
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'ประเภทบ้าน:',
                                      ),
                                      Text(
                                        '${detail?['houseType']}',
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'ปริมาณขยะ รายวัน:',
                                      ),
                                      Text(
                                        '${detail?['quantityDailyLitre']} ลิตร',
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'จำนวนถังขยะที่ขอใหม่:',
                                      ),
                                      Text(
                                        '${detail?['totalBin']} ถัง',
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            )
                          : const PlayStoreShimmer(),
                      detail != null
                          ? Container(
                              margin:
                                  const EdgeInsets.only(top: 10, bottom: 10),
                              child: CarouselSlider(
                                items: getCarouseSlider([
                                  jsonEncode(
                                      jsonDecode(detail!["nationalIdImg"])[0]),
                                  jsonEncode(
                                      jsonDecode(detail!["houseCertImg"])[0])
                                ]),
                                carouselController: controller,
                                options: CarouselOptions(
                                    autoPlay: true,
                                    viewportFraction: 0.98,
                                    enlargeCenterPage: true,
                                    aspectRatio: 16 / 9,
                                    onPageChanged: (index, reason) {
                                      setState(() {
                                        current = index;
                                      });
                                    }),
                              ),
                            )
                          : const PlayStoreShimmer(),
                      detail != null
                          ? SizedBox(
                              height: 250,
                              child: MapGoogle(
                                lat: jsonDecode(detail!["coordinates"])[1],
                                lng: jsonDecode(detail!["coordinates"])[0],
                                label: "สถานที่ร้องเรียน",
                              ))
                          : const PlayStoreShimmer()
                    ],
                  )
                : Container(),
            data["type"] == "openBusiness" || data["type"] == "continueBusiness"
                ? Column(
                    children: [
                      detail != null
                          ? Container(
                              margin: const EdgeInsets.only(
                                  top: 10, left: 10, right: 10),
                              padding: const EdgeInsets.all(10),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.all(
                                  Radius.circular(
                                    10,
                                  ),
                                ),
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Text(
                                          'เมื่อ ${DateFormat.yMMMMEEEEd('th').format(DateTime.fromMillisecondsSinceEpoch(data["requestedAt"] * 1000).toLocal())}'),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'หัวข้อ:',
                                      ),
                                      Text(
                                        data["name"],
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'ประเภทธุรกิจ:',
                                      ),
                                      Text(
                                        '${detail!["type"]}',
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            )
                          : const PlayStoreShimmer(),
                      detail != null
                          ? Container(
                              margin:
                                  const EdgeInsets.only(top: 10, bottom: 10),
                              child: CarouselSlider(
                                items: getCarouseSlider([
                                  jsonEncode(
                                      jsonDecode(detail!["nationalIdImg"])[0]),
                                  jsonEncode(
                                      jsonDecode(detail!["houseCertImg"])[0])
                                ]),
                                carouselController: controller,
                                options: CarouselOptions(
                                    autoPlay: true,
                                    viewportFraction: 0.98,
                                    enlargeCenterPage: true,
                                    aspectRatio: 16 / 9,
                                    onPageChanged: (index, reason) {
                                      setState(() {
                                        current = index;
                                      });
                                    }),
                              ),
                            )
                          : const PlayStoreShimmer(),
                      detail != null
                          ? SizedBox(
                              height: 250,
                              child: MapGoogle(
                                lat: jsonDecode(detail!["coordinates"])[1],
                                lng: jsonDecode(detail!["coordinates"])[0],
                                label: "สถานที่ร้องเรียน",
                              ))
                          : const PlayStoreShimmer()
                    ],
                  )
                : Container()
          ],
        ),
      ),
    );
  }

  void getAppealDetailData() async {
    if (data["type"] == "appeal") {
      var detailData = await AppwriteService().getAppeal(data["docId"]);
      setState(() {
        detail = detailData?.data;
      });
      return;
    }
    if (data["type"] == "ems") {
      debugPrint(data.toString());
      var detailData = await AppwriteService().getEms(data["docId"]);
      debugPrint('detail data ${detailData?.data}');
      setState(() {
        detail = detailData?.data;
      });
      return;
    }
    if (data["type"] == "trash") {
      var detailData = await AppwriteService().getTrash(data["docId"]);
      debugPrint('detail data ${detailData?.data}');
      setState(() {
        detail = detailData?.data;
      });
      return;
    }
    if (data["type"] == "openBusiness") {
      var detailData = await AppwriteService().getOpenBusiness(data["docId"]);
      debugPrint('detail data ${detailData?.data}');
      setState(() {
        detail = detailData?.data;
      });
      return;
    }
    if (data["type"] == "continueBusiness") {
      var detailData =
          await AppwriteService().getContinueBusiness(data["docId"]);
      debugPrint('detail data ${detailData?.data}');
      setState(() {
        detail = detailData?.data;
      });
      return;
    }
  }

  List<Widget> getCarouseSlider(List<dynamic> images) {
    return images.map((each) {
      var item = jsonDecode(each);
      return Container(
        height: 200,
        margin: const EdgeInsets.all(5.0),
        child: ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(10.0)),
          child: Stack(
            children: <Widget>[
              CachedNetworkImage(
                  imageUrl: item["url"], fit: BoxFit.cover, width: 500.0),
              Positioned(
                bottom: 20.0,
                left: 0.0,
                right: 0.0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: images.asMap().entries.map((entry) {
                    return GestureDetector(
                      onTap: () => controller.animateToPage(entry.key),
                      child: Container(
                        width: 12.0,
                        height: 12.0,
                        margin: const EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 4.0),
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: (Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Colors.white
                                    : Colors.white60)
                                .withOpacity(current == entry.key ? 0.9 : 0.4)),
                      ),
                    );
                  }).toList(),
                ),
              ),
              Positioned(
                top: 0.0,
                left: 0.0,
                right: 0.0,
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color.fromARGB(0, 0, 0, 0),
                        Color.fromARGB(100, 0, 0, 0),
                      ],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(
                      vertical: 10.0, horizontal: 20.0),
                  child: const Text(
                    '',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }).toList();
  }

  void getCommentData() async {
    var comments = await AppwriteService().getComments(data["\$id"]);
    debugPrint('comments ${comments.toString()}');
    if (comments != null) {
      setState(() {
        commentData = comments.documents;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getAppealDetailData();
    getCommentData();
  }
}
