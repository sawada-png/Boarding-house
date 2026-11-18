import 'package:cupertino_ui/cupertino_ui.dart';

import 'photo_box.dart';

/// Swipeable photos with a "1 / 8" counter in the corner.
class PhotoGallery extends StatefulWidget {
  const PhotoGallery({
    super.key,
    required this.photos,
    this.height = 300,
    this.hint = 'No photos yet',
    this.radius = 0,
    this.bottomLeft,
  });

  final List<String> photos;
  final double height;
  final String hint;

  /// 24 for the rounded card on the house page.
  final double radius;

  /// Shown at the bottom left, like the "6 min walk to PSU" pill.
  final Widget? bottomLeft;

  @override
  State<PhotoGallery> createState() => _PhotoGalleryState();
}

class _PhotoGalleryState extends State<PhotoGallery> {
  int _page = 0;

  @override
  Widget build(BuildContext context) {
    final photos = widget.photos;
    return ClipRRect(
      borderRadius: BorderRadius.circular(widget.radius),
      child: SizedBox(
        height: widget.height,
        child: Stack(
          children: [
            if (photos.isEmpty)
              PhotoBox(hint: widget.hint, height: widget.height)
            else
              PageView.builder(
                itemCount: photos.length,
                onPageChanged: (i) => setState(() => _page = i),
                itemBuilder: (_, i) => PhotoBox(imageUrl: photos[i], height: widget.height),
              ),
            if (widget.bottomLeft != null) Positioned(left: 12, bottom: 12, child: widget.bottomLeft!),
            if (photos.length > 1)
              Positioned(
                right: 12,
                bottom: 12,
                child: Container(
                  height: 26,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(color: const Color(0xB80F1D20), borderRadius: BorderRadius.circular(13)),
                  child: Text(
                    '${_page + 1} / ${photos.length}',
                    style: const TextStyle(color: Color(0xFFFFFFFF), fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
