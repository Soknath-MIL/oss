import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class NewsDetailPage extends StatefulWidget {
  const NewsDetailPage({super.key});

  @override
  State<NewsDetailPage> createState() => _NewsDetailPageState();
}

class _NewsDetailPageState extends State<NewsDetailPage> {
  final Map<String, dynamic> news = Get.arguments[0];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('รายละเอียดข่าว')),
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
                imageUrl: jsonDecode(news["images"])[0]
                    ["url"], // Replace with your image URL
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(top: 20, left: 10, right: 10),
            child: Text(
              news["title"],
              textAlign: TextAlign.start,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(right: 10),
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                DateFormat.yMMMMEEEEd('th')
                    .format(DateTime.parse(news["\$createdAt"]).toLocal()),
                textAlign: TextAlign.end,
                style: const TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(top: 20, left: 10, right: 10),
            child: Text(
              news['content'],
              textAlign: TextAlign.justify,
              style: const TextStyle(fontWeight: FontWeight.w400),
            ),
          )
        ],
      ),
    );
  }
}
