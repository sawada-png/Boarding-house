import 'package:cupertino_ui/cupertino_ui.dart';

import '../theme/app_text_styles.dart';

/// Bold label with a small gray hint under it, used above form sections.
class FormSectionLabel extends StatelessWidget {
  const FormSectionLabel(this.title, {super.key, this.hint});

  final String title;
  final String? hint;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppText.label),
          if (hint != null) ...[
            const SizedBox(height: 2),
            Text(hint!, style: AppText.secondary.copyWith(fontSize: 13)),
          ],
        ],
      ),
    );
  }
}
