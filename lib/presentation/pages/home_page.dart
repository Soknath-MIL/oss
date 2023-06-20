import 'dart:convert';

import 'package:appwrite/appwrite.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_shimmer/flutter_shimmer.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:oss/presentation/controllers/appeal_list_controller.dart';
import 'package:oss/presentation/controllers/doc_type_controller.dart';
import 'package:oss/presentation/controllers/message_controller.dart';
import 'package:oss/presentation/controllers/unit_controller.dart';

import '../../constants/constants.dart';
import '../../data/services/appwrite_service.dart';
import '../controllers/news_controller.dart';
import '../widgets/vetical_tab_view.dart';

List<Map<String, dynamic>> dataMenu = [
  {"icon": "assets/images/compaign.png", "name": "ติดตามคำขอ", "id": "request"},
  {
    "icon": "assets/images/contact.png",
    "name": "เบอร์โทรฉุกเฉิน",
    "id": "emergency"
  },
  {"icon": "assets/images/mail.png", "name": "ข่าวสาร", "id": "news"},
  {"icon": "assets/images/paid.png", "name": "ชำระค่าบริการ", "id": "payment"},
  {"icon": "assets/images/info.png", "name": "ติดต่อเรา", "id": "contact"}
];

List<Map<String, dynamic>> dataService = [
  {
    "icon": "assets/images/service4.png",
    "name": "ขอลงทะเบียนผู้สูงอายุ",
    'id': 'ems'
  },
  {
    "icon": "assets/images/service1.png",
    "name": "ขอจดทะเบียนพาณิชย์",
    'id': 'test'
  },
  {"icon": "assets/images/service2.png", "name": "แจ้งปลดป้าย-เปลี่ยนแปลงป้าย"},
  {"icon": "assets/images/service3.png", "name": "ขอลงทะเบียนผู้สูงอายุ"}
];

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class HorizonMenu extends StatefulWidget {
  final List<Map<String, dynamic>> data;

  const HorizonMenu({super.key, required this.data});

  @override
  State<HorizonMenu> createState() => _HorizonMenuState();
}

class ServiceMenu extends StatefulWidget {
  final List<Map<String, dynamic>> data;
  const ServiceMenu({super.key, required this.data});

  @override
  State<ServiceMenu> createState() => _ServiceMenuState();
}

class _HomeScreenState extends State<HomeScreen> {
  int current = 0;
  final CarouselController controller = CarouselController();
  List<String> boardList = [];
  final NewsController newsController = Get.put(NewsController());
  final DocTypesController docTypesController = Get.put(DocTypesController());
  final UnitController unitsController = Get.put(UnitController());
  final AppealListController appealListController =
      Get.put(AppealListController());
  final errorMessageController = TextEditingController();
  bool isLoading = true;

