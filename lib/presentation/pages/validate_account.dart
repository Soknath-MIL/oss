import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:get/get.dart';
import 'package:oss/data/services/appwrite_service.dart';

// ignore: must_be_immutable
class ValidateSccount extends StatefulWidget {
  const ValidateSccount({super.key});

  @override
  State<ValidateSccount> createState() => _ValidateSccountState();
}

class _ValidateSccountState extends State<ValidateSccount> {
  final _formKey = GlobalKey<FormBuilderState>();
  final bool userExist = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: FormBuilder(
              key: _formKey,
              // autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
                children: [
                  FormBuilderTextField(
                    name: 'nationalId',
                    keyboardType: TextInputType.number,
                    decoration: customInputDecoration('เลขประจำตัวประชาชน'),
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(),
                      FormBuilderValidators.minLength(13),
                      FormBuilderValidators.maxLength(13),
                    ]),
                  ),
                  const SizedBox(height: 10),
                  const SizedBox(height: 20),
                  FormBuilderTextField(
                    name: 'full_name',
                    decoration: customInputDecoration('ชื่อ-นามสกุล'),
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(),
                    ]),
                  ),
                  const SizedBox(height: 10),
                  MaterialButton(
                    color: Theme.of(context).colorScheme.secondary,
                    onPressed: () async {
                      if (_formKey.currentState?.saveAndValidate() ?? false) {
                        await EasyLoading.show(
                          status: 'กำลังโหลด...',
                          maskType: EasyLoadingMaskType.black,
                        );
                        await AppwriteService().createUser(
                          int.parse(_formKey.currentState?.value["nationalId"]),
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
        ),
      ),
    );
  }

  customInputDecoration(label) {
    return InputDecoration(
      border: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.grey),
        borderRadius: BorderRadius.circular(8.0),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.blue),
        borderRadius: BorderRadius.circular(8.0),
      ),
      hintText: label,
      labelText: label,
    );
  }
}
