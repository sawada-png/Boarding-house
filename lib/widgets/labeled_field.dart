import 'package:cupertino_ui/cupertino_ui.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// A label with a white rounded text box under it.
class LabeledField extends StatelessWidget {
  const LabeledField({
    super.key,
    required this.label,
    required this.controller,
    this.placeholder,
    this.keyboardType,
    this.maxLines = 1,
    this.prefixText,
    this.textCapitalization = TextCapitalization.none,
  });

  final String label;
  final TextEditingController controller;
  final String? placeholder;
  final TextInputType? keyboardType;
  final int maxLines;

  /// Shown inside the box before the text, like "₱".
  final String? prefixText;
  final TextCapitalization textCapitalization;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppText.label),
        const SizedBox(height: 8),
        CupertinoTextField(
          controller: controller,
          placeholder: placeholder,
          keyboardType: keyboardType,
          maxLines: maxLines,
          minLines: maxLines > 1 ? 3 : 1,
          textCapitalization: textCapitalization,
          style: AppText.body,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          prefix: prefixText == null
              ? null
              : Padding(
                  padding: const EdgeInsets.only(left: 14),
                  child: Text(prefixText!, style: AppText.body.copyWith(color: AppColors.textSecondary)),
                ),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ],
    );
  }
}
