import 'dart:convert';

import 'package:appwrite/appwrite.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:oss/data/services/appwrite_service.dart';
import 'package:oss/presentation/pages/notification_page.dart';
import 'package:oss/presentation/pages/profile_page.dart';
import 'package:oss/presentation/pages/unit_chat_page.dart';
import 'package:overlay_support/overlay_support.dart';

import '../../constants/constants.dart';
import '../controllers/config_controller.dart';
import '../controllers/message_controller.dart';
import '../models/push_notification.dart';
import '../widgets/appeal_list.dart';
import 'home_page.dart';

const storage = FlutterSecureStorage();

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Handling a background message: ${message.messageId}");
  // save unread meesage count
  String unreadNoti = await storage.read(key: 'notiCount') ?? "";
  storage.write(
    key: 'notiCount',
    value: (int.parse(unreadNoti) + 1).toString(),
  );
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with WidgetsBindingObserver {
  final GlobalKey<ConvexAppBarState> _appBarKey =
      GlobalKey<ConvexAppBarState>();
  final MessageConroller _messageConroller = Get.put(MessageConroller());
  final ConfigController configController = Get.put(ConfigController());
  int currentIndex = 0;
  int unreadMessage = 0;
  String notiCount = "";
  RealtimeSubscription? _subscription;
  // Notification
  late final FirebaseMessaging _messaging;

  PushNotification? _notificationInfo;

  @override
  Widget build(BuildContext context) {
    List<Widget> pages = <Widget>[
      const HomeScreen(),
      const UnitSelectionPage(),
      const AppealList(),
      NotificationsPage(clearNotification: () async {
        await storage.write(key: "notiCount", value: "");
        setState(() {
          notiCount = "";
        });
      }),
      ProfilePage(onLogoutPressed: (index) {
        setState(() {
          currentIndex = index;
        });
        _appBarKey.currentState?.animateTo(index);
      })
    ];
    return configController.obx((state) {
      var maintenance = configController.configList.where((item) {
        return item.data["name"] == 'maintenance';
      }).toList();

      if (maintenance[0].data["value"].split("|")[0] == 'true') {
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
                  maintenance[0].data["value"].split("|")[1] ??
                      "ภายใต้การบำรุงรักษา",
                  style: const TextStyle(fontSize: 18),
                ),
              ],
            ),
          ),
        );
      }
      return Scaffold(
        body: pages[currentIndex],
        bottomNavigationBar: ConvexAppBar.badge(
          {
            1: unreadMessage != 0 ? '$unreadMessage' : '',
            3: notiCount,
          },
          height: 55,
          key: _appBarKey,
          badgeMargin: const EdgeInsets.only(bottom: 30, left: 30),
          style: TabStyle.react,
          backgroundColor: Colors.green,
          items: const [
            TabItem(icon: Iconsax.category, title: "หน้าแรก"),
            TabItem(icon: Iconsax.message, title: "คุยกับเรา"),
            TabItem(icon: Iconsax.info_circle, title: "แจ้งเหตุ"),
            TabItem(icon: Iconsax.notification, title: "แจ้งเตือน"),
            TabItem(icon: Iconsax.textalign_left, title: "อื่นๆ"),
          ],
          initialActiveIndex: currentIndex,
          onTap: (int i) {
            setState(() {
              currentIndex = i;
            });
          },
        ),
      );
    });
  }

  // For handling notification when the app is in terminated state
  checkForInitialMessage() async {
    await Firebase.initializeApp();
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();

    if (initialMessage != null) {
      PushNotification notification = PushNotification(
        title: initialMessage.notification?.title,
        body: initialMessage.notification?.body,
        dataTitle: initialMessage.data['title'],
        dataBody: initialMessage.data['body'],
      );

      setState(() {
        _notificationInfo = notification;
      });
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    debugPrint(state.toString());
    String? userID = await storage.read(key: 'userID');

    if (userID != null) {
      if (state == AppLifecycleState.resumed) {
        getNotiCount();
        AppwriteService().setOnline(userID, true);
      } else {
        AppwriteService().setOnline(userID, false);
      }
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    AppwriteService().makeOnline(false);
    WidgetsBinding.instance.removeObserver(this);
    _subscription!.close();
  }

  void getNotiCount() async {
    var totalNoti = await storage.read(key: 'notiCount') ?? "";
    setState(() {
      notiCount = totalNoti;
    });
  }

  void getUnreadMessage() async {
    String? userID = await storage.read(key: 'userID');
    if (userID != null) {
      final database = Databases(Appwrite.instance.client);
      try {
        var user = await database.getDocument(
          databaseId: Constants.databseId,
          collectionId: Constants.userId,
          documentId: userID,
        );

        var total = 0;
        jsonDecode(user.data["unreadMessage"]).forEach((key, val) {
          total += val as int;
        });

        setState(() {
          unreadMessage = total;
        });
        debugPrint('admin message ${user.data["adminUnreadMessage"]}');
        _messageConroller.adminUnreadMessage.value =
            jsonDecode(user.data["adminUnreadMessage"]);
      } catch (e) {
        debugPrint('erro load unread message: ${e.toString()}');
      }
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    AppwriteService().makeOnline(true);
    WidgetsBinding.instance.addObserver(this);
    getUnreadMessage();
    getNotiCount();

    final realtime = Realtime(Appwrite.instance.client);
    _subscription = realtime.subscribe([
      'databases.${Constants.databseId}.collections.${Constants.userId}.documents'
    ]);

    _subscription!.stream.listen((response) async {
      // Callback will be executed on changes for documents A and all files.
      String? userID = await storage.read(key: 'userID');
      if (response.payload["\$id"] == userID!) {
        getUnreadMessage();
      }
      // do query to update massage
    });

    // Notification

    registerNotification();
    checkForInitialMessage();

    // For handling notification when the app is in background
    // but not terminated
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
      print("Handling onMessageOpenedApp message: ${message.messageId}");
      // save unread meesage count
      String unreadNoti = await storage.read(key: 'notiCount') ?? "";
      setState(() {
        notiCount = unreadNoti;
      });

      PushNotification notification = PushNotification(
        title: message.notification?.title,
        body: message.notification?.body,
        dataTitle: message.data['title'],
        dataBody: message.data['body'],
      );

      setState(() {
        _notificationInfo = notification;
      });
    });
  }

  void registerNotification() async {
    await Firebase.initializeApp();
    _messaging = FirebaseMessaging.instance;
    var token = await _messaging.getToken();
    var fcmOnline = await _messageConroller.accountData["fcm"];
    var userID = await storage.read(key: 'userID');
    if (token != fcmOnline) {
      // update token
      await AppwriteService().updateUser(userID, {"fcm": token});
      storage.write(key: 'fcm', value: token);
    }

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');

      FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
        print("Handling onMessage message: ${message.messageId}");
        // save unread meesage count
        String unreadNoti = await storage.read(key: 'notiCount') ?? "0";
        debugPrint('unreadNoti ${unreadNoti.toString() == ""}');
        storage.write(
            key: 'notiCount',
            value: (int.parse(unreadNoti.toString() == ""
                        ? "0"
                        : unreadNoti.toString()) +
                    1)
                .toString());
        setState(() {
          notiCount = (int.parse(unreadNoti.toString() == ""
                      ? "0"
                      : unreadNoti.toString()) +
                  1)
              .toString();
        });

        // Parse the message received
        PushNotification notification = PushNotification(
          title: message.notification?.title,
          body: message.notification?.body,
          dataTitle: message.data['title'],
          dataBody: message.data['body'],
        );

        setState(() {
          _notificationInfo = notification;
        });

        if (_notificationInfo != null) {
          // For displaying the notification as an overlay
          showSimpleNotification(
            Text(_notificationInfo!.title!),
            subtitle: Text(_notificationInfo!.body!),
            background: Colors.cyan.shade700,
            duration: const Duration(seconds: 2),
          );
        }
      });
    } else {
      print('User declined or has not accepted permission');
    }
  }

  void _onItemTapped(index) {
    setState(() {
      currentIndex = index;
    });
  }
}
