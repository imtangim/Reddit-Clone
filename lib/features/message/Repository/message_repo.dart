import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:reddit_clone/core/Constant/firebase_constant.dart';
import 'package:reddit_clone/core/failure.dart';
import 'package:reddit_clone/core/providers/firebase_provider.dart';
import 'package:reddit_clone/models/message_model.dart';

import '../../../core/typedef.dart';

final userMessageProvider = Provider(
  (ref) => UserMessageRepository(firestore: ref.watch(fireStoreProvider)),
);

class UserMessageRepository {
  final FirebaseFirestore _firestore;

  UserMessageRepository({required FirebaseFirestore firestore})
      : _firestore = firestore;

  CollectionReference get _message =>
      _firestore.collection(FirebaseConstant.messageCollection);

  Futurevoid sendMessage(MessageModel message, String chatroomID) async {
    try {
      return right(
        // ignore: void_checks
        await _message.doc(chatroomID).collection('messages').add(
              message.toMap(),
            ),
      );
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  Stream<List<MessageModel>> getMessages(String userID, String otherUserID) {
    //construct a chatroom id from currentUser id and reciever id (sorted to ensure uniqueness)
    List<String> ids = [userID, otherUserID];

    ids.sort(); //sort the ids( this ensure the chat room id is always same for any pair of people)
    String chatRoomId = ids.join("_");

    // print(
    //     "Data: ${_firestore.collection("chat_rooms").doc(chatRoomId).collection('messages').doc().snapshots()}");

    return _message
        .doc(chatRoomId)
        .collection('messages')
        .orderBy("sentAT", descending: true)
        .snapshots()
        .map(
          (event) => event.docs
              .map(
                (e) => MessageModel.fromMap(
                  e.data(),
                ),
              )
              .toList(),
        );
  }

  deleteMessagesForChatroom(MessageModel messageModel) async {
    try {
      _message
          .doc(messageModel.chatroomID)
          .collection('messages')
          .get()
          .then((querySnapshot) {
        for (var doc in querySnapshot.docs) {
          doc.reference.delete();
        }
      });

      right(true);
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  Stream<List<MessageModel>> getMessagesBySenderUID(String senderUID) {
    return FirebaseFirestore.instance
        .collectionGroup('messages')
        .where('senderUID', isEqualTo: senderUID)
        .orderBy("sentAT", descending: false)
        .snapshots()
        .map(
          (event) => event.docs
              .map(
                (e) => MessageModel.fromMap(
                  e.data(),
                ),
              )
              .toList(),
        );
  }
}
