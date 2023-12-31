import 'dart:convert';

import 'package:appwrite/appwrite.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:get/get.dart';
import 'package:oss/presentation/controllers/message_controller.dart';

import '../../constants/constants.dart';
import '../../data/services/appwrite_service.dart';

class MessageScreen extends StatefulWidget {
  const MessageScreen({super.key});

  @override
  State<MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  var title = Get.arguments[0];
  var admin = Get.arguments[1];
  final MessageConroller _messageConroller = Get.find();
  final TextEditingController _textEditingController = TextEditingController();
  RealtimeSubscription? _subscription;

  late List<types.Message> _messages = [];
  late types.User? _user;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('สนทนากับ $title'),
      ),
      body: Scaffold(
        body: Chat(
          emptyState: const Center(child: Text('ไม่พบข้อความ')),
          theme: DefaultChatTheme(
            sendingIcon: const Icon(
              Icons.send_rounded,
              color: Colors.green,
            ),
            inputBackgroundColor: Colors.grey.shade100,
            inputTextColor: Colors.green,
          ),
          messages: _messages,
          // onAttachmentPressed: _handleAttachmentPressed,
          // onMessageTap: _handleMessageTap,
          // onPreviewDataFetched: _handlePreviewDataFetched,
          onSendPressed: _handleSendPressed,
          showUserAvatars: true,
          showUserNames: true,
          user: _user!,
        ),
      ),
    );
  }

  void clearMessage() async {
    await AppwriteService().updateUser(_messageConroller.user$Id.toString(), {
      "unreadMessage":
          jsonEncode({..._messageConroller.unreadMessage, '$admin': 0})
              .toString()
    });
  }

  @override
  void dispose() {
    _subscription?.close();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    clearMessage();
    subscribe();
  }

  Future<String> subscribe() async {
    _user = types.User(
      id: _messageConroller.userId.value,
    );
    _loadMessages();

    final realtime = Realtime(Appwrite.instance.client);
    _subscription = realtime.subscribe([
      'databases.${Constants.databseId}.collections.${Constants.chatMessageCollectionId}.documents'
    ]);

    _subscription!.stream.listen((response) {
      // Callback will be executed on changes for documents A and all files.
      _loadMessages();
      // do query to update massage
    });
    return 'Initial state';
  }

  void _handleSendPressed(types.PartialText message) async {
    Map<String, dynamic> jsonMessage = {
      "author": {"id": _user!.id},
      "createdAt": DateTime.now().millisecondsSinceEpoch,
      "text": message.text,
      "senderId": _user!.id,
      "receiverId": '$admin',
    };
    // send message to server
    AppwriteService().addMessage(jsonMessage);
    AppwriteService().updateUser(
      _messageConroller.user$Id.toString(),
      {
        "adminUnreadMessage": jsonEncode({
          ..._messageConroller.adminUnreadMessage,
          admin: (_messageConroller.adminUnreadMessage[admin] ?? 0) + 1
        }),
        "lastMessage": message.text,
        "timestampMessage": DateTime.now().millisecondsSinceEpoch
      },
    );

    try {
      var exitMessageCount = await AppwriteService().getMessageCount(admin);
      AppwriteService().updateMessageCount(admin, {
        "unit_id": admin,
        "messageCount": exitMessageCount?.data["messageCount"] + 1
      });
    } catch (e) {
      AppwriteService()
          .createMessageCount(admin, {"unit_id": admin, "messageCount": 1});
    }
  }

  void _loadMessages() async {
    debugPrint('load message');
    final response = await AppwriteService().getMessage(_user!.id, '$admin');
    if (response != null) {
      List<Map<String, dynamic>> data = response.toMap()["documents"];
      final messages = data.map((e) {
        var jsonMessage = e["data"];
        jsonMessage["author"] = jsonDecode(e["data"]["author"]);
        jsonMessage["id"] = e["data"]["\$id"];
        return types.Message.fromJson(jsonMessage);
      }).toList();
      setState(() {
        _messages = messages;
      });
    }
  }
}
