import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:oss/presentation/widgets/tab_view.dart';

class PoisPage extends StatefulWidget {
  const PoisPage({super.key});

  @override
  State<PoisPage> createState() => _PoisPageState();
}

class _PoisPageState extends State<PoisPage> {
  int activeTab = Get.arguments[0];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('แนะนำสถานที่'),
        ),
        body: Container(
          margin: const EdgeInsets.only(top: 10),
          child: TabView(
            activeTab: activeTab,
          ),
        ));
  }
}
