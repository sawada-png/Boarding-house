import 'package:cloud_firestore/cloud_firestore.dart';

/// A chat between one student and one landlord about one boarding house: chats/{studentId}_{propertyId}.
class Chat {
  const Chat({
    required this.studentId,
    required this.landlordId,
    required this.propertyId,
    required this.propertyName,
    this.studentName = '',
    this.landlordName = '',
    this.latitude = 0,
    this.longitude = 0,
    this.lastText = '',
    this.lastAt,
    this.lastSenderId = '',
  });

  final String studentId;
  final String landlordId;
  final String propertyId;
  final String propertyName;
  final String studentName;
  final String landlordName;

  /// The house pin, for "Directions" on a visit card.
  final double latitude;
  final double longitude;

  final String lastText;
  final DateTime? lastAt;
  final String lastSenderId;

  String get id => chatIdFor(studentId, propertyId);

  Chat withStudentName(String name) => Chat(
    studentId: studentId,
    landlordId: landlordId,
    propertyId: propertyId,
    propertyName: propertyName,
    studentName: name,
    landlordName: landlordName,
    latitude: latitude,
    longitude: longitude,
  );

  /// The other person's name, as [me] sees it.
  String otherName(String me) {
    final name = me == studentId ? landlordName : studentName;
    return name.trim().isEmpty ? (me == studentId ? 'Owner' : 'Student') : name.trim();
  }

  factory Chat.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? const {};
    return Chat(
      studentId: d['studentId'] as String? ?? '',
      landlordId: d['landlordId'] as String? ?? '',
      propertyId: d['propertyId'] as String? ?? '',
      propertyName: d['propertyName'] as String? ?? '',
      studentName: d['studentName'] as String? ?? '',
      landlordName: d['landlordName'] as String? ?? '',
      latitude: (d['latitude'] as num?)?.toDouble() ?? 0,
      longitude: (d['longitude'] as num?)?.toDouble() ?? 0,
      lastText: d['lastText'] as String? ?? '',
      lastAt: (d['lastAt'] as Timestamp?)?.toDate(),
      lastSenderId: d['lastSenderId'] as String? ?? '',
    );
  }

  /// Fields only the student writes, once, when the chat starts.
  Map<String, dynamic> toStartMap() => {
    'studentId': studentId,
    'landlordId': landlordId,
    'propertyId': propertyId,
    'propertyName': propertyName,
    'studentName': studentName,
    'landlordName': landlordName,
    'latitude': latitude,
    'longitude': longitude,
    'members': [studentId, landlordId],
  };
}

String chatIdFor(String studentId, String propertyId) => '${studentId}_$propertyId';

enum MessageKind { text, room, visit }

enum VisitStatus { open, confirmed, declined }

/// Times a student or landlord can offer for a visit.
const visitTimes = ['9:00 AM', '10:30 AM', '1:00 PM', '3:00 PM', '4:30 PM', '6:00 PM'];

/// One message: plain text, an "Asking about Room 2" pill, or a visit card.
class ChatMessage {
  const ChatMessage({
    this.id = '',
    required this.senderId,
    this.kind = MessageKind.text,
    this.text = '',
    this.sentAt,
    this.roomName = '',
    this.roomPrice = 0,
    this.visitDay,
    this.visitTimes = const [],
    this.picked,
    this.visitStatus = VisitStatus.open,
  });

  final String id;
  final String senderId;
  final MessageKind kind;
  final String text;
  final DateTime? sentAt;

  /// [MessageKind.room] only.
  final String roomName;
  final int roomPrice;

  /// [MessageKind.visit] only: the day, the offered times, and the one the other person picked.
  final DateTime? visitDay;
  final List<String> visitTimes;
  final String? picked;
  final VisitStatus visitStatus;

  factory ChatMessage.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? const {};
    return ChatMessage(
      id: doc.id,
      senderId: d['senderId'] as String? ?? '',
      kind: MessageKind.values.asNameMap()[d['kind']] ?? MessageKind.text,
      text: d['text'] as String? ?? '',
      sentAt: (d['sentAt'] as Timestamp?)?.toDate(),
      roomName: d['roomName'] as String? ?? '',
      roomPrice: (d['roomPrice'] as num?)?.toInt() ?? 0,
      visitDay: (d['visitDay'] as Timestamp?)?.toDate(),
      visitTimes: List<String>.from(d['visitTimes'] as List? ?? const []),
      picked: d['picked'] as String?,
      visitStatus: VisitStatus.values.asNameMap()[d['visitStatus']] ?? VisitStatus.open,
    );
  }

  Map<String, dynamic> toMap() => {
    'senderId': senderId,
    'kind': kind.name,
    'sentAt': FieldValue.serverTimestamp(),
    if (kind == MessageKind.text) 'text': text,
    if (kind == MessageKind.room) ...{'roomName': roomName, 'roomPrice': roomPrice},
    if (kind == MessageKind.visit) ...{
      'visitDay': Timestamp.fromDate(visitDay!),
      'visitTimes': visitTimes,
      'visitStatus': VisitStatus.open.name,
    },
  };

  /// One line for the Messages list.
  String get preview => switch (kind) {
    MessageKind.text => text,
    MessageKind.room => 'Asked about $roomName',
    MessageKind.visit => 'Visit · ${shortDay(visitDay!)}',
  };
}

const _weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
const _months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

/// "Thursday, Nov 20"
String longDay(DateTime d) => '${_weekdays[d.weekday - 1]}, ${_months[d.month - 1]} ${d.day}';

/// "Thu, Nov 20"
String shortDay(DateTime d) => '${_weekdays[d.weekday - 1].substring(0, 3)}, ${_months[d.month - 1]} ${d.day}';

/// "Nov 20"
String monthDay(DateTime d) => '${_months[d.month - 1]} ${d.day}';

/// "4:30 PM" today, otherwise "Nov 20".
String chatTime(DateTime d, {DateTime? now}) {
  final n = now ?? DateTime.now();
  if (d.year == n.year && d.month == n.month && d.day == n.day) {
    final h = d.hour % 12 == 0 ? 12 : d.hour % 12;
    return '$h:${d.minute.toString().padLeft(2, '0')} ${d.hour < 12 ? 'AM' : 'PM'}';
  }
  return monthDay(d);
}
