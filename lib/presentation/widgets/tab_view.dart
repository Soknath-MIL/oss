import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:oss/presentation/widgets/poi_destination.dart';

class TabView extends StatefulWidget {
  final int? activeTab;
  const TabView({Key? key, required this.activeTab}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _TabViewState createState() => _TabViewState();
}

class _TabViewState extends State<TabView> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _selectedColor = Colors.green[200];
  final _unselectedColor = const Color(0xff5f6368);
  final _tabs = [
    const Tab(text: 'กิน'),
    const Tab(text: 'เที่ยว'),
    const Tab(text: 'ที่พัก'),
    const Tab(text: 'ห้าง'),
    const Tab(text: 'โรงงาน'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height -
          AppBar().preferredSize.height -
          16,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.lightGreen[50],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'แนะนำสถานที่',
                style: TextStyle(color: Colors.green),
              ),
              GestureDetector(
                onTap: () {
                  Get.toNamed("/map-view");
                },
                child: const Text(
                  'ดูบนแผนที่',
                  style: TextStyle(color: Colors.green),
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          Container(
            height: kToolbarHeight - 8.0,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.0),
                  color: _selectedColor),
              labelColor: Colors.white,
              unselectedLabelColor: Colors.black,
              tabs: _tabs,
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const <Widget>[
                Center(
                  child: SingleChildScrollView(
                    child: Destinations(type: "food"),
                  ),
                ),
                Center(
                  child: SingleChildScrollView(
                    child: Destinations(type: "tourist"),
                  ),
                ),
                Center(
                  child: SingleChildScrollView(
                    child: Destinations(type: "hotel"),
                  ),
                ),
                Center(
                  child: SingleChildScrollView(
                    child: Destinations(type: "shopping"),
                  ),
                ),
                Center(
                  child: SingleChildScrollView(
                    child: Destinations(type: "factory"),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
  }

  @override
  void initState() {
    _tabController = TabController(
        length: _tabs.length, vsync: this, initialIndex: widget.activeTab!);
    super.initState();
  }
}
