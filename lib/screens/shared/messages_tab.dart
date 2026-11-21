import 'package:cupertino_ui/cupertino_ui.dart';

import '../../models/app_user.dart';
import '../../models/chat.dart';
import '../../services/chat_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/bm_tab_scaffold.dart';
import '../../widgets/rounded_card.dart';
import 'chat_screen.dart';

/// The Messages tab, for students and landlords: one row per chat, newest first.
class MessagesTab extends StatefulWidget {
  const MessagesTab({super.key, required this.profile, this.chats});

  final AppUser profile;

  /// Only set in tests.
  final Stream<List<Chat>>? chats;

  @override
  State<MessagesTab> createState() => _MessagesTabState();
}

class _MessagesTabState extends State<MessagesTab> {
  late final _chats = widget.chats ?? ChatService().watchMine(widget.profile.uid);

  @override
  Widget build(BuildContext context) {
    final me = widget.profile.uid;
    return CupertinoPageScaffold(
      child: SafeArea(
        bottom: false,
        child: StreamBuilder<List<Chat>>(
          stream: _chats,
          builder: (context, snap) {
            // A landlord in student mode only sees chats they started as a student, and the other way round.
            final list = [
              for (final c in snap.data ?? const <Chat>[])
                if ((c.landlordId == me) == widget.profile.isLandlord) c,
            ];
            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, BmTabScaffold.bottomSpace),
              children: [
                Text('Messages', style: AppText.largeTitle),
                const SizedBox(height: 16),
                if (snap.hasError)
                  Text("Couldn't load your messages. Check your internet.", style: AppText.secondary)
                else if (!snap.hasData)
                  const Padding(padding: EdgeInsets.only(top: 40), child: CupertinoActivityIndicator())
                else if (list.isEmpty)
                  _Empty(isLandlord: widget.profile.isLandlord)
                else
                  RoundedCard(
                    shadow: false,
                    child: Column(
                      children: [
                        for (var i = 0; i < list.length; i++) ...[
                          if (i > 0) Container(height: 1, color: AppColors.divider),
                          _ChatRow(chat: list[i], me: me),
                        ],
                      ],
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ChatRow extends StatelessWidget {
  const _ChatRow({required this.chat, required this.me});

  final Chat chat;
  final String me;

  @override
  Widget build(BuildContext context) {
    final name = chat.otherName(me);
    final last = chat.lastSenderId == me ? 'You: ${chat.lastText}' : chat.lastText;
    return CupertinoButton(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      onPressed: () => Navigator.of(context, rootNavigator: true).push(
        CupertinoPageRoute(
          builder: (_) => ChatScreen(chat: chat, me: me),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            decoration: const BoxDecoration(color: AppColors.lagoonLight, shape: BoxShape.circle),
            child: Text(name[0].toUpperCase(), style: AppText.section.copyWith(color: AppColors.lagoonDark)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppText.label.copyWith(fontSize: 16, fontWeight: FontWeight.w700),
                      ),
                    ),
                    if (chat.lastAt != null) Text(chatTime(chat.lastAt!), style: AppText.small),
                  ],
                ),
                Text(
                  chat.propertyName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.small.copyWith(color: AppColors.lagoonDark),
                ),
                const SizedBox(height: 2),
                Text(last, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppText.secondary),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty({required this.isLandlord});

  final bool isLandlord;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 80),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: const BoxDecoration(color: AppColors.card, shape: BoxShape.circle),
            child: const Icon(CupertinoIcons.chat_bubble_2, size: 32, color: AppColors.ink),
          ),
          const SizedBox(height: 16),
          Text('No messages yet', style: AppText.section.copyWith(fontSize: 20)),
          const SizedBox(height: 6),
          Text(
            isLandlord
                ? 'When a student asks about your rooms, the chat shows up here.'
                : 'Open a boarding house and tap "Ask about" or "Plan a visit" to message the owner.',
            textAlign: TextAlign.center,
            style: AppText.secondary.copyWith(fontSize: 15, height: 1.4),
          ),
        ],
      ),
    );
  }
}
