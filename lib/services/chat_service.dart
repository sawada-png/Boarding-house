import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/chat.dart';

/// Chats at chats/{studentId}_{propertyId}, messages at chats/{id}/messages/{id}.
class ChatService {
  ChatService([FirebaseFirestore? db]) : _db = db ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _chats => _db.collection('chats');

  /// The user's chats, newest first. Works for students and landlords.
  Stream<List<Chat>> watchMine(String uid) => _chats.where('members', arrayContains: uid).snapshots().map((snap) {
    final list = snap.docs.map(Chat.fromDoc).toList();
    // A chat whose last message is still sending has no time yet: treat it as newest.
    final now = DateTime.now();
    return list..sort((a, b) => (b.lastAt ?? now).compareTo(a.lastAt ?? now));
  });

  /// Messages of one chat, oldest first.
  // shortcut: loads the whole chat; add paging if chats grow past a few hundred messages.
  Stream<List<ChatMessage>> watchMessages(String chatId) =>
      _chats.doc(chatId).collection('messages').snapshots().map((snap) {
        final list = snap.docs.map(ChatMessage.fromDoc).toList();
        final now = DateTime.now();
        return list..sort((a, b) => (a.sentAt ?? now).compareTo(b.sentAt ?? now));
      });

  /// Sends one or more messages (like a room pill + the question) in one write.
  /// The student's first message also creates the chat. Returns the chat with the student's name filled in.
  Future<Chat> send(Chat chat, String senderId, List<ChatMessage> messages) async {
    if (senderId == chat.studentId && chat.studentName.isEmpty) {
      final me = await _db.collection('users').doc(senderId).get();
      chat = chat.withStudentName(me.data()?['name'] as String? ?? '');
    }
    final doc = _chats.doc(chat.id);
    final batch = _db.batch();
    for (final m in messages) {
      batch.set(doc.collection('messages').doc(), m.toMap());
    }
    final last = {'lastText': messages.last.preview, 'lastAt': FieldValue.serverTimestamp(), 'lastSenderId': senderId};
    if (senderId == chat.studentId) {
      batch.set(doc, {...chat.toStartMap(), ...last}, SetOptions(merge: true));
    } else {
      batch.update(doc, last);
    }
    await batch.commit();
    return chat;
  }

  /// The other person picks a time ([picked]) and confirms, or says none of the times work (null).
  Future<void> answerVisit(String chatId, String messageId, String? picked) => _chats
      .doc(chatId)
      .collection('messages')
      .doc(messageId)
      .update({'picked': picked, 'visitStatus': (picked == null ? VisitStatus.declined : VisitStatus.confirmed).name});
}
