import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:oss/presentation/controllers/emergency_controller.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../constants/constants.dart';

class EmergencyContactPage extends StatefulWidget {
  const EmergencyContactPage({super.key});

  @override
  State<EmergencyContactPage> createState() => _EmergencyContactPageState();
}

class _EmergencyContactPageState extends State<EmergencyContactPage> {
  final EmergencyController emergencyController = Get.put(
    EmergencyController(),
  );
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

    return Scaffold(
      appBar: AppBar(
        title: const Text("เบอร์โทรฉุกเฉิน"),
      ),
      body: Obx(
        () => Center(
          child: ListView.builder(
            itemCount: emergencyController.contactList.length,
            itemBuilder: (context, index) => Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(jsonDecode(emergencyController
                      .contactList[index].data["avatar"])[0]["url"]),
                  backgroundColor: Colors.grey[200],
                ),
                title: Text(
                    '${Constants.title[emergencyController.contactList[index].data["title"]]} ${emergencyController.contactList[index].data["firstname"]} ${emergencyController.contactList[index].data["lastname"]}'),
                subtitle: Text(
                    emergencyController.contactList[index].data["position"]),
                trailing: GestureDetector(
                  onTap: () {
                    debugPrint('call');
                    _launchCaller(emergencyController
                        .contactList[index].data["telephone"]);
                  },
                  child: const Chip(
                    elevation: 2,
                    backgroundColor: Colors.green,
                    label: Icon(
                      Icons.call,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
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

  @override
  void initState() {
    super.initState();
    loadController();
  }

  Future<void> loadController() async {
    try {
      await Get.putAsync(() async => EmergencyController());
      setState(() {
        isLoading = false;
      });
    } catch (error) {
      setState(() {
        errorMessageController.text = 'Error: ${error.toString()}';
      });
    }
  }

  _launchCaller(String phone) async {
    var url = "tel:$phone";
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
