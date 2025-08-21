import 'package:flutter/material.dart';
import 'package:inventerization_4aas/constants/theme/app_colors.dart';
import 'package:inventerization_4aas/constants/theme/app_text_styles.dart';

Widget invCheckbox({
  required bool value,
  required void Function(bool) onChanged,
  String? text,
}) {
  return Row(
    children: [
      Checkbox(
        activeColor: AppColor.mainButton,
        focusColor: AppColor.accentColor,
        value: value,
        onChanged: (value) {
          onChanged(value!);
        },
      ),

      Text(text ?? "", style: AppTextStyle.style16w400),
    ],
  );
}
