import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../l10n/app_localizations.dart';

Future<bool> confirmDeleteFlashcard(BuildContext context, String word) async {
  final l10n = AppLocalizations.of(context)!;
  final result = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(l10n.deleteFlashcard),
      content: Text(l10n.areYouSureYouWantToDeleteWord(word)),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: Text(l10n.cancel),
        ),
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(true),
          style: TextButton.styleFrom(foregroundColor: AppColors.error),
          child: Text(l10n.delete),
        ),
      ],
    ),
  );
  return result == true;
}
