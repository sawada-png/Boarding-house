import 'package:cupertino_ui/cupertino_ui.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Red text button for deleting, shown under a form's Save button.
class DeleteTextButton extends StatelessWidget {
  const DeleteTextButton({super.key, required this.label, required this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: CupertinoButton(
        onPressed: onPressed,
        child: Text(label, style: AppText.label.copyWith(color: AppColors.error)),
      ),
    );
  }
}
