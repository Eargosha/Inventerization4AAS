import 'package:flutter/material.dart';
import 'package:inventerization_4aas/constants/theme/app_colors.dart';
import 'package:inventerization_4aas/constants/theme/app_text_styles.dart';
import 'package:inventerization_4aas/utils/formatters.dart';

Widget movementTile({
  required String name,
  required String fromPlace,
  required String toPlace,
  required String invNumber,
  required DateTime date,
  required void Function()? onTap,
}) {
  return ListTile(
    title: Text(
      name,
      style: AppTextStyle.style18w700.copyWith(color: AppColor.textPrimary),
    ),
    subtitle: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Из $fromPlace кабинета -> в $toPlace',
          style: AppTextStyle.style14w400.copyWith(
            color: AppColor.textSecondary,
          ),
        ),
        Text(
          invNumber,
          style: AppTextStyle.style14w600.copyWith(
            color: AppColor.textSecondary,
          ),
        ),
      ],
    ),
    trailing: Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(
          formatDateTime(date),
          style: AppTextStyle.style16w400.copyWith(
            color: AppColor.textSecondary,
          ),
        ),
      ],
    ),
    onTap: () {
      onTap!();
    },
  );
}
