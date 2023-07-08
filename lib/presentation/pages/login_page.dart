import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl_phone_field/countries.dart';
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
                countries: const [
                  Country(
                    name: "Thailand",
                    nameTranslations: {
                      "sk": "Thajsko",
                      "se": "Thaieana",
                      "pl": "Tajlandia",
                      "no": "Thailand",
                      "ja": "タイ",
                      "it": "Thailandia",
                      "zh": "泰国",
                      "nl": "Thailand",
                      "de": "Thailand",
                      "fr": "Thaïlande",
                      "es": "Tailandia",
                      "en": "Thailand",
                      "pt_BR": "Tailândia",
                      "sr-Cyrl": "Тајланд",
                      "sr-Latn": "Tajland",
                      "zh_TW": "泰國",
                      "tr": "Tayland",
                      "ro": "Tailanda",
                      "ar": "تايلاند",
                      "fa": "تایلند",
                      "yue": "泰國"
                    },
                    flag: "🇹🇭",
                    code: "TH",
                    dialCode: "66",
                    minLength: 9,
                    maxLength: 9,
                  ),
                ],
                initialValue: '830232090',
                onTap: () {},
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
                  await _loginController.signInWithPhoneNumber(
                    _loginController.phoneNumber.value,
                  );
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
