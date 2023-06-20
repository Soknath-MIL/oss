import 'dart:convert';

import 'package:flutter/material.dart';

import '../../constants/constants.dart';

// ignore: must_be_immutable
class ProfileCard extends StatelessWidget {
  Map<String, dynamic> person;
  ProfileCard({super.key, required this.person});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 140.0,
      margin: const EdgeInsets.only(top: 10.0, left: 10, right: 10),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 0.5,
            blurRadius: 3,
            offset: const Offset(0, 1), // changes position of shadow
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 30.0,
            backgroundImage: NetworkImage(
              jsonDecode(person["avatar"])[0]["url"],
            ),
            backgroundColor: Colors.transparent,
          ),
          const SizedBox(
            width: 30,
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${Constants.title[person["title"]]} ${person["firstname"]} ${person["lastname"]}',
                style: const TextStyle(
                  fontSize: 14.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${person["position"]}',
                style: const TextStyle(
                  fontSize: 12.0,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 4.0),
              _buildContactInfo(Icons.email, '${person["email"]}'),
              const SizedBox(height: 4.0),
              _buildContactInfo(Icons.phone, '${person["phone"]}'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContactInfo(IconData icon, String text) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon),
        const SizedBox(width: 8.0),
        Text(text),
      ],
    );
  }
}
