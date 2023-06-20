import 'package:flutter/material.dart';
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
      body: Center(
        child: Container(
          margin: const EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IntlPhoneField(
                initialValue: '830232090',
                decoration: const InputDecoration(
                  labelText: 'หมายเลขโทรศัพท์',
                  border: OutlineInputBorder(
                    borderSide: BorderSide(),
                  ),
                ),
                initialCountryCode: 'TH',
                onChanged: (phone) {
                  print('phone number: ${phone.countryCode + phone.number}');
                  _loginController
                      .onPhoneNumberChanged(phone.countryCode + phone.number);
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  _loginController.signInWithPhoneNumber(
                      _loginController.phoneNumber.value);
                },
                child: const Text('เข้าสู่ระบบ'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
