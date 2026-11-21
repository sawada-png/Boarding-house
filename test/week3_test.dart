import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:boardmate/models/chat.dart';
import 'package:boardmate/models/review.dart';
import 'package:boardmate/models/room.dart';
import 'package:boardmate/models/stay.dart';
import 'package:boardmate/screens/landlord/dashboard_tab.dart';
import 'package:boardmate/screens/shared/chat_screen.dart';
import 'package:boardmate/screens/shared/visit_card.dart';
import 'package:boardmate/services/chat_service.dart';
import 'package:boardmate/services/landlord_service.dart';

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  const chat = Chat(
    studentId: 's1',
    landlordId: 'l1',
    propertyId: 'p1',
    propertyName: "Neegy's Place",
    landlordName: 'Nathan Grande',
  );

  test('First student message creates the chat with both members and the student name', () async {
    final db = FakeFirebaseFirestore();
    await db.collection('users').doc('s1').set({'name': 'Ana Cruz'});
    final service = ChatService(db);

    final sent = await service.send(chat, 's1', [
      const ChatMessage(senderId: 's1', kind: MessageKind.room, roomName: 'Room 2', roomPrice: 4500),
      const ChatMessage(senderId: 's1', text: 'Is Room 2 still open?'),
    ]);
    expect(sent.studentName, 'Ana Cruz');

    final doc = (await db.collection('chats').doc('s1_p1').get()).data()!;
    expect(doc['members'], ['s1', 'l1']);
    expect(doc['lastText'], 'Is Room 2 still open?');

    // The landlord answers with a visit card; the student confirms a time.
    await service.send(sent, 'l1', [
      ChatMessage(
        senderId: 'l1',
        kind: MessageKind.visit,
        visitDay: DateTime(2026, 11, 20),
        visitTimes: const ['3:00 PM', '4:30 PM'],
      ),
    ]);
    final landlordChats = await service.watchMine('l1').first;
    expect(landlordChats.single.otherName('l1'), 'Ana Cruz');
    expect(landlordChats.single.lastText, 'Visit · Fri, Nov 20');

    final messages = await service.watchMessages('s1_p1').first;
    expect(messages.map((m) => m.kind), containsAll(MessageKind.values));
    final visit = messages.firstWhere((m) => m.kind == MessageKind.visit);
    await service.answerVisit('s1_p1', visit.id, '4:30 PM');
    final after = (await service.watchMessages('s1_p1').first).firstWhere((m) => m.kind == MessageKind.visit);
    expect(after.visitStatus, VisitStatus.confirmed);
    expect(after.picked, '4:30 PM');
  });

  test('A tenant fills a solo room, or the last bed of a bedspace', () {
    const solo = Room(id: 'r1', propertyId: 'p', landlordId: 'l', name: 'Room 1', type: RoomType.solo, monthlyPrice: 1);
    const beds = Room(
      id: 'r2',
      propertyId: 'p',
      landlordId: 'l',
      name: 'Room 2',
      type: RoomType.bedspace,
      capacity: 2,
      monthlyPrice: 1,
    );
    Stay stay(String room, StayStatus status) => Stay(
      studentId: 's',
      studentName: '',
      landlordId: 'l',
      propertyId: 'p',
      propertyName: '',
      roomId: room,
      roomName: '',
      status: status,
    );
    expect(fillsRoom(solo, const []), isTrue);
    expect(fillsRoom(beds, const []), isFalse);
    expect(fillsRoom(beds, [stay('r2', StayStatus.active)]), isTrue);
    // Someone who moved out or said "Not me" frees the bed.
    expect(fillsRoom(beds, [stay('r2', StayStatus.ended), stay('r2', StayStatus.declined)]), isFalse);
  });

  test('Weekly check picks the open room that went longest without a check', () {
    final now = DateTime(2026, 11, 20);
    Room room(String name, int daysAgo, {bool open = true}) => Room(
      id: name,
      propertyId: 'p',
      landlordId: 'l',
      name: name,
      type: RoomType.solo,
      monthlyPrice: 1,
      available: open,
      updatedAt: now.subtract(Duration(days: daysAgo)),
    );
    expect(roomToCheck([room('Room 1', 2), room('Room 2', 6)], now: now), isNull);
    expect(
      roomToCheck([room('Room 1', 8), room('Room 4', 20), room('Room 5', 30, open: false)], now: now)?.name,
      'Room 4',
    );
  });

  test('Average stars and chat times', () {
    Review r(int stars) =>
        Review(propertyId: 'p', studentId: 's', studentName: '', roomName: '', stars: stars, text: '');
    expect(averageStars(const []), isNull);
    expect(averageStars([r(5), r(4), r(4)]), '4.3');
    final now = DateTime(2026, 11, 20, 18);
    expect(chatTime(DateTime(2026, 11, 20, 16, 30), now: now), '4:30 PM');
    expect(chatTime(DateTime(2026, 11, 20, 0, 5), now: now), '12:05 AM');
    expect(chatTime(DateTime(2026, 11, 3, 9), now: now), 'Nov 3');
  });

  testWidgets('Visit card: the other person picks a time and confirms; the sender waits', (tester) async {
    String? answered = 'none';
    final m = ChatMessage(
      id: 'm1',
      senderId: 'l1',
      kind: MessageKind.visit,
      visitDay: DateTime(2026, 11, 20),
      visitTimes: const ['3:00 PM', '4:30 PM', '6:00 PM'],
    );
    Widget card(bool mine) => CupertinoApp(
      home: CupertinoPageScaffold(
        child: VisitCard(
          message: m,
          mine: mine,
          otherName: 'Ana',
          onAnswer: (picked) async => answered = picked,
          onDirections: () {},
        ),
      ),
    );

    await tester.pumpWidget(card(false));
    expect(find.text('VISIT · PICK A TIME'), findsOneWidget);
    expect(find.text('Friday, Nov 20'), findsOneWidget);
    await tester.tap(find.text('4:30 PM'));
    await tester.pump();
    await tester.tap(find.text('Confirm 4:30 PM'));
    await tester.pump();
    expect(answered, '4:30 PM');

    await tester.pumpWidget(card(true));
    expect(find.text('VISIT · WAITING FOR ANA'), findsOneWidget);
    expect(find.text('None of these work'), findsNothing);
  });

  testWidgets('Chat: room pill waits for the first message, then both send; Call shows with a phone', (tester) async {
    final db = FakeFirebaseFirestore();
    await db.collection('users').doc('s1').set({'name': 'Ana'});
    await tester.pumpWidget(
      CupertinoApp(
        home: ChatScreen(
          chat: chat,
          me: 's1',
          room: const Room(propertyId: 'p1', landlordId: 'l1', name: 'Room 2', type: RoomType.solo, monthlyPrice: 4500),
          service: ChatService(db),
          landlord: Stream.value(const LandlordInfo(name: 'Nathan Grande', phone: '+639171234567')),
        ),
      ),
    );
    await tester.pump();
    expect(find.text('Nathan Grande'), findsOneWidget);
    expect(find.text("Owner · Neegy's Place"), findsOneWidget);
    expect(find.bySemanticsLabel('Call Nathan Grande'), findsOneWidget);
    expect(find.text('Asking about Room 2 · ₱4,500'), findsOneWidget);

    await tester.enterText(find.byType(CupertinoTextField), 'Is it still open?');
    await tester.tap(find.bySemanticsLabel('Send'));
    await tester.pumpAndSettle();
    expect(find.text('Is it still open?'), findsOneWidget);
    expect(find.text('Asking about Room 2 · ₱4,500'), findsOneWidget);

    final messages = await db.collection('chats').doc('s1_p1').collection('messages').get();
    expect(messages.docs, hasLength(2));
  });
}
