import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class MaintenanceWidget extends StatefulWidget {
  final String label;
  const MaintenanceWidget({super.key, required this.label});

  @override
  State<MaintenanceWidget> createState() => _MaintenanceWidgetState();
}

class _MaintenanceWidgetState extends State<MaintenanceWidget> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Iconsax.setting_4,
              size: 40,
              color: Colors.green,
            ),
            const SizedBox(
              height: 10,
            ),
            Text(
              widget.label,
              style: const TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
