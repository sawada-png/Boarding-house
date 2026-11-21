import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/chat.dart';
import '../../models/property.dart' show formatPesos;
import '../../models/room.dart';
import '../../services/chat_service.dart';
import '../../services/landlord_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/circle_back_button.dart';
import 'dialogs.dart';
import 'plan_visit_sheet.dart';
import 'visit_card.dart';

/// Quick questions a student can send with one tap (design-2.0/6-chat).
const quickQuestions = ['Is electricity separate?', 'Visitors allowed?', 'Is there a curfew?'];

/// One chat between a student and a landlord (design-2.0/6-chat).
class ChatScreen extends StatefulWidget {
  const ChatScreen({
    super.key,
    required this.chat,
    required this.me,
    this.room,
    this.planVisit = false,
    this.service,
    this.landlord,
  });

  final Chat chat;

  /// The logged-in user's id.
  final String me;

  /// Opened from "Ask about Room 2": the first message gets an "Asking about Room 2" pill.
  final Room? room;

  /// Opened from "Plan a visit": shows the visit sheet right away.
  final bool planVisit;

  /// Only set in tests.
  final ChatService? service;
  final Stream<LandlordInfo?>? landlord;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late final _service = widget.service ?? ChatService();
  late final _messages = _service.watchMessages(widget.chat.id);
  late final Stream<LandlordInfo?>? _landlord =
      widget.landlord ?? (_isStudent ? LandlordService().watch(widget.chat.landlordId) : null);
  final _text = TextEditingController();
  late Room? _room = widget.room;
  late Chat _chat = widget.chat;
  bool _sending = false;

  bool get _isStudent => widget.me == widget.chat.studentId;

  @override
  void initState() {
    super.initState();
    if (widget.planVisit) WidgetsBinding.instance.addPostFrameCallback((_) => _planVisit());
  }

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  Future<void> _send(List<ChatMessage> messages) async {
    final room = _room;
    if (room != null) {
      messages = [
        ChatMessage(senderId: widget.me, kind: MessageKind.room, roomName: room.name, roomPrice: room.monthlyPrice),
        ...messages,
      ];
    }
    setState(() => _sending = true);
    try {
      _chat = await _service.send(_chat, widget.me, messages);
      if (mounted) setState(() => _room = null);
    } catch (_) {
      if (mounted) await showError(context, "Couldn't send. Check your internet and try again.");
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _sendText([String? quick]) async {
    final text = (quick ?? _text.text).trim();
    if (text.isEmpty || _sending) return;
    if (quick == null) _text.clear();
    await _send([ChatMessage(senderId: widget.me, text: text)]);
  }

  Future<void> _planVisit() async {
    final picked = await showPlanVisitSheet(context);
    if (picked == null || !mounted) return;
    await _send([
      ChatMessage(senderId: widget.me, kind: MessageKind.visit, visitDay: picked.day, visitTimes: picked.times),
    ]);
  }

  Future<void> _answerVisit(ChatMessage m, String? picked) async {
    try {
      await _service.answerVisit(widget.chat.id, m.id, picked);
    } catch (_) {
      if (mounted) await showError(context, "Couldn't save your answer. Check your internet and try again.");
    }
  }

  void _directions() => launchUrl(
    Uri.parse('https://www.google.com/maps/dir/?api=1&destination=${widget.chat.latitude},${widget.chat.longitude}'),
  );

  @override
  Widget build(BuildContext context) {
    final chat = widget.chat;
    final other = chat.otherName(widget.me);
    return CupertinoPageScaffold(
      child: Column(
        children: [
          StreamBuilder<LandlordInfo?>(
            stream: _landlord,
            builder: (context, snap) => _Header(
              name: other,
              subtitle: '${_isStudent ? 'Owner' : 'Student'} · ${chat.propertyName}',
              phone: snap.data?.phone,
            ),
          ),
          Expanded(
            child: StreamBuilder<List<ChatMessage>>(
              stream: _messages,
              builder: (context, snap) {
                if (snap.hasError) {
                  return Center(child: Text("Couldn't load messages. Check your internet.", style: AppText.secondary));
                }
                if (!snap.hasData) return const Center(child: CupertinoActivityIndicator());
                final list = snap.data!;
                final room = _room;
                // Newest at the bottom: the list is reversed so it starts scrolled down.
                final items = <Widget>[
                  if (list.isEmpty && room == null) _Hint(isStudent: _isStudent, other: other),
                  for (final m in list) _item(m, other),
                  if (room != null) _RoomPill(name: room.name, price: room.monthlyPrice, pending: true),
                ];
                return ListView(
                  reverse: true,
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  children: [
                    for (final w in items.reversed) Padding(padding: const EdgeInsets.only(top: 10), child: w),
                  ],
                );
              },
            ),
          ),
          if (_isStudent)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  for (final q in quickQuestions) ...[
                    _QuickChip(label: q, onTap: _sending ? null : () => _sendText(q)),
                    const SizedBox(width: 8),
                  ],
                ],
              ),
            ),
          _Composer(controller: _text, sending: _sending, onSend: _sendText, onPlanVisit: _planVisit),
        ],
      ),
    );
  }

  Widget _item(ChatMessage m, String other) {
    final mine = m.senderId == widget.me;
    return switch (m.kind) {
      MessageKind.text => _Bubble(text: m.text, mine: mine),
      MessageKind.room => _RoomPill(name: m.roomName, price: m.roomPrice),
      MessageKind.visit => VisitCard(
        message: m,
        mine: mine,
        otherName: other,
        onAnswer: (picked) => _answerVisit(m, picked),
        onDirections: _directions,
      ),
    };
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.name, required this.subtitle, required this.phone});

  final String name;
  final String subtitle;

  /// Null hides the Call button.
  final String? phone;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 6, 16, 12),
        child: Row(
          children: [
            const CircleBackButton(),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppText.section),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.secondary.copyWith(fontSize: 12),
                  ),
                ],
              ),
            ),
            if (phone != null && phone!.isNotEmpty)
              Semantics(
                button: true,
                label: 'Call $name',
                excludeSemantics: true,
                child: GestureDetector(
                  onTap: () => launchUrl(Uri(scheme: 'tel', path: phone)),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(color: AppColors.ink, shape: BoxShape.circle),
                    child: const Icon(CupertinoIcons.phone_fill, size: 20, color: AppColors.card),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.text, required this.mine});

  final String text;
  final bool mine;

  @override
  Widget build(BuildContext context) {
    const big = Radius.circular(22);
    const small = Radius.circular(6);
    return Align(
      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
      child: FractionallySizedBox(
        widthFactor: 0.76,
        alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
        child: Align(
          alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 11),
            decoration: BoxDecoration(
              color: mine ? AppColors.ink : AppColors.card,
              borderRadius: BorderRadius.only(
                topLeft: big,
                topRight: big,
                bottomLeft: mine ? big : small,
                bottomRight: mine ? small : big,
              ),
            ),
            child: Text(
              text,
              style: AppText.body.copyWith(fontSize: 15, height: 1.4, color: mine ? AppColors.card : AppColors.ink),
            ),
          ),
        ),
      ),
    );
  }
}

