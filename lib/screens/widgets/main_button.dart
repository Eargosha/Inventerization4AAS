import 'package:flutter/material.dart';
import 'package:inventerization_4aas/constants/theme/app_colors.dart';
import 'package:inventerization_4aas/constants/theme/app_text_styles.dart';

Widget mainButton({
  required void Function()? onPressed,
  String? title,
  Color? color,
  Icon? icon,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 12),
    child: SizedBox(
      height: 48,
      child: ElevatedButton(
        onPressed: () {
          onPressed!();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: color ?? AppColor.mainButton,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: icon == null
            ? Center(
                child: Text(
                  title ?? 'Войти',
                  style: AppTextStyle.style18w700.copyWith(
                    color: color == null ? AppColor.textInverse : AppColor.textPrimary,
                  ),
                ),
              )
            : Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    icon,
                    SizedBox(width: 10),
                    Text(
                      title ?? 'Войти',
                      style: AppTextStyle.style16w600.copyWith(
                        color: color == null
                            ? AppColor.textInverse
                            : AppColor.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
      ),
    ),
  );
}
