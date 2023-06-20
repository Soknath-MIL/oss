import 'package:flutter/material.dart';
import 'package:oss/presentation/widgets/appeal_list.dart';

class AppealListPage extends StatefulWidget {
  const AppealListPage({super.key});

  @override
  State<AppealListPage> createState() => _AppealListPageState();
}

class _AppealListPageState extends State<AppealListPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("แจ้งเรื่องร้องเรียน")),
      body: const AppealList(),
    );
  }
}