/// "Asking about Room 2 · ₱4,500" in the middle of the chat.
class _RoomPill extends StatelessWidget {
  const _RoomPill({required this.name, required this.price, this.pending = false});

  final String name;
  final int price;

  /// Not sent yet: it goes out with the next message.
  final bool pending;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Opacity(
        opacity: pending ? 0.6 : 1,
        child: Container(
          height: 32,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(16)),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(color: AppColors.lagoon, borderRadius: BorderRadius.circular(4)),
              ),
              const SizedBox(width: 8),
              Text(
                'Asking about $name · ₱${formatPesos(price)}',
                style: AppText.small.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Shown in an empty chat.
class _Hint extends StatelessWidget {
  const _Hint({required this.isStudent, required this.other});

  final bool isStudent;
  final String other;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Text(
        isStudent
            ? 'Say hi to $other. Ask about the rooms, or tap the calendar to plan a visit.\nNever send a deposit before you visit.'
            : 'No messages yet.',
        textAlign: TextAlign.center,
        style: AppText.secondary.copyWith(height: 1.4),
      ),
    );
  }
}

class _QuickChip extends StatelessWidget {
  const _QuickChip({required this.label, required this.onTap});

  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      minimumSize: const Size(44, 44),
      onPressed: onTap,
      child: Container(
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        alignment: Alignment.center,
        decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(18)),
        child: Text(label, style: AppText.small.copyWith(fontSize: 13, fontWeight: FontWeight.w500)),
      ),
    );
  }
}

class _Composer extends StatelessWidget {
  const _Composer({required this.controller, required this.sending, required this.onSend, required this.onPlanVisit});

  final TextEditingController controller;
  final bool sending;
  final VoidCallback onSend;
  final VoidCallback onPlanVisit;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: Row(
          children: [
            Expanded(
              child: Container(
                height: 50,
                padding: const EdgeInsets.only(left: 18, right: 4),
                decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(25)),
                child: Row(
                  children: [
                    Expanded(
                      child: CupertinoTextField.borderless(
                        controller: controller,
                        placeholder: 'Message',
                        padding: EdgeInsets.zero,
                        style: AppText.body.copyWith(fontSize: 15),
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => onSend(),
                      ),
                    ),
                    Semantics(
                      button: true,
                      label: 'Plan a visit',
                      excludeSemantics: true,
                      child: CupertinoButton(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(44, 44),
                        onPressed: sending ? null : onPlanVisit,
                        child: const Icon(CupertinoIcons.calendar, size: 22, color: AppColors.textSecondary),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            Semantics(
              button: true,
              label: 'Send',
              excludeSemantics: true,
              child: GestureDetector(
                onTap: sending ? null : onSend,
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: const BoxDecoration(color: AppColors.lagoon, shape: BoxShape.circle),
                  child: sending
                      ? const CupertinoActivityIndicator(color: AppColors.card)
                      : const Icon(CupertinoIcons.arrow_up, size: 22, color: AppColors.card),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
