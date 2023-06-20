class MessageModel {
  final String sender;
  final String message;
  final int timestamp;

  MessageModel(
      {required this.sender, required this.message, required this.timestamp});

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      sender: json['sender'],
      message: json['message'],
      timestamp: json['timestamp'],
    );
  }
}
