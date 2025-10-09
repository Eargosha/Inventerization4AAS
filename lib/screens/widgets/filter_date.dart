import 'package:flutter/material.dart';
import 'package:inventerization_4aas/constants/theme/app_colors.dart';
import 'package:inventerization_4aas/constants/theme/app_text_styles.dart';

class DateFilterButton extends StatefulWidget {
  final String title;
  final String year;
  final String month;
  final ValueChanged<DateTime?> onChanged;

  const DateFilterButton({
    Key? key,
    required this.title,
    required this.onChanged,
    required this.year,
    required this.month,
  }) : super(key: key);

  @override
  State<DateFilterButton> createState() => _DateFilterButtonState();
}

class _DateFilterButtonState extends State<DateFilterButton> {
  DateTime? _selectedDate;

  // Future<void> _selectDate(BuildContext context) async {
  //   final DateTime? picked = await showDatePicker(
  //     context: context,
  //     initialDate: _selectedDate ?? DateTime.now(),
  //     firstDate: DateTime(int.tryParse(widget.year)!, int.tryParse(widget.month)!),
  //     lastDate: DateTime(int.tryParse(widget.year)!, int.tryParse(widget.month)!, 31),
  //     builder: (context, child) {
  //       return Theme(
  //         data: ThemeData.light().copyWith(
  //           colorScheme: ColorScheme.light(primary: AppColor.accentColor),
  //         ),
  //         child: child!,
  //       );
  //     },
  //   );

  //   if (picked != null && picked != _selectedDate) {
  //     setState(() {
  //       _selectedDate = picked;
  //     });
  //     widget.onChanged(picked);
  //   }
  // }

  Future<void> _selectDate(BuildContext context) async {
    final int year = int.tryParse(widget.year)!;
    final int month = int.tryParse(widget.month)!;

    // Определяем границы месяца
    final DateTime firstDate = DateTime(year, month);
    final DateTime lastDate = DateTime(
      year,
      month + 1,
    ).subtract(const Duration(days: 1));

    // Определяем initialDate с учётом границ
    DateTime initialDate;
    if (_selectedDate != null) {
      // Если уже выбрана дата — используем её, но проверяем границы
      if (_selectedDate!.isBefore(firstDate)) {
        initialDate = firstDate;
      } else if (_selectedDate!.isAfter(lastDate)) {
        initialDate = lastDate;
      } else {
        initialDate = _selectedDate!;
      }
    } else {
      // Если нет выбранной даты — используем сегодня, но не позже lastDate
      final now = DateTime.now();
      if (now.isBefore(firstDate)) {
        initialDate = firstDate;
      } else if (now.isAfter(lastDate)) {
        initialDate = lastDate;
      } else {
        initialDate = now;
      }
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(primary: AppColor.accentColor),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      widget.onChanged(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: GestureDetector(
        onTap: () => _selectDate(context),
        child: Container(
          decoration: BoxDecoration(
            color: AppColor.elementColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                Text(
                  _selectedDate != null
                      ? "${_selectedDate!.day}.${_selectedDate!.month}.${_selectedDate!.year}"
                      : widget.title,
                  style: AppTextStyle.style16w400.copyWith(
                    color: AppColor.textPrimary,
                  ),
                ),
                SizedBox(width: 8),
                Icon(
                  Icons.keyboard_arrow_down_outlined,
                  size: 32,
                  color: AppColor.textPrimary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
