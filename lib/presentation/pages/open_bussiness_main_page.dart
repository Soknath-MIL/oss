import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:oss/presentation/pages/con_business_request_form.dart';
import 'package:oss/presentation/pages/open_business_request_form.dart';

import '../../constants/constants.dart';

class OpenBusiness extends StatefulWidget {
  const OpenBusiness({super.key});

  @override
  State<OpenBusiness> createState() => _OpenBusinessState();
}

class _OpenBusinessState extends State<OpenBusiness> {
  final _formKey = GlobalKey<FormBuilderState>();
  String type = 'แบบคำขอรับใบอนุญาต';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ขอรับใบอนุญาต'),
      ),
      body: Container(
        margin: const EdgeInsets.all(16),
        child: FormBuilder(
          key: _formKey,
          initialValue: const {'type': 'แบบคำขอรับใบอนุญาต'},
          child: ListView(
            children: [
              const SizedBox(height: 10),
              SizedBox(
                height: 60,
                child: FormBuilderDropdown<String>(
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                  name: 'type',
                  decoration: customInputDecoration('ประเภทคำขอ'),
                  validator: FormBuilderValidators.required(),
                  items: Constants.openBusinessType
                      .map((item) => DropdownMenuItem(
                            alignment: AlignmentDirectional.centerStart,
                            value: item["name"],
                            child: Text(item["value"].toString()),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      type = value!;
                    });
                  },
                  valueTransformer: (val) => val?.toString(),
                ),
              ),
              type == "แบบคำขอรับใบอนุญาต"
                  ? SizedBox(
                      height: MediaQuery.of(context).size.height - 200,
                      child: const OpenBusinessRequestPage(),
                    )
                  : Container(),
              type == "แบบคำขอต่อใบอนุญาต"
                  ? SizedBox(
                      height: MediaQuery.of(context).size.height - 200,
                      child: const ContinueBusinessRequestPage(),
                    )
                  : Container(),
            ],
          ),
        ),
      ),
    );
  }

  customInputDecoration(label) {
    return InputDecoration(
      contentPadding: const EdgeInsets.all(10),
      isDense: true,
      border: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.grey),
        borderRadius: BorderRadius.circular(8.0),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.blue),
        borderRadius: BorderRadius.circular(8.0),
      ),
      labelText: label,
    );
  }
}
