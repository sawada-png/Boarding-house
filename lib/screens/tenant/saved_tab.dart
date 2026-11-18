import 'package:cupertino_ui/cupertino_ui.dart';

import '../../models/app_user.dart';
import '../../models/property.dart';
import '../../models/room.dart';
import '../../models/school.dart';
import '../../services/landlord_service.dart';
import '../../services/property_service.dart';
import '../../services/room_service.dart';
import '../../services/saved_service.dart';
import '../../services/user_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/bm_tab_scaffold.dart';
import 'home_logic.dart';
import 'house_card.dart';

/// Saved tab: the houses the student hearted, newest first.
class SavedTab extends StatefulWidget {
  const SavedTab({
    super.key,
    required this.profile,
    this.properties,
    this.rooms,
    this.savedIds,
    this.school,
    this.landlords,
  });

  final AppUser profile;

  /// Only set in tests. Normally loaded from Firestore.
  final Stream<List<Property>>? properties;
  final Stream<List<Room>>? rooms;
  final Stream<List<String>>? savedIds;
  final Stream<AppUser?>? school;
  final Stream<Map<String, LandlordInfo>>? landlords;

  @override
  State<SavedTab> createState() => _SavedTabState();
}

class _SavedTabState extends State<SavedTab> {
  late final _properties = widget.properties ?? PropertyService().watchAll();
  late final _rooms = widget.rooms ?? RoomService().watchAll();
  late final _savedIds = widget.savedIds ?? SavedService().watchIds(widget.profile.uid);
  // The school can change on Home, so follow the live profile for walk times.
  late final _profile = widget.school ?? UserService().watch(widget.profile.uid);
  late final _landlords = widget.landlords ?? LandlordService().watchAll();

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: SafeArea(
        bottom: false,
        child: StreamBuilder<List<String>>(
          stream: _savedIds,
          builder: (context, saved) => StreamBuilder<List<Property>>(
            stream: _properties,
            builder: (context, places) => StreamBuilder<List<Room>>(
              stream: _rooms,
              builder: (context, rooms) => StreamBuilder<AppUser?>(
                stream: _profile,
                initialData: widget.profile,
                builder: (context, me) => StreamBuilder<Map<String, LandlordInfo>>(
                  stream: _landlords,
                  builder: (context, landlords) => ListView(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, BmTabScaffold.bottomSpace),
                    children: [
                      Text('Saved', style: AppText.largeTitle),
                      const SizedBox(height: 16),
                      ..._body(saved, places, rooms, schoolById(me.data?.school), landlords.data ?? const {}),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _body(
    AsyncSnapshot<List<String>> saved,
    AsyncSnapshot<List<Property>> places,
    AsyncSnapshot<List<Room>> rooms,
    School? school,
    Map<String, LandlordInfo> landlords,
  ) {
    if (saved.hasError || places.hasError) {
      return [
        const _Empty(
          icon: CupertinoIcons.wifi_slash,
          title: "Couldn't load your saved houses",
          text: 'Check your internet.',
        ),
      ];
    }
    if (!saved.hasData || !places.hasData) {
      return [const Padding(padding: EdgeInsets.only(top: 40), child: CupertinoActivityIndicator())];
    }
    final byId = {for (final p in places.data!) p.id: p};
    // A landlord may have deleted a saved house; skip it.
    final list = [
      for (final id in saved.data!)
        if (byId[id] != null) byId[id]!,
    ];
    if (list.isEmpty) {
      return [
        const _Empty(
          icon: CupertinoIcons.heart,
          title: 'Nothing saved yet',
          text: 'Tap the heart on a boarding house to compare it later.',
        ),
      ];
    }
    final byHouse = roomsByHouse(rooms.data ?? const []);
    return [
      for (final p in list)
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: HouseCard(
            property: p,
            rooms: byHouse[p.id],
            school: school,
            userId: widget.profile.uid,
            saved: true,
            landlord: landlords[p.landlordId],
          ),
        ),
    ];
  }
}

class _Empty extends StatelessWidget {
  const _Empty({required this.icon, required this.title, required this.text});

  final IconData icon;
  final String title;
  final String text;

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
            child: Icon(icon, size: 32, color: AppColors.ink),
          ),
          const SizedBox(height: 16),
          Text(title, style: AppText.section.copyWith(fontSize: 20), textAlign: TextAlign.center),
          const SizedBox(height: 6),
          Text(text, style: AppText.secondary.copyWith(fontSize: 15), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
