import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class NotificationDetailPage extends StatefulWidget {
  const NotificationDetailPage({super.key});

  @override
  State<NotificationDetailPage> createState() => _NotificationDetailPageState();
}

class _NotificationDetailPageState extends State<NotificationDetailPage> {
  final Map<String, dynamic> news = Get.arguments[0];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('รายละเอียดการแจ้งเตือน')),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            height: 200,
            margin: const EdgeInsets.all(10),
            child: ClipRRect(
              borderRadius:
                  BorderRadius.circular(10.0), // Set the desired border radius
              child: CachedNetworkImage(
                imageUrl: jsonDecode(
                    news["images"][0])["url"], // Replace with your image URL
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      news["title"],
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    // Text(
                    //   news["subTitle"],
                    //   style: const TextStyle(fontWeight: FontWeight.w300),
                    // ),
                  ],
                ),
                Text(
                  DateFormat.yMMMMEEEEd('th')
                      .format(DateTime.parse(news["subTitle"]).toLocal()),
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
              news['detail'],
              textAlign: TextAlign.justify,
              style: const TextStyle(fontWeight: FontWeight.w400),
            ),
          )
        ],
      ),
    );
  }
}
