import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:image_picker/image_picker.dart';

import '../models/picked_photo.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'photo_box.dart';

/// Grid of photos with an "Add photos" tile and an × on each photo to remove it.
/// The first photo is the cover.
class PhotoPickerGrid extends StatelessWidget {
  const PhotoPickerGrid({
    super.key,
    required this.photos,
    required this.onChanged,
    this.max = 10,
  });

  final List<PickedPhoto> photos;
  final ValueChanged<List<PickedPhoto>> onChanged;
  final int max;

  Future<void> _pick() async {
    // Resized on the phone first so uploads are quick on mobile data.
    final files = await ImagePicker().pickMultiImage(maxWidth: 1600, imageQuality: 80);
    if (files.isEmpty) return;
    final room = max - photos.length;
    final added = [
      for (final f in files.take(room))
        PickedPhoto.local(await f.readAsBytes(), mimeType: f.mimeType),
    ];
    onChanged([...photos, ...added]);
  }

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      children: [
        for (var i = 0; i < photos.length; i++) _tile(i),
        if (photos.length < max) _addTile(),
      ],
    );
  }

  Widget _tile(int i) {
    final photo = photos[i];
    return Stack(
      fit: StackFit.expand,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: photo.isUploaded
              ? PhotoBox(imageUrl: photo.url)
              : Image.memory(photo.bytes!, fit: BoxFit.cover),
        ),
        if (i == 0)
          Positioned(
            left: 6,
            bottom: 6,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xB31C1C1E),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text('Cover', style: AppText.small.copyWith(color: AppColors.card, fontSize: 11)),
            ),
          ),
        Positioned(
          top: 4,
          right: 4,
          child: Semantics(
            button: true,
            label: 'Remove photo',
            child: GestureDetector(
              onTap: () => onChanged([...photos]..removeAt(i)),
              child: Container(
                width: 26,
                height: 26,
                decoration: const BoxDecoration(color: Color(0xCC1C1C1E), shape: BoxShape.circle),
                child: const Icon(CupertinoIcons.xmark, size: 14, color: AppColors.card),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _addTile() {
    return Semantics(
      button: true,
      label: 'Add photos',
      child: GestureDetector(
        onTap: _pick,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(CupertinoIcons.camera, color: AppColors.lagoon),
              const SizedBox(height: 4),
              Text('Add photos', style: AppText.small.copyWith(color: AppColors.lagoon)),
            ],
          ),
        ),
      ),
    );
  }
}
