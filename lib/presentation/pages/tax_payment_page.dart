import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:oss/constants/constants.dart';
import 'package:oss/data/services/appwrite_service.dart';

const months = [
  "ตุลาคม",
  "พฤศจิกายน",
  "ธันวาคม",
  "มกราคม",
  "กุมภาพันธ์",
  "มีนาคม",
  "เมษายน",
  "พฤษภาคม",
  "มิถุนายน",
  "กรกฎาคม",
  "สิงหาคม",
  "กันยายน",
];

class TaxPaymentPage extends StatefulWidget {
  const TaxPaymentPage({super.key});

  @override
  State<TaxPaymentPage> createState() => _TaxPaymentPageState();
}

class _TaxPaymentPageState extends State<TaxPaymentPage> {
  int selectedYear = DateTime.now().year + 543;
  var taxData = Get.arguments[0];
  var nationalId = Get.arguments[1];
  var address = Get.arguments[2];
  var isChecked = List.generate(12, (index) => false);
  int totalSelectedPrice = 0;

  var itemData = [
    {
      "expanded": false,
      "name": "ชำระค่าธรรมเนียมการจัดเก็บขยะ",
      "icon": "assets/images/trash.png"
    },
    {
      "expanded": false,
      "name": "ชำระค่าธรรมเนียมป้าย",
      "icon": "assets/images/tax-sign.png"
    },
    {
      "expanded": false,
      "name": "ชำระค่าธรรมเนียมอื่นๆ",
      "icon": "assets/images/tax-other.png"
    }
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'ชำระค่าบริการ',
        ),
      ),
      body: Container(
        padding: const EdgeInsets.only(top: 10, bottom: 10),
        child: ListView.builder(
          itemCount: itemData.length,
          itemBuilder: (BuildContext context, int index) {
            return ExpansionPanelList(
              animationDuration: const Duration(milliseconds: 1000),
              dividerColor: Colors.red,
              elevation: 1,
              children: [
                ExpansionPanel(
                  body: index == 0
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            FloatingActionButton.extended(
                              heroTag: 'tax',
                              elevation: 0,
                              onPressed: () {
                                showModalBottomSheet(
                                    context: context,
                                    builder: (context) {
                                      return Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          ListTile(
                                            leading: const Icon(
                                                Icons.calendar_month,
                                                color: Colors.green),
                                            title: Text(
                                                (DateTime.now().year + 543)
                                                    .toString()),
                                            onTap: () async {
                                              // retrive new data
                                              var newdata =
                                                  await AppwriteService()
                                                      .searchTrashTax(
                                                          nationalId,
                                                          address,
                                                          DateTime.now().year +
                                                              543);
                                              setState(() {
                                                taxData = newdata;
                                                selectedYear =
                                                    DateTime.now().year + 543;
                                              });
                                              // ignore: use_build_context_synchronously
                                              Navigator.pop(context);
                                            },
                                          ),
                                          ListTile(
                                            leading: const Icon(
                                              Icons.calendar_month,
                                              color: Colors.green,
                                            ),
                                            title: Text(
                                                (DateTime.now().year + 543 - 1)
                                                    .toString()),
                                            onTap: () async {
                                              // retrive new data
                                              var newdata =
                                                  await AppwriteService()
                                                      .searchTrashTax(
                                                          nationalId,
                                                          address,
                                                          DateTime.now().year +
                                                              543 -
                                                              1);
                                              setState(() {
                                                taxData = newdata;
                                                selectedYear =
                                                    DateTime.now().year +
                                                        543 -
                                                        1;
                                              });
                                              // ignore: use_build_context_synchronously
                                              Navigator.pop(context);
                                            },
                                          ),
                                          ListTile(
                                            leading: const Icon(
                                              Icons.calendar_month,
                                              color: Colors.green,
                                            ),
                                            title: Text(
                                                (DateTime.now().year + 543 - 2)
                                                    .toString()),
                                            onTap: () async {
                                              // retrive new data
                                              var newdata =
                                                  await AppwriteService()
                                                      .searchTrashTax(
                                                          nationalId,
                                                          address,
                                                          DateTime.now().year +
                                                              543 -
                                                              2);
                                              setState(() {
                                                taxData = newdata;
                                                selectedYear =
                                                    DateTime.now().year +
                                                        543 -
                                                        2;
                                              });
                                              // ignore: use_build_context_synchronously
                                              Navigator.pop(context);
                                              // refetch data
                                            },
                                          ),
                                        ],
                                      );
                                    });
                              },
                              label: Text(
                                selectedYear.toString(),
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            taxData != null
                                ? Container(
                                    padding: const EdgeInsets.all(10),
                                    color: Colors.grey[100],
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        // นาย สมชาย แน่นนอน ประเภท ครัวเรือน บ้านเลขที่ 99/1 หมู่ 10
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  '${taxData["title"]} ${taxData["firstname"]} ${taxData["lastname"]} ประเภท ${taxData["type"]}',
                                                ),
                                                Text(
                                                  '${taxData["address"]}',
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        const Divider(),
                                        SizedBox(
                                          child: Table(
                                            columnWidths: const {
                                              0: FlexColumnWidth(3),
                                              1: FlexColumnWidth(4),
                                              2: FlexColumnWidth(2),
                                              3: FlexColumnWidth(2),
                                            },
                                            children: [
                                              TableRow(
                                                children: [
                                                  const TableCell(
                                                    verticalAlignment:
                                                        TableCellVerticalAlignment
                                                            .top,
                                                    child: SizedBox(
                                                      height: 36,
                                                      child: Text("เดือน"),
                                                    ),
                                                  ),
                                                  const TableCell(
                                                    verticalAlignment:
                                                        TableCellVerticalAlignment
                                                            .top,
                                                    child: SizedBox(
                                                      height: 36,
                                                      child: Text(
                                                          "ค่าบริการ (บาท)"),
                                                    ),
                                                  ),
                                                  const TableCell(
                                                    verticalAlignment:
                                                        TableCellVerticalAlignment
                                                            .top,
                                                    child: SizedBox(
                                                      height: 36,
                                                      child: Text("สถานะ"),
                                                    ),
                                                  ),
                                                  TableCell(
                                                    verticalAlignment:
                                                        TableCellVerticalAlignment
                                                            .top,
                                                    child: Container(
                                                      margin:
                                                          const EdgeInsets.only(
                                                              right: 20),
                                                      height: 36,
                                                      child: const Text(
                                                        "เลือก",
                                                        textAlign:
                                                            TextAlign.end,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              for (var i = 0;
                                                  i < taxData["detail"].length;
                                                  i++)
                                                TableRow(
                                                  children: [
                                                    TableCell(
                                                      verticalAlignment:
                                                          TableCellVerticalAlignment
                                                              .top,
                                                      child: SizedBox(
                                                        height: 36,
                                                        child: Text(months[i]),
                                                      ),
                                                    ),
                                                    TableCell(
                                                      verticalAlignment:
                                                          TableCellVerticalAlignment
                                                              .top,
                                                      child: SizedBox(
                                                        height: 36,
                                                        child: Text(
                                                          jsonDecode(
                                                              taxData["detail"]
                                                                  [i])["price"],
                                                          textAlign:
                                                              TextAlign.center,
                                                        ),
                                                      ),
                                                    ),
                                                    TableCell(
                                                      verticalAlignment:
                                                          TableCellVerticalAlignment
                                                              .top,
                                                      child: SizedBox(
                                                        height: 36,
                                                        child: Text(
                                                          jsonDecode(taxData["detail"]
                                                                          [i])[
                                                                      "status"] ==
                                                                  "new"
                                                              ? Constants
                                                                      .taxPaymentStatus[
                                                                  "new"]!
                                                              : (jsonDecode(taxData["detail"]
                                                                              [
                                                                              i])[
                                                                          "status"] ==
                                                                      "complete"
                                                                  ? Constants
                                                                          .taxPaymentStatus[
                                                                      "complete"]!
                                                                  : Constants
                                                                          .taxPaymentStatus[
                                                                      "confirm"]!),
                                                        ),
                                                      ),
                                                    ),
                                                    TableCell(
                                                      verticalAlignment:
                                                          TableCellVerticalAlignment
                                                              .top,
                                                      child: SizedBox(
                                                          height: 36,
                                                          child: Checkbox(
                                                            shape:
                                                                RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                4,
                                                              ),
                                                            ),
                                                            checkColor:
                                                                isChecked[i]
                                                                    ? Colors
                                                                        .white
                                                                    : Colors
                                                                        .black,
                                                            value: jsonDecode(taxData["detail"]
                                                                            [
                                                                            i])[
                                                                        "status"] ==
                                                                    "new"
                                                                ? isChecked[i]
                                                                : true,
                                                            onChanged:
                                                                (bool? value) {
                                                              setState(() {
                                                                isChecked[i] =
                                                                    value!;
                                                              });
                                                              // calculated total selected price
                                                              calculatedPrice();
                                                            },
                                                          )),
                                                    ),
                                                  ],
                                                ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          decoration: BoxDecoration(
                                              color: Colors.green[300],
                                              borderRadius:
                                                  const BorderRadius.all(
                                                      Radius.circular(10))),
                                          padding: const EdgeInsets.all(10),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              const Text(
                                                  'ยอดรวมที่ต้องการชำระ'),
                                              Text(
                                                totalSelectedPrice.toString(),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        Center(
                                          child: FloatingActionButton.extended(
                                            heroTag: 'payment',
                                            icon: const Icon(Icons.upload),
                                            onPressed: () {
                                              bool allTrue = isChecked.every(
                                                  (element) => element == true);
                                              if (!allTrue) {
                                                Get.toNamed('/payment-detail',
                                                    arguments: [
                                                      taxData,
                                                      isChecked,
                                                      totalSelectedPrice
                                                    ]);
                                              } else {
                                                Get.snackbar(
                                                  "ข้อผิดพลาด",
                                                  "ไม่มีจำนวนเงินที่ต้องจ่าย",
                                                  colorText: Colors.white,
                                                  icon:
                                                      const Icon(Icons.cancel),
                                                  snackPosition:
                                                      SnackPosition.TOP,
                                                );
                                              }
                                            },
                                            label: const Text("ดำเนินการต่อ"),
                                          ),
                                        )
                                      ],
                                    ),
                                  )
                                : const SizedBox(
                                    height: 50,
                                    child: Center(child: Text('ไม่พบข้อมูล')),
                                  ),
                          ],
                        )
                      : Container(),
                  headerBuilder: (BuildContext context, bool isExpanded) {
                    return Container(
                      padding: const EdgeInsets.all(10),
                      child: Row(
                        children: [
                          Image.asset(itemData[index]["icon"].toString()),
                          const SizedBox(
                            width: 16,
                          ),
                          Text(
                            itemData[index]["name"].toString(),
                            style: const TextStyle(
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  isExpanded: itemData[index]["expanded"] as bool,
                )
              ],
              expansionCallback: (int item, bool status) {
                setState(() {
                  itemData[index]["expanded"] =
                      !(itemData[index]["expanded"]! as bool);
                });
              },
            );
          },
        ),
      ),
    );
  }

  void calculatedPrice() {
    int newPrice = 0;
    for (var i = 0; i < isChecked.length; i++) {
      if (isChecked[i]) {
        newPrice += int.parse(jsonDecode(taxData["detail"][i])["price"]);
        setState(() {
          totalSelectedPrice = newPrice;
        });
      }
    }
  }
}
