import 'package:flutter/foundation.dart';

class UserModel {
  final String name;
  final String profilepic;
  final String banner;
  final String uid;
  final bool isAuthenticated; //if guest or not
  final int karma;
  final List<String> awards;

  //constructer
  UserModel({
    required this.name,
    required this.profilepic,
    required this.banner,
    required this.uid,
    required this.isAuthenticated,
    required this.karma,
    required this.awards,
  });

  //return user profile to override the value, because they are final
  UserModel copyWith({
    String? name,
    String? profilepic,
    String? banner,
    String? uid,
    bool? isAuthenticated,
    int? karma,
    List<String>? awards,
  }) {
    return UserModel(
      name: name ?? this.name,
      profilepic: profilepic ?? this.profilepic,
      banner: banner ?? this.banner,
      uid: uid ?? this.uid,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      karma: karma ?? this.karma,
      awards: awards ?? this.awards,
    );
  }

  //making a map to send data firebase
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'profilepic': profilepic,
      'banner': banner,
      'uid': uid,
      'isAuthenticated': isAuthenticated,
      'karma': karma,
      'awards': awards,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
        name: map['name'] as String,
        profilepic: map['profilepic'] as String,
        banner: map['banner'] as String,
        uid: map['uid'] as String,
        isAuthenticated: map['isAuthenticated'] as bool,
        karma: map['karma'] as int,
        awards: List<String>.from(
          (map['awards'] as List<dynamic>),
        ));
  }
  //usermodel.toString(); result = UserModel(name: $name, profilepic: $profilepic, banner: $banner, uid: $uid, isAuthenticated: $isAuthenticated, karma: $karma, awards: $awards)
  @override
  String toString() {
    return 'UserModel(name: $name, profilepic: $profilepic, banner: $banner, uid: $uid, isAuthenticated: $isAuthenticated, karma: $karma, awards: $awards)';
  }

  @override
  bool operator ==(covariant UserModel other) {
    if (identical(this, other)) return true;

    return other.name == name &&
        other.profilepic == profilepic &&
        other.banner == banner &&
        other.uid == uid &&
        other.isAuthenticated == isAuthenticated &&
        other.karma == karma &&
        listEquals(other.awards, awards);
  }

  @override
  int get hashCode {
    return name.hashCode ^
        profilepic.hashCode ^
        banner.hashCode ^
        uid.hashCode ^
        isAuthenticated.hashCode ^
        karma.hashCode ^
        awards.hashCode;
  }
}