  @override
  Widget build(BuildContext context) {
    if (errorMessageController.text.isNotEmpty) {
      return Center(child: Text(errorMessageController.text));
    }

    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    return SafeArea(
      child: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.only(bottom: 0),
          child: Column(
            children: [
              Stack(children: [
                SizedBox(
                  height: 250,
                  child: Column(children: [
                    FutureBuilder<List<String>>(
                      future: fetchBoard(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          boardList = snapshot.data!;
                          return Expanded(
                            child: CarouselSlider(
                              items: getCarouseSlider(boardList),
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
                          );
                        } else if (snapshot.hasError) {
                          return Text('${snapshot.error}');
                        }
                        return const SizedBox(
                            height: 250, child: Center(child: VideoShimmer()));
                      },
                    ),
                  ]),
                ),
              ]),
              Container(
                padding: const EdgeInsets.all(8),
                margin: const EdgeInsets.only(bottom: 10),
                decoration: const BoxDecoration(color: Colors.white),
                height: 150,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'บริการร้องเรียนยอดนิยม',
                      style: TextStyle(color: Colors.green),
                    ),
                    HorizonMenu(data: dataMenu),
                  ],
                ),
              ),

              // Appeal list
              appealListController.obx(
                (state) {
                  var appealData = appealListController.appealList;
                  return Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(color: Colors.white),
                    height: 145,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'แจ้งเรื่องร้องเรียน',
                              style: TextStyle(color: Colors.green),
                            ),
                            GestureDetector(
                              onTap: () {
                                Get.toNamed('/appeal-list');
                              },
                              child: const Text(
                                'ดูทั้งหมด',
                                style: TextStyle(color: Colors.green),
                              ),
                            ),
                          ],
                        ),
                        Expanded(
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: List.generate(
                              appealData.length,
                              (index) => GestureDetector(
                                onTap: () async {
                                  // check if flow of current appeal exist
                                  var docExist = await AppwriteService()
                                      .checkDocMaster(
                                          appealData[index]["\$id"]);
                                  if (docExist == null) {
                                    Get.snackbar(
                                      "ข้อผิดพลาด",
                                      "ไม่มีเวิร์กโฟลว์ ของเอกสาร",
                                      colorText: Colors.white,
                                      icon: const Icon(Icons.cancel),
                                      snackPosition: SnackPosition.TOP,
                                    );
                                  } else {
                                    Get.toNamed("/appeal-request", arguments: [
                                      docExist.documents[0].data["\$id"],
                                      appealData[index]["\$id"],
                                      appealData[index]["name"],
                                      docExist.documents[0].data["docOwner"],
                                    ]);
                                  }
                                },
                                child: Column(
                                  children: [
                                    Container(
                                      margin: const EdgeInsets.only(
                                          left: 20,
                                          right: 20,
                                          top: 10,
                                          bottom: 10),
                                      width: 60,
                                      decoration: const BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            offset: Offset(0, 1),
                                            color: Colors.black12,
                                            blurRadius: 10,
                                          )
                                        ],
                                      ),
                                      padding: const EdgeInsets.all(10),
                                      child: appealData[index]["icon"] != null
                                          ? CachedNetworkImage(
                                              imageUrl: jsonDecode(
                                                  appealData[index]
                                                      ["icon"])[0]["url"],
                                              height: 40,
                                            )
                                          : const Icon(
                                              Icons.question_mark,
                                              color: Colors.green,
                                              size: 40,
                                            ),
                                    ),
                                    Text(
                                      appealData[index]["name"] ?? "",
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
                onLoading: const Center(child: PlayStoreShimmer()),
              ),

              // doc type
              docTypesController.obx(
                (state) {
                  List<Map<String, dynamic>> dataMap = [];
                  for (var element in docTypesController.docTyesList) {
                    dataMap.add(element.data);
                  }

                  return Container(
                    margin: const EdgeInsets.only(top: 10),
                    padding: const EdgeInsets.all(10),
                    height: 180,
                    color: Colors.white,
                    child: SizedBox(
                      height: 40,
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'บริการร้องขอยอดนิยม',
                                style: TextStyle(color: Colors.green),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Get.toNamed('/request-list', arguments: [""]);
                                },
                                child: const Text(
                                  'ดูทั้งหมด',
                                  style: TextStyle(color: Colors.green),
                                ),
                              ),
                            ],
                          ),
                          Expanded(
                            child: ServiceMenu(
                              data: dataMap,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                onLoading: const Center(child: PlayStoreShimmer()),
              ),

              // unit
              unitsController.obx(
                (state) {
                  List<Map<String, dynamic>> dataUnitMap = [];
                  for (var element in unitsController.unitList) {
                    dataUnitMap.add(
                      {
                        ...element.data,
                        "name": element.data["name_t"],
                      },
                    );
                  }
                  return Container(
                    margin: const EdgeInsets.only(top: 10),
                    padding: const EdgeInsets.all(10),
                    color: Colors.white,
                    height: 250,
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'บริการร้องขอตามแผนก',
                              style: TextStyle(color: Colors.green),
                            ),
                            GestureDetector(
                              onTap: () {
                                Get.toNamed('/request-list', arguments: [""]);
                              },
                              child: const Text(
                                'ดูทั้งหมด',
                                style: TextStyle(color: Colors.green),
                              ),
                            ),
                          ],
                        ),
                        Expanded(
                          child: ServiceMenu(
                            data: dataUnitMap,
                          ),
                        ),
                      ],
                    ),
                  );
                },
                onLoading: const Center(child: PlayStoreShimmer()),
              ),

              Container(
                padding: const EdgeInsets.all(10),
                margin: const EdgeInsets.only(top: 10),
                color: Colors.transparent,
                height: 250,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'ข่าวสาร/กิจกรรม',
                          style: TextStyle(color: Colors.green),
                        ),
                        GestureDetector(
                          onTap: () {
                            Get.toNamed("/news");
                          },
                          child: const Text(
                            'ดูทั้งหมด',
                            style: TextStyle(color: Colors.green),
                          ),
                        ),
                      ],
                    ),
                    Expanded(
                      child: Obx(() {
                        debugPrint('${newsController.newsList}');
                        return ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: newsController.newsList.length,
                          itemBuilder: (ctx, i) {
                            var createdAt = DateTime.parse(newsController
                                    .newsList[i].data['\$createdAt'])
                                .toLocal();
                            var formatted =
                                DateFormat.yMMMMEEEEd('th').format(createdAt);
                            return GestureDetector(
                              onTap: () {
                                Get.toNamed("/news-detail", arguments: [
                                  newsController.newsList[i].data
                                ]);
                              },
                              child: Container(
                                height: 200,
                                width: 200,
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                margin: const EdgeInsets.all(5),
                                child: Stack(
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        SizedBox(
                                          height: 90,
                                          child: ClipRRect(
                                            borderRadius:
                                                const BorderRadius.all(
                                                    Radius.circular(16)),
                                            child: CachedNetworkImage(
                                              imageUrl: jsonDecode(
                                                      newsController.newsList[i]
                                                          .data['images'])[0]
                                                  ["url"],
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          formatted,
                                          overflow: TextOverflow.ellipsis,
                                          textAlign: TextAlign.start,
                                          style: const TextStyle(
                                            fontSize: 10,
                                          ),
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                newsController
                                                    .newsList[i].data['title'],
                                                softWrap: true,
                                                maxLines: 3,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  fontSize: 15,
                                                ),
                                              ),
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      }),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              const VerticalTabView()
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    errorMessageController.dispose();
    super.dispose();
  }

  Future<List<String>> fetchBoard() async {
    final database = Databases(Appwrite.instance.client);
    var data = await database.listDocuments(
      databaseId: Constants.databseId,
      collectionId: Constants.boardId,
    );
    List<String> values = [];
    for (var imageone in data.documents[0].data["pictures"]!) {
      values.add(jsonDecode(imageone)["url"]);
    }
    return values;
  }

  List<Widget> getCarouseSlider(List<String> boardList) {
    return boardList
        .map((item) => Container(
              child: Container(
                height: 250,
                margin: const EdgeInsets.all(5.0),
                child: ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(10.0)),
                  child: Stack(
                    children: <Widget>[
                      CachedNetworkImage(
                        imageUrl: item,
                        fit: BoxFit.cover,
                        width: 1000.0,
                      ),
                      Positioned(
                        bottom: 5.0,
                        left: 0.0,
                        right: 0.0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: boardList.asMap().entries.map((entry) {
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
                                        .withOpacity(
                                            current == entry.key ? 0.9 : 0.4)),
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
                                Color.fromARGB(200, 0, 0, 0),
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
              ),
            ))
        .toList();
  }

  @override
  void initState() {
    super.initState();
    loadController();
  }

  Future<void> loadController() async {
    try {
      await Get.putAsync(() async => newsController);
      setState(() {
        isLoading = false;
      });
    } catch (error) {
      setState(() {
        errorMessageController.text = 'Error: ${error.toString()}';
      });
    }
  }
}

class _HorizonMenuState extends State<HorizonMenu> {
  final _formKey = GlobalKey<FormBuilderState>();
  final MessageConroller messageController = Get.put(MessageConroller());
  bool address = false;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: List.generate(
          widget.data.length,
          (index) => GestureDetector(
            onTap: () async {
              if (widget.data[index]["id"] == 'news') {
                Get.toNamed("/news");
                return;
              }
              if (widget.data[index]["id"] == 'request') {
                await EasyLoading.show(
                  status: 'ตรวจสอบผู้ใช้...',
                  maskType: EasyLoadingMaskType.black,
                );
                await messageController.getUserId();
                await EasyLoading.dismiss();
                Get.toNamed("/request");
                return;
              }
              if (widget.data[index]["id"] == 'emergency') {
                Get.toNamed("/emergency");
                return;
              }
              if (widget.data[index]["id"] == 'contact') {
                Get.toNamed("/contact");
                return;
              }
              if (widget.data[index]["id"] == 'payment') {
                showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        content: StatefulBuilder(builder:
                            (BuildContext context, StateSetter setState) {
                          return Container(
                            height: 260,
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: [
                                Expanded(
                                  child: Column(
                                    children: [
                                      FormBuilder(
                                        key: _formKey,
                                        child: Column(
                                          children: [
                                            FormBuilderTextField(
                                              name: 'nationalId',
                                              initialValue: '3190300425582',
                                              keyboardType:
                                                  TextInputType.number,
                                              decoration: customInputDecoration(
                                                  'ค้นหารหัสประจำตัวประชาชน'),
                                              validator: FormBuilderValidators
                                                  .required(),
                                            ),
                                            SizedBox(
                                              height: 60,
                                              child:
                                                  Row(children: const <Widget>[
                                                Expanded(child: Divider()),
                                                Text("หรือ"),
                                                Expanded(child: Divider()),
                                              ]),
                                            ),
                                            FormBuilderTextField(
                                              name: 'address',
                                              initialValue: '30/1 หมู่ 3',
                                              keyboardType:
                                                  TextInputType.number,
                                              decoration: customInputDecoration(
                                                  'ค้นหาที่อยู่ (ตัวอย่าง xx/x หมู่ x)'),
                                              validator: FormBuilderValidators
                                                  .required(),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 16,
                                      ),
                                      ElevatedButton(
                                        child: const Text('ยืนยัน'),
                                        onPressed: () async {
                                          // Get.toNamed("/payment-detail");
                                          // update user name in appwrite
                                          if (_formKey.currentState!
                                              .validate()) {
                                            _formKey.currentState?.save();
                                            // get data from trash
                                            await EasyLoading.show(
                                              status: 'ตรวจสอบผู้ใช้...',
                                              maskType:
                                                  EasyLoadingMaskType.black,
                                            );
                                            await messageController.getUserId();
                                            var taxData = await AppwriteService()
                                                .searchTrashTax(
                                                    _formKey.currentState
                                                            ?.value[
                                                        "nationalId"], //integer required TODO
                                                    _formKey.currentState
                                                        ?.value["address"],
                                                    DateTime.now().year + 543);

                                            // close dialog
                                            if (taxData == null) {
                                              Get.snackbar(
                                                "ข้อผิดพลาด",
                                                "ไม่พบข้อมูล",
                                                colorText: Colors.white,
                                                icon: const Icon(Icons.cancel),
                                                snackPosition:
                                                    SnackPosition.TOP,
                                              );
                                            } else {
                                              // GO to tax detail
                                              Get.back();
                                              Get.toNamed("/tax-payment",
                                                  arguments: [
                                                    taxData,
                                                    _formKey.currentState
                                                        ?.value["nationalId"],
                                                    _formKey.currentState
                                                        ?.value["address"]
                                                  ]);
                                            }
                                            EasyLoading.dismiss();
                                            // Get.back();
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      );
                    });
                return;
              }
              Get.toNamed("/appeal-request");
            },
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.only(
                      left: 20, right: 20, top: 10, bottom: 10),
                  width: 60,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        offset: Offset(0, 1),
                        color: Colors.black12,
                        blurRadius: 10,
                      )
                    ],
                  ),
                  padding: const EdgeInsets.all(10),
                  child: Image.asset(
                    widget.data[index]["icon"],
                  ),
                ),
                Text(
                  widget.data[index]["name"],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  customInputDecoration(label) {
    return InputDecoration(
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
}

class _ServiceMenuState extends State<ServiceMenu> {
  final MessageConroller messageController = Get.put(MessageConroller());

  @override
  Widget build(BuildContext context) {
    return ListView(
      scrollDirection: Axis.horizontal,
      children: List.generate(
        widget.data.length,
        (index) => GestureDetector(
          onTap: () async {
            if (widget.data[index]["link"] != null) {
              var docExist = await AppwriteService()
                  .checkDocMasterName(widget.data[index]["link"]);
              if (docExist == null) {
                Get.snackbar(
                  "ข้อผิดพลาด",
                  "ไม่มีเวิร์กโฟลว์ ของเอกสาร",
                  colorText: Colors.white,
                  icon: const Icon(Icons.cancel),
                  snackPosition: SnackPosition.TOP,
                );
                return;
              }
              // check login account;
              await EasyLoading.show(
                status: 'ตรวจสอบผู้ใช้...',
                maskType: EasyLoadingMaskType.black,
              );
              await messageController.getUserId();
              await EasyLoading.dismiss();
              Get.toNamed("/${widget.data[index]["link"]}-form");
              return;
            }
            if (widget.data[index]["unit_id"] != null) {
              // display only specific form
              debugPrint('service click ${widget.data[index]["\$id"]}');
              Get.toNamed("/request-list",
                  arguments: [widget.data[index]["\$id"]]);
              return;
            }
            Get.snackbar(
              "ข้อผิดพลาด",
              "In Progress",
              colorText: Colors.white,
              icon: const Icon(Icons.cancel),
              snackPosition: SnackPosition.TOP,
            );
          },
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              Container(
                margin:
                    const EdgeInsets.only(left: 5, right: 5, top: 5, bottom: 5),
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  boxShadow: [
                    BoxShadow(
                      offset: Offset(0, 1),
                      color: Colors.white,
                      blurRadius: 2,
                    )
                  ],
                ),
                child: CachedNetworkImage(
                  imageUrl: widget.data[index]["image"] != null
                      ? jsonDecode(widget.data[index]["image"])[0]["url"]
                      : '',
                ),
              ),
              Positioned(
                top: 10,
                child: Container(
                  padding: const EdgeInsets.only(left: 10, right: 10),
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.all(
                      Radius.circular(16),
                    ),
                  ),
                  child: Center(
                    child: Text(widget.data[index]["name"],
                        style:
                            const TextStyle(color: Colors.white, fontSize: 12)),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
