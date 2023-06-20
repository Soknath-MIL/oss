import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_shimmer/flutter_shimmer.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

import '../../constants/constants.dart';
import '../controllers/request_controller.dart';

class RequestPage extends StatefulWidget {
  const RequestPage({super.key});

  @override
  State<RequestPage> createState() => _RequestPageState();
}

class _RequestPageState extends State<RequestPage> {
  final RequestController _requestConroller = Get.put(RequestController());

  @override
  Widget build(BuildContext context) {
    debugPrint('notification list ${_requestConroller.reqList.toString()}');
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('ติดตาม'),
        ),
        body: RefreshIndicator(
          onRefresh: _pullRefresh,
          child: _requestConroller.obx(
            (state) {
              return FadeInDown(
                child: ListView(
                  scrollDirection: Axis.vertical,
                  children: List.generate(
                    _requestConroller.reqList.length,
                    (index) => renderItem(index),
                  ),
                ),
              );
            },
            onLoading: Column(
              children: const [
                PlayStoreShimmer(),
                PlayStoreShimmer(),
                PlayStoreShimmer(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void getRequestData() async {
    await _requestConroller.getAllRequest();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getRequestData();
  }

  renderItem(int index) {
    var data = _requestConroller.reqList[index].data;
    return GestureDetector(
      onTap: () {
        Get.toNamed("/request-detail", arguments: [data]);
      },
      child: Container(
          margin: const EdgeInsets.only(left: 16, right: 16, top: 10),
          padding: const EdgeInsets.all(10),
          height: 100,
          decoration: BoxDecoration(
            color: data["status"] == "new"
                ? Colors.grey.shade300
                : data["status"] == "complete"
                    ? Colors.green.shade400
                    : Colors.yellow.shade400,
            borderRadius: const BorderRadius.all(
              Radius.circular(16),
            ),
            boxShadow: const [
              BoxShadow(
                offset: Offset(0, 1),
                color: Colors.black12,
                blurRadius: 3,
              )
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Image.network(jsonDecode(data["images"][0])["url"]),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 300,
                        child: Text(
                          'หัวข้อ ${data["docSeq"]}',
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                      Text(
                        'เมื่อ ${DateFormat.yMMMMEEEEd('th').format(DateTime.fromMillisecondsSinceEpoch(data["requestedAt"] * 1000).toLocal())}',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                  LinearPercentIndicator(
                    width: 100.0,
                    lineHeight: 8.0,
                    percent: data["currentStep"] / data["totalStep"],
                    progressColor: Colors.blue,
                  )
                ],
              ),

              Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Chip(
                    backgroundColor: Colors.green[200],
                    shadowColor: Colors.black54,
                    label: Text(
                      '${Constants.requestStatus[data["status"]]}',
                      style: const TextStyle(fontSize: 10),
                      textAlign: TextAlign.end,
                    ),
                  )
                ],
              ),
            ],
          )),
    );
  }

  Future<void> _pullRefresh() async {
    await _requestConroller.getAllRequest();
  }
}
