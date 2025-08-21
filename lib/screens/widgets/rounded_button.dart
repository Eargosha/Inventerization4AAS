import 'package:flutter/material.dart';
import 'package:inventerization_4aas/constants/theme/app_colors.dart';

Widget roundedButton({required void Function()? onPressed, Icon? icon, double? size}) {
  return ElevatedButton(
    style: ElevatedButton.styleFrom(
      shape: CircleBorder(),
      padding: EdgeInsets.all(size ?? 16),
      backgroundColor: Colors.white,
      shadowColor: AppColor.shadowColor,
      elevation: 5,
    ),
    onPressed: () {
      onPressed!();
    },
    child:
        icon ??
        Icon(Icons.camera_alt_rounded, color: AppColor.textPrimary, size: 32),
  );
}
