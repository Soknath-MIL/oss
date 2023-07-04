import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:get/get.dart';
import 'package:oss/data/services/appwrite_service.dart';
import 'package:thai_id_card_numbers/thai_id_card_numbers.dart';
import 'package:thai_id_card_numbers/thai_id_card_numbers_formatter.dart';

// ignore: must_be_immutable
class ValidateSccount extends StatefulWidget {
  const ValidateSccount({super.key});

  @override
  State<ValidateSccount> createState() => _ValidateSccountState();
}

class _ValidateSccountState extends State<ValidateSccount> {
  final _formKey = GlobalKey<FormBuilderState>();
  final bool userExist = false;
  String pattern = "x-xxxx-xxxxx-xx-x";
  String separator = "-";
  final _thaiIdCardNumbers = ThaiIdCardNumbers();

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
      body: SafeArea(
        child: SingleChildScrollView(
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(
                  height: 80,
                ),
                Image.asset('assets/logo.png'),
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'กรุณาป้อนข้อมูลเริ่มต้นสำหรับกระบวนการลงทะเบียน',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: FormBuilder(
                    key: _formKey,
                    // autovalidateMode: AutovalidateMode.onUserInteraction,
                    child: Column(
                      children: [
                        FormBuilderTextField(
                          name: 'nationalId',
                          style: const TextStyle(color: Colors.white),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            ThaiIdCardNumbersFormatter(
                                pattern: pattern, delimiter: separator),
                          ],
                          decoration: customInputDecoration(
                              'เลขประจำตัวประชาชน', "1-2345-67891-01-2"),
                          // validator: FormBuilderValidators.compose([
                          //   FormBuilderValidators.required(),
                          //   FormBuilderValidators.minLength(13),
                          //   FormBuilderValidators.maxLength(13),
                          // ]),

                          validator: (String? value) {
                            String? newValue =
                                value?.replaceAll(RegExp('-'), '');
                            if (!_thaiIdCardNumbers.validate(newValue!)) {
                              return "$value ไม่ใช่หมายเลขบัตรประจำตัวไทยที่ถูกต้อง";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 10),
                        FormBuilderTextField(
                          name: 'full_name',
                          style: const TextStyle(color: Colors.white),
                          decoration: customInputDecoration(
                              'ชื่อ-นามสกุล', "ชื่อ-นามสกุล"),
                          validator: FormBuilderValidators.compose([
                            FormBuilderValidators.required(),
                          ]),
                        ),
                        const SizedBox(height: 10),
                        MaterialButton(
                          shape: const StadiumBorder(),
                          color: Theme.of(context).colorScheme.secondary,
                          onPressed: () async {
                            if (_formKey.currentState?.saveAndValidate() ??
                                false) {
                              await EasyLoading.show(
                                status: 'กำลังโหลด...',
                                maskType: EasyLoadingMaskType.black,
                              );
                              await AppwriteService().createUser(
                                int.parse(
                                    _formKey.currentState?.value["nationalId"]),
                                _formKey.currentState?.value["full_name"],
                              );
                              await EasyLoading.dismiss();

                              Get.toNamed('/main');
                            } else {
                              debugPrint('Invalid');
                            }
                            // debugPrint(_formKey.currentState?.value.toString());
                          },
                          child: const Text('ตรวจสอบบัญชี',
                              style: TextStyle(color: Colors.white)),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  customInputDecoration(label, hint) {
    return InputDecoration(
      border: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.white),
        borderRadius: BorderRadius.circular(16.0),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.white),
        borderRadius: BorderRadius.circular(16.0),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.white),
        borderRadius: BorderRadius.circular(16.0),
      ),
      hintText: hint,
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white),
      hintStyle: const TextStyle(color: Colors.white),
    );
  }
}
