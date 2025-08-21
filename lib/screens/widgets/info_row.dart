// widgets/info_row.dart

import 'package:flutter/material.dart';
import 'package:inventerization_4aas/constants/theme/app_colors.dart';
import 'package:inventerization_4aas/constants/theme/app_text_styles.dart';

class InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const InfoRow({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SizedBox(
          width: 120, // Фиксированная ширина для меток (можно регулировать)
          child: Text(
            '$label:',
            style: AppTextStyle.style14w400.copyWith(
              color: AppColor.textSecondary,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: AppTextStyle.style16w400.copyWith(
              color: AppColor.textPrimary,
            ),
            maxLines: 5,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}
