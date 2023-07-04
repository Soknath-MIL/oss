import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class EmptyWidget extends StatelessWidget {
  const EmptyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        Icon(
          Iconsax.empty_wallet,
          size: 30,
        ),
        SizedBox(
          height: 10,
        ),
        Text(
          'ไม่พบข้อมูล',
          style: TextStyle(fontSize: 16),
        ),
      ],
    ));
  }
}
