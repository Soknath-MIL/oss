import 'package:appwrite/appwrite.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:oss/constants/constants.dart';

import '../../data/services/appwrite_service.dart';

class PoisController extends GetxController with StateMixin {
  final Account account = Account(Appwrite.instance.client);
  final Databases database = Databases(Appwrite.instance.client);
  final poisList = [].obs;
  final hotelList = [].obs;
  final foodList = [].obs;
  final factoryList = [].obs;
  final shoppingList = [].obs;
  final touristList = [].obs;

  Future<void> getAllPois() async {
    try {
      change(null, status: RxStatus.loading());

      var allPoisList = await database.listDocuments(
        databaseId: Constants.databseId,
        collectionId: Constants.poiId,
        queries: [Query.orderAsc("distance")],
      ); // add group ID filter
      // debugPrint(allPoisList.documents[0].data.toString());
      var poisAllList = allPoisList.documents;
      var hotelAllList = allPoisList.documents
          .where((i) => i.data["type"] == "hotel")
          .toList();
      var foodAllList =
          allPoisList.documents.where((i) => i.data["type"] == "food").toList();
      var shoppingAllList = allPoisList.documents
          .where((i) => i.data["type"] == "shopping")
          .toList();
      var factoryAllList = allPoisList.documents
          .where((i) => i.data["type"] == "factory")
          .toList();
      var touristAllList = allPoisList.documents
          .where((i) => i.data["type"] == "tourist")
          .toList();
      poisList.value = poisAllList;
      hotelList.value = hotelAllList;
      foodList.value = foodAllList;
      shoppingList.value = shoppingAllList;
      factoryList.value = factoryAllList;
      touristList.value = touristAllList;
      poisList.refresh();
      hotelList.refresh();
      foodList.refresh();
      shoppingList.refresh();
      factoryList.refresh();
      touristList.refresh();

      // if done, change status to success
      change(null, status: RxStatus.success());
    } catch (e) {
      debugPrint('error ${e.toString()}');
      // Get.toNamed('/login');
    }
  }

  @override
  void onInit() {
    getAllPois();
    super.onInit();
  }
}
