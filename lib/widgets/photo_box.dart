import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_colors.dart';

/// Shows a photo from a web link, or a colored box with a hint when there is no photo yet.
class PhotoBox extends StatelessWidget {
  const PhotoBox({
    super.key,
    this.imageUrl,
    this.hint = '',
    this.sand = false,
    this.width,
    this.height,
    this.radius = 0,
  });

  final String? imageUrl;
  final String hint;

  /// Sand-colored placeholder instead of teal (the mockups use both).
  final bool sand;
  final double? width;
  final double? height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final placeholder = Container(
      color: sand ? AppColors.photoSand : AppColors.photoTeal,
      alignment: Alignment.center,
      padding: const EdgeInsets.all(8),
      child: Text(
        hint,
        textAlign: TextAlign.center,
        style: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: sand ? AppColors.photoSandText : AppColors.photoTealText,
        ),
      ),
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: SizedBox(
        width: width,
        height: height,
        child: imageUrl == null
            ? placeholder
            : Image.network(imageUrl!, fit: BoxFit.cover, errorBuilder: (_, _, _) => placeholder),
      ),
    );
  }
}
