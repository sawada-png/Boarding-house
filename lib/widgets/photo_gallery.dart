import 'package:cupertino_ui/cupertino_ui.dart';

import 'photo_box.dart';

/// Swipeable photos with a "1 / 8" counter in the corner.
class PhotoGallery extends StatefulWidget {
  const PhotoGallery({super.key, required this.photos, this.height = 300, this.hint = 'No photos yet'});

  final List<String> photos;
  final double height;
  final String hint;

  @override
  State<PhotoGallery> createState() => _PhotoGalleryState();
}

class _PhotoGalleryState extends State<PhotoGallery> {
  int _page = 0;

  @override
  Widget build(BuildContext context) {
    final photos = widget.photos;
    if (photos.isEmpty) return PhotoBox(hint: widget.hint, height: widget.height);

    return SizedBox(
      height: widget.height,
      child: Stack(
        children: [
          PageView.builder(
            itemCount: photos.length,
            onPageChanged: (i) => setState(() => _page = i),
            itemBuilder: (_, i) => PhotoBox(imageUrl: photos[i], height: widget.height),
          ),
          if (photos.length > 1)
            Positioned(
              right: 16,
              bottom: 36,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xB31C1C1E),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${_page + 1} / ${photos.length}',
                  style: const TextStyle(color: Color(0xFFFFFFFF), fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
