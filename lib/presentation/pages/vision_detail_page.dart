import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class VisionDetailPage extends StatefulWidget {
  const VisionDetailPage({super.key});

  @override
  State<VisionDetailPage> createState() => _VisionDetailPageState();
}

class _VisionDetailPageState extends State<VisionDetailPage> {
  final Map<String, dynamic> vision = Get.arguments[0];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          vision["type"],
        ),
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            height: 200,
            margin: const EdgeInsets.all(10),
            child: ClipRRect(
              borderRadius:
                  BorderRadius.circular(10.0), // Set the desired border radius
              child: ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(20)),
                child: CachedNetworkImage(
                  imageUrl: jsonDecode(vision["image"])[0]
                      ["url"], // Replace with your image URL
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  vision["type"],
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                Text(
                  DateFormat.yMMMMEEEEd('th')
                      .format(DateTime.parse(vision["\$createdAt"]).toLocal()),
                  style: const TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.only(top: 20, left: 10, right: 10),
            child: Text(
              vision['detail'],
              textAlign: TextAlign.justify,
              style: const TextStyle(fontWeight: FontWeight.w400),
            ),
          )
        ],
      ),
    );
  }
}
