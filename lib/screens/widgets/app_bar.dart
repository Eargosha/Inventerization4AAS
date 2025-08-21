import 'package:flutter/material.dart';
import 'package:inventerization_4aas/constants/theme/app_colors.dart';
import 'package:inventerization_4aas/constants/theme/app_text_styles.dart';

PreferredSizeWidget invAppBar({String? title, List<Widget>? actions, Widget? leading}) {
  return AppBar(
    title: Text(
      title ?? 'Инвентаризация 4ААС',
      style: AppTextStyle.style22w700.copyWith(color: AppColor.textPrimary),
    ),
    elevation: 0,
    centerTitle: true,
    actions: actions,
    scrolledUnderElevation: 0,
    leading: leading,
  );
}
