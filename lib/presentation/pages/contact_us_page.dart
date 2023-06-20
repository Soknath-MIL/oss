import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:oss/presentation/controllers/contact_us_controller.dart';

import '../../utils/map_utils.dart';
import '../widgets/full_map.dart';

class ContactUsPage extends StatefulWidget {
  const ContactUsPage({super.key});

  @override
  State<ContactUsPage> createState() => _ContactUsPageState();
}

class _ContactUsPageState extends State<ContactUsPage> {
  final ContactUsController contactUsController = Get.put(
    ContactUsController(),
  );

  @override
  Widget build(BuildContext context) {
    return contactUsController.obx(
      (state) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('ติดต่อเรา'),
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(20.0)),
                    child: Image.asset(
                      "./assets/images/contact-us.png",
                      fit: BoxFit.fitWidth,
                    ),
                  ),
                ),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(8),
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: const BoxDecoration(
                    color: Colors.greenAccent,
                  ),
                  child: Obx(
                    () => Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${contactUsController.contactsList[0].data["address"]} ${contactUsController.contactsList[0].data["tambon"]} ${contactUsController.contactsList[0].data["amphoe"]} ${contactUsController.contactsList[0].data["province"]} ${contactUsController.contactsList[0].data["postcode"]} ',
                          style: const TextStyle(fontSize: 12),
                        ),
                        Text(
                          'โทรศัพท์ : ${contactUsController.contactsList[0].data["phone"]}',
                          style: const TextStyle(fontSize: 12),
                        ),
                        Text(
                          'โทรสาร : ${contactUsController.contactsList[0].data["fax"]}',
                          style: const TextStyle(fontSize: 12),
                        ),
                        Text(
                          'Email : ${contactUsController.contactsList[0].data["email"]}',
                          style: const TextStyle(fontSize: 12),
                        ),
                        Text(
                          'Website : ${contactUsController.contactsList[0].data["website"]}',
                          style: const TextStyle(fontSize: 12),
                        )
                      ],
                    ),
                  ),
                ),
                Container(
                  height: 350,
                  margin: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(
                      Radius.circular(
                        10,
                      ),
                    ),
                  ),
                  child: Obx(
                    () => FullMap(
                        lat: contactUsController
                            .contactsList[0].data["latitude"],
                        lng: contactUsController
                            .contactsList[0].data["longitude"],
                        label: "ที่ตั้ง ตำบล"),
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: BottomAppBar(
            child: GestureDetector(
              onTap: () {
                // GO TO Navigation
                MapUtils.openMap(
                  double.parse(
                      contactUsController.contactsList[0].data["latitude"]),
                  double.parse(
                    contactUsController.contactsList[0].data["longitude"],
                  ),
                );
              },
              child: Container(
                height: 40.0,
                color: Colors.green,
                child: const Center(
                    child: Text(
                  "นำทาง",
                  style: TextStyle(color: Colors.white),
                )),
              ),
            ),
          ),
        );
      },
      onLoading: const Center(child: CircularProgressIndicator()),
    );
  }
}
