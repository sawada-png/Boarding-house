import 'package:cupertino_ui/cupertino_ui.dart';

import '../../models/app_user.dart';
import '../../models/property.dart';
import '../../models/room.dart';
import '../../models/school.dart';
import '../../services/property_service.dart';
import '../../services/room_service.dart';
import '../../services/saved_service.dart';
import '../../services/user_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/bm_tab_scaffold.dart';
import 'house_card.dart';
import '../shared/dialogs.dart';
import 'home_header.dart';
import 'home_logic.dart';

/// Student home tab: live header pinned on top, boarding houses closest to the school below.
class HomeTab extends StatefulWidget {
  const HomeTab({super.key, required this.profile, this.properties, this.rooms, this.savedIds});

  final AppUser profile;

  /// Only set in tests. Normally loaded from Firestore.
  final Stream<List<Property>>? properties;
  final Stream<List<Room>>? rooms;
  final Stream<List<String>>? savedIds;

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  late final _properties = widget.properties ?? PropertyService().watchAll();
  late final _rooms = widget.rooms ?? RoomService().watchAll();
  late final _savedIds = widget.savedIds ?? SavedService().watchIds(widget.profile.uid);
  late School? _school = schoolById(widget.profile.school);
  final _search = TextEditingController();
  final _scroll = ScrollController();
  bool _collapsed = false;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
    _search.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _scroll.dispose();
    _search.dispose();
    super.dispose();
  }

  // Two different limits so the header doesn't flicker at the edge.
  void _onScroll() {
    final offset = _scroll.offset;
    if (!_collapsed && offset > 60) setState(() => _collapsed = true);
    if (_collapsed && offset < 8) setState(() => _collapsed = false);
  }

  void _expand() {
    _scroll.animateTo(0, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
  }

  /// Saves the school, or clears it when [picked] is null.
  Future<void> _setSchool(School? picked) async {
    final before = _school;
    setState(() => _school = picked);
    try {
      await UserService().setSchool(widget.profile.uid, picked?.id);
    } catch (_) {
      if (!mounted) return;
      setState(() => _school = before);
      await showError(context, "Couldn't save your school. Check your internet and try again.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: StreamBuilder<List<Property>>(
        stream: _properties,
        builder: (context, places) => StreamBuilder<List<Room>>(
          stream: _rooms,
          builder: (context, rooms) {
            final ready = places.hasData && rooms.hasData;
            return Column(
              children: [
                HomeHeader(
                  school: _school,
                  stats: ready ? LiveStats.from(places.data!, rooms.data!, _school) : null,
                  collapsed: _collapsed,
                  search: _search,
                  onSchool: _setSchool,
                  onExpand: _expand,
                  onBell: () => showInfo(
                    context,
                    title: 'No notifications yet',
                    message: "We'll let you know here when a landlord replies or a room opens up.",
                  ),
                  onFilters: () => showInfo(
                    context,
                    title: 'Coming soon',
                    message: 'Filters for price, girls/boys only, Wi-Fi and curfew are coming next.',
                  ),
                ),
                Expanded(
                  child: StreamBuilder<List<String>>(
                    stream: _savedIds,
                    builder: (context, saved) => ListView(
                      controller: _scroll,
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, BmTabScaffold.bottomSpace),
                      children: _listings(places, rooms, saved.data?.toSet() ?? const {}),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  List<Widget> _listings(AsyncSnapshot<List<Property>> places, AsyncSnapshot<List<Room>> rooms, Set<String> saved) {
    if (places.hasError) {
      return [
        const _Message(icon: CupertinoIcons.wifi_slash, text: "Couldn't load boarding houses.\nCheck your internet."),
      ];
    }
    if (!places.hasData) {
      return [const Padding(padding: EdgeInsets.only(top: 40), child: CupertinoActivityIndicator())];
    }
    final school = _school;
    final byHouse = roomsByHouse(rooms.data ?? const []);
    final near = school == null ? places.data! : places.data!.where((p) => isNear(school, p)).toList();
    final list = searchListings(sortForHome(near, byHouse, school), _search.text);
    final query = _search.text.trim();
    if (list.isEmpty) {
      return [
        _Message(
          icon: CupertinoIcons.house,
          text: query.isNotEmpty
              ? 'Nothing matches "$query".'
              : school == null
              ? 'No boarding houses yet.\nCheck again soon!'
              : 'No boarding houses near ${school.code} yet.',
        ),
      ];
    }
    final count = '${list.length} ${list.length == 1 ? 'house' : 'houses'}';
    return [
      Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Expanded(
            child: Text(
              school == null ? '$count · A to Z' : '$count · sorted by walk time',
              style: AppText.label.copyWith(fontSize: 15, color: AppColors.textSecondary),
            ),
          ),
          CupertinoButton(
            padding: EdgeInsets.zero,
            minimumSize: const Size(44, 44),
            onPressed: () => showInfo(
              context,
              title: 'Coming soon',
              message: 'A map with every boarding house and its prices is coming next.',
            ),
            child: Text('Map', style: AppText.label.copyWith(color: AppColors.lagoon)),
          ),
        ],
      ),
      const SizedBox(height: 8),
      for (final p in list)
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: HouseCard(
            property: p,
            rooms: byHouse[p.id],
            school: school,
            userId: widget.profile.uid,
            saved: saved.contains(p.id),
          ),
        ),
    ];
  }
}

class _Message extends StatelessWidget {
  const _Message({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 48),
      child: Column(
        children: [
          Icon(icon, size: 40, color: AppColors.textSecondary),
          const SizedBox(height: 10),
          Text(text, style: AppText.secondary, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
