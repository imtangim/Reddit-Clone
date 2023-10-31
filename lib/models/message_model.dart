

class MessageModel {
  final String senderUID;
  final String recieverUID;
  final String message;
  final String chatroomID;
  final DateTime sentAT;
  final String senderProfilePic;
  final String recieverProfilePic;
  MessageModel({
    required this.senderUID,
    required this.recieverUID,
    required this.message,
    required this.chatroomID,
    required this.sentAT,
    required this.senderProfilePic,
    required this.recieverProfilePic,
  });

  MessageModel copyWith({
    String? senderUID,
    String? recieverUID,
    String? message,
    String? chatroomID,
    DateTime? sentAT,
    String? senderProfilePic,
    String? recieverProfilePic,
  }) {
    return MessageModel(
      senderUID: senderUID ?? this.senderUID,
      recieverUID: recieverUID ?? this.recieverUID,
      message: message ?? this.message,
      chatroomID: chatroomID ?? this.chatroomID,
      sentAT: sentAT ?? this.sentAT,
      senderProfilePic: senderProfilePic ?? this.senderProfilePic,
      recieverProfilePic: recieverProfilePic ?? this.recieverProfilePic,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'senderUID': senderUID,
      'recieverUID': recieverUID,
      'message': message,
      'chatroomID': chatroomID,
      'sentAT': sentAT.millisecondsSinceEpoch,
      'senderProfilePic': senderProfilePic,
      'recieverProfilePic': recieverProfilePic,
    };
  }

  factory MessageModel.fromMap(Map<String, dynamic> map) {
    return MessageModel(
      senderUID: map['senderUID'] as String,
      recieverUID: map['recieverUID'] as String,
      message: map['message'] as String,
      chatroomID: map['chatroomID'] as String,
      sentAT: DateTime.fromMillisecondsSinceEpoch(map['sentAT'] as int),
      senderProfilePic: map['senderProfilePic'] as String,
      recieverProfilePic: map['recieverProfilePic'] as String,
    );
  }

  @override
  String toString() {
    return 'MessageModel(senderUID: $senderUID, recieverUID: $recieverUID, message: $message, chatroomID: $chatroomID, sentAT: $sentAT, senderProfilePic: $senderProfilePic, recieverProfilePic: $recieverProfilePic)';
  }

  @override
  bool operator ==(covariant MessageModel other) {
    if (identical(this, other)) return true;

    return other.senderUID == senderUID &&
        other.recieverUID == recieverUID &&
        other.message == message &&
        other.chatroomID == chatroomID &&
        other.sentAT == sentAT &&
        other.senderProfilePic == senderProfilePic &&
        other.recieverProfilePic == recieverProfilePic;
  }

  @override
  int get hashCode {
    return senderUID.hashCode ^
        recieverUID.hashCode ^
        message.hashCode ^
        chatroomID.hashCode ^
        sentAT.hashCode ^
        senderProfilePic.hashCode ^
        recieverProfilePic.hashCode;
  }
}
