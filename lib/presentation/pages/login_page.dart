import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

import '../controllers/login_controller.dart';

class LoginPage extends StatelessWidget {
  final LoginController _loginController = Get.put(LoginController());
  LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        heroTag: 'to_home_1',
        onPressed: () {
          Get.toNamed('/main', arguments: [0]);
        },
        child: const Icon(Icons.home),
      ),
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: const Alignment(1, 1),
              colors: <Color>[
                const Color(0xff29991F),
                Colors.grey.shade500,
              ],
              tileMode: TileMode.clamp,
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const SizedBox(
                height: 80,
              ),
              Image.asset('assets/logo.png'),
              const SizedBox(
                height: 20,
              ),
              const Text(
                'กรุณาป้อนหมายเลขโทรศัพท์เพื่อรับข้อความ OTP',
                style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: Colors.white),
              ),
              const SizedBox(
                height: 40,
              ),
              IntlPhoneField(
                disableLengthCheck: true,
                initialValue: '830232090',
                decoration: InputDecoration(
                  labelText: 'หมายเลขโทรศัพท์',
                  labelStyle: const TextStyle(color: Colors.white),
                  border: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.white),
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                ),
                initialCountryCode: 'TH',
                onChanged: (phone) {
                  _loginController
                      .onPhoneNumberChanged(phone.countryCode + phone.number);
                },
              ),
              const SizedBox(height: 16),
              MaterialButton(
                shape: const StadiumBorder(),
                color: Theme.of(context).colorScheme.secondary,
                onPressed: () async {
                  await EasyLoading.show(
                    status: 'กำลังโหลด...',
                    maskType: EasyLoadingMaskType.black,
                  );
                  await _loginController.signInWithPhoneNumber(
                    _loginController.phoneNumber.value,
                  );
                  await EasyLoading.dismiss();
                },
                child: const Text(
                  'เข้าสู่ระบบ',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
