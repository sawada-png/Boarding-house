import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart' show Clipboard, ClipboardData;
import 'package:share_plus/share_plus.dart';

import '../../models/property.dart';
import '../../models/school.dart';
import '../shared/dialogs.dart';
import 'home_logic.dart';

/// The text people get when a student shares a boarding house.
String shareText(Property p, HouseRooms? rooms, School? school) {
  final lines = ['${p.name} · ${p.place}'];
  final details = <String>[];
  final open = rooms?.open ?? 0;
  if (open > 0) {
    details.add('$open ${open == 1 ? 'room' : 'rooms'} open from ₱${formatPesos(rooms!.cheapestOpen!)}/month');
  } else {
    details.add('${formatPriceRange(p.priceMin, p.priceMax)}/month');
  }
  if (school != null) details.add(walkText(distanceTo(school, p), school));
  lines.add(details.join(' · '));
  lines.add('Found on BoardMate');
  // TODO(share-link): add a real link (boardmate.app/house/{id}) that opens the app,
  // or a simple web page for people without the app.
  return lines.join('\n');
}

/// Opens the phone's share menu. In the browser it copies the text and shows "Copied!".
Future<void> shareHouse(BuildContext context, String text) async {
  if (kIsWeb) {
    await Clipboard.setData(ClipboardData(text: text));
    if (context.mounted) showToast(context, 'Copied!');
    return;
  }
  await SharePlus.instance.share(ShareParams(text: text));
}
