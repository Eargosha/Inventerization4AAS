import 'package:flutter/material.dart';
import 'package:inventerization_4aas/models/update_info_model.dart';

class UpdateDialog extends StatelessWidget {
  final UpdateInfo updateInfo;
  final VoidCallback onDownload;

  const UpdateDialog({
    Key? key,
    required this.updateInfo,
    required this.onDownload,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Доступно обновление'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Версия: ${updateInfo.version}'),
          if (updateInfo.changelog != null) ...[
            SizedBox(height: 8),
            Text(updateInfo.changelog!),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: Navigator.of(context).pop,
          child: Text('Позже'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
            onDownload();
          },
          child: Text('Обновить'),
        ),
      ],
    );
  }
}