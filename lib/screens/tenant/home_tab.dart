import 'package:cupertino_ui/cupertino_ui.dart';

import '../../models/app_user.dart';
import '../../models/property.dart';
import '../../models/room.dart';
import '../../models/school.dart';
import '../../services/property_service.dart';
import '../../services/room_service.dart';
import '../../services/user_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/bm_tab_scaffold.dart';
import '../../widgets/listing_card.dart';
import '../shared/dialogs.dart';
import 'home_header.dart';
import 'home_logic.dart';
import 'listing_screen.dart';

/// Student home tab: live header pinned on top, boarding houses closest to the school below.
class HomeTab extends StatefulWidget {
  const HomeTab({super.key, required this.profile, this.properties, this.rooms});

  final AppUser profile;

  /// Only set in tests. Normally loaded from Firestore.
  final Stream<List<Property>>? properties;
  final Stream<List<Room>>? rooms;

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  late final _properties = widget.properties ?? PropertyService().watchAll();
  late final _rooms = widget.rooms ?? RoomService().watchAll();
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
                  onBell: () => showInfo(context, title: 'No notifications yet', message: "We'll let you know here when a landlord replies or a room opens up."),
                  onFilters: () => showInfo(context, title: 'Coming soon', message: 'Filters for price, girls/boys only, Wi-Fi and curfew are coming next.'),
                ),
                Expanded(
                  child: ListView(
                    controller: _scroll,
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, BmTabScaffold.bottomSpace),
                    children: _listings(places, rooms),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  List<Widget> _listings(AsyncSnapshot<List<Property>> places, AsyncSnapshot<List<Room>> rooms) {
    if (places.hasError) {
      return [const _Message(icon: CupertinoIcons.wifi_slash, text: "Couldn't load boarding houses.\nCheck your internet.")];
    }
    if (!places.hasData) {
      return [const Padding(padding: EdgeInsets.only(top: 40), child: CupertinoActivityIndicator())];
    }
    final list = searchListings(sortByDistance(places.data!, _school), _search.text);
    if (list.isEmpty) {
      return [
        _Message(
          icon: CupertinoIcons.house,
          text: _search.text.trim().isEmpty
              ? 'No boarding houses yet.\nCheck again soon!'
              : 'Nothing matches "${_search.text.trim()}".',
        ),
      ];
    }
    final available = countAvailableRooms(rooms.data ?? const []);
    final count = '${list.length} ${list.length == 1 ? 'house' : 'houses'}';
    return [
      Text(
        _school == null ? '$count · A to Z' : '$count · closest first',
        style: AppText.label.copyWith(fontSize: 15, color: AppColors.textSecondary),
      ),
      const SizedBox(height: 16),
      for (final p in list)
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: ListingCard(
            name: p.name,
            subtitle: _subtitle(p),
            priceText: formatPriceRange(p.priceMin, p.priceMax),
            photoUrl: p.photos.isEmpty ? null : p.photos.first,
            roomsAvailable: available[p.id],
            onTap: () => Navigator.of(context, rootNavigator: true).push(
              CupertinoPageRoute(builder: (_) => ListingScreen(property: p, school: _school)),
            ),
          ),
        ),
    ];
  }

  String _subtitle(Property p) {
    final school = _school;
    if (school == null) return p.tags.isEmpty ? 'Puerto Princesa' : p.tags.take(3).join(' · ');
    return '${formatDistance(distanceTo(school, p))} from ${school.shortName}';
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
