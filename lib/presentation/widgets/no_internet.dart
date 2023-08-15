import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class NoInternetConnection extends StatelessWidget {
  const NoInternetConnection({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'No Internet Connection',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(
              height: 10,
            ),
            const Icon(
              Iconsax.warning_2,
              size: 60,
            ),
            const SizedBox(
              height: 16,
            ),
            FloatingActionButton.extended(
                onPressed: () {
                  Get.offAllNamed("/main");
                },
                label: const Text("ลองใหม่"))
          ],
        ),
      ),
    );
  }
}
