

class Comments {
  final String id;
  final String text;
  final DateTime createAt;
  final String postID;
  final String username;
  final String profilepic;
  final String uid;
  Comments({
    required this.id,
    required this.text,
    required this.createAt,
    required this.postID,
    required this.username,
    required this.profilepic,
    required this.uid,
  });

  Comments copyWith({
    String? id,
    String? text,
    DateTime? createAt,
    String? postID,
    String? username,
    String? profilepic,
    String? uid,
  }) {
    return Comments(
      id: id ?? this.id,
      text: text ?? this.text,
      createAt: createAt ?? this.createAt,
      postID: postID ?? this.postID,
      username: username ?? this.username,
      profilepic: profilepic ?? this.profilepic,
      uid: uid ?? this.uid,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'text': text,
      'createAt': createAt.millisecondsSinceEpoch,
      'postID': postID,
      'username': username,
      'profilepic': profilepic,
      'uid': uid,
    };
  }

  factory Comments.fromMap(Map<String, dynamic> map) {
    return Comments(
      id: map['id'] as String,
      text: map['text'] as String,
      createAt: DateTime.fromMillisecondsSinceEpoch(map['createAt'] as int),
      postID: map['postID'] as String,
      username: map['username'] as String,
      profilepic: map['profilepic'] as String,
      uid: map['uid'] as String,
    );
  }

  @override
  String toString() {
    return 'Comments(id: $id, text: $text, createAt: $createAt, postID: $postID, username: $username, profilepic: $profilepic, uid: $uid)';
  }

  @override
  bool operator ==(covariant Comments other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.text == text &&
        other.createAt == createAt &&
        other.postID == postID &&
        other.username == username &&
        other.profilepic == profilepic &&
        other.uid == uid;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        text.hashCode ^
        createAt.hashCode ^
        postID.hashCode ^
        username.hashCode ^
        profilepic.hashCode ^
        uid.hashCode;
  }
}
