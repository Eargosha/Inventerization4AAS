import 'package:flutter/material.dart';
import 'package:inventerization_4aas/models/update_info_model.dart';
import 'package:inventerization_4aas/screens/widgets/update_dialog.dart';
import 'package:inventerization_4aas/utils/update_service.dart';

Future<void> showUpdateDialogIfNeeded(BuildContext context, UpdateInfo info) async {
  // Откладываем вызов до следующего кадра отрисовки
  await WidgetsBinding.instance.endOfFrame;
  if (!context.mounted) return;
  
  await showDialog(
    context: context,
    builder: (_) => UpdateDialog(
      updateInfo: info,
      onDownload: () => _handleUpdateDownload(context, info),
    ),
  );
}

Future<void> _handleUpdateDownload(BuildContext context, UpdateInfo info) async {
  try {
    await UpdateService.downloadAndInstall(info);
  } catch (e) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Ошибка обновления: $e')),
    );
  }
}