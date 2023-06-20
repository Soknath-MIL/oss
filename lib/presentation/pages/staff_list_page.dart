import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:oss/presentation/controllers/mngt_controller.dart';
import 'package:oss/presentation/widgets/profile_card.dart';

class StaffListPage extends StatefulWidget {
  const StaffListPage({super.key});

  @override
  State<StaffListPage> createState() => _StaffListPageState();
}

class _StaffListPageState extends State<StaffListPage> {
  final ManagementController mngtConroller = Get.put(ManagementController());
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
        title: const Text('คณะผู้บริหาร'),
      ),
      body: Obx(() {
        return ListView.builder(
          itemCount: mngtConroller.mngtList.length,
          itemBuilder: (ctx, i) =>
              ProfileCard(person: mngtConroller.mngtList[i].data),
        );
      }),
    );
  }

  @override
  void dispose() {
    errorMessageController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadController();
  }

  Future<void> loadController() async {
    try {
      await Get.putAsync(() async => mngtConroller);
      setState(() {
        isLoading = false;
      });
    } catch (error) {
      setState(() {
        errorMessageController.text = 'Error: ${error.toString()}';
      });
    }
  }
}
