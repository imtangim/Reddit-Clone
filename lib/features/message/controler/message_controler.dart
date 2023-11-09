import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:reddit_clone/core/util.dart';
import 'package:reddit_clone/features/auth/controler/auth_controler.dart';
import 'package:reddit_clone/features/message/Repository/message_repo.dart';
import 'package:reddit_clone/models/message_model.dart';

final messageControlerProvider =
    StateNotifierProvider<MessageControler, bool>((ref) {
  final userMessageRepository = ref.watch(userMessageProvider);

  return MessageControler(
    userMessageRepository: userMessageRepository,
    ref: ref,
  );
});

final getUserMessageProvider = StreamProvider.family((ref, String uid) {
  return ref.read(messageControlerProvider.notifier).getUserMessages(uid);
});

final fetchmessageProvider = StreamProvider.family((ref, String uid) {
  return ref.read(messageControlerProvider.notifier).fetchUserPost();
});

class MessageControler extends StateNotifier<bool> {
  final UserMessageRepository _userMessageRepository;

  final Ref _ref;

  MessageControler({
    required UserMessageRepository userMessageRepository,
    required Ref ref,
  })  : _userMessageRepository = userMessageRepository,
        _ref = ref,
        super(false);

  void sendMessage(
      {required BuildContext context,
      required String recieverUid,
      required String recieverProfilepic,
      required String text}) async {
    state = true;

    final user = _ref.read(userProvider)!;

    // Define a date format pattern

    List<String> ids = [user.uid, recieverUid];
    ids.sort(); //sort the ids( this ensure the chat room id is always same for any pair of people)
    String chatRoomId = ids.join("_");

    final MessageModel message = MessageModel(
      senderUID: user.uid,
      recieverUID: recieverUid,
      message: text,
      chatroomID: chatRoomId,
      sentAT: DateTime.now(),
      senderProfilePic: user.profilepic,
      recieverProfilePic: recieverProfilepic,
    );

    final res = await _userMessageRepository.sendMessage(message, chatRoomId);

    res.fold(
      (l) {},
      (r) {},
    );
  }

  Stream<List<MessageModel>> getUserMessages(String uid) {
    final user = _ref.watch(userProvider)!;
    return _userMessageRepository.getMessages(user.uid, uid);
  }

  void deleteMessage(MessageModel messageModel, BuildContext context) async {
    await _userMessageRepository.deleteMessagesForChatroom(messageModel);
  }

  Stream<List<MessageModel>> fetchUserPost() {
    final user = _ref.watch(userProvider)!;

    return _userMessageRepository.getMessagesBySenderUID(user.uid);
  }
}
