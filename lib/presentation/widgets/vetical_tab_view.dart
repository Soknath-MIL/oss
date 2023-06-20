import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:oss/presentation/widgets/poi_destination.dart';

class VerticalTabView extends StatefulWidget {
  const VerticalTabView({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _VerticalTabViewState createState() => _VerticalTabViewState();
}

class _VerticalTabViewState extends State<VerticalTabView>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  NavigationRailLabelType labelType = NavigationRailLabelType.all;
  bool showLeading = false;
  bool showTrailing = false;
  double groupAlignment = -1.0;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height -
          AppBar().preferredSize.height -
          16,
      padding: const EdgeInsets.only(left: 16),
      decoration: BoxDecoration(
        color: Colors.lightGreen[50],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      _selectedIndex == 0
                          ? const SingleChildScrollView(
                              child: Destinations(type: "food"),
                            )
                          : Container(),
                      _selectedIndex == 1
                          ? const SingleChildScrollView(
                              child: Destinations(type: "tourist"),
                            )
                          : Container(),
                      _selectedIndex == 2
                          ? const SingleChildScrollView(
                              child: Destinations(type: "hotel"),
                            )
                          : Container(),
                      _selectedIndex == 3
                          ? const Destinations(type: "shopping")
                          : Container(),
                      _selectedIndex == 4
                          ? const Destinations(type: "factory")
                          : Container(),
                    ],
                  ),
                ),
                const VerticalDivider(thickness: 1, width: 1),

                NavigationRail(
                  leading: FloatingActionButton(
                    elevation: 0,
                    onPressed: () {
                      // Add your onPressed code here!
                      Get.toNamed("/map-view");
                    },
                    child: const Icon(Icons.map),
                  ),
                  selectedIndex: _selectedIndex,
                  groupAlignment: groupAlignment,
                  onDestinationSelected: (int index) {
                    setState(() {
                      _selectedIndex = index;
                    });
                  },
                  labelType: labelType,
                  destinations: const <NavigationRailDestination>[
                    NavigationRailDestination(
                      icon: Icon(Icons.food_bank_outlined),
                      selectedIcon: Icon(Icons.food_bank_outlined),
                      label: Text('กิน'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.tour),
                      selectedIcon: Icon(Icons.tour),
                      label: Text('เที่ยว'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.holiday_village),
                      selectedIcon: Icon(Icons.holiday_village),
                      label: Text('ที่พัก'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.shop),
                      selectedIcon: Icon(Icons.shop),
                      label: Text('ห้าง'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.hotel),
                      selectedIcon: Icon(Icons.hotel),
                      label: Text('โรงงาน'),
                    ),
                  ],
                ),
                // This is the main content.
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
  }
}
