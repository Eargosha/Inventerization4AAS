import 'package:flutter/material.dart';
import 'package:inventerization_4aas/constants/theme/app_colors.dart';
import 'package:inventerization_4aas/constants/theme/app_text_styles.dart';

class DateFilterButton extends StatefulWidget {
  final String title;
  final String? year;     // Теперь опционально
  final String? month;    // Теперь опционально
  final ValueChanged<DateTime?> onChanged;

  const DateFilterButton({
    Key? key,
    required this.title,
    required this.onChanged,
    this.year,            // убрали required
    this.month,           // убрали required
  }) : super(key: key);

  @override
  State<DateFilterButton> createState() => _DateFilterButtonState();
}

class _DateFilterButtonState extends State<DateFilterButton> {
  DateTime? _selectedDate;

  Future<void> _selectDate(BuildContext context) async {
    DateTime? firstDate;
    DateTime? lastDate;

    // Пытаемся распарсить год и месяц
    final int? parsedYear = widget.year != null ? int.tryParse(widget.year!) : null;
    final int? parsedMonth = widget.month != null ? int.tryParse(widget.month!) : null;

    // Если оба значения корректны — ограничиваем пределы текущим месяцем
    if (parsedYear != null && parsedMonth != null && parsedMonth >= 1 && parsedMonth <= 12) {
      firstDate = DateTime(parsedYear, parsedMonth);
      lastDate = DateTime(parsedYear, parsedMonth + 1).subtract(const Duration(days: 1));
    } else {
      // Иначе — разрешаем широкий диапазон (например, ±10 лет от сегодня)
      final now = DateTime.now();
      firstDate = DateTime(now.year - 10, 1, 1);
      lastDate = DateTime(now.year + 10, 12, 31);
    }

    // Определяем initialDate
    DateTime initialDate;
    if (_selectedDate != null && _selectedDate!.isAfter(firstDate!) && _selectedDate!.isBefore(lastDate!)) {
      initialDate = _selectedDate!;
    } else {
      initialDate = DateTime.now();
      // Убеждаемся, что initialDate в пределах [firstDate, lastDate]
      if (initialDate.isBefore(firstDate)) {
        initialDate = firstDate;
      } else if (initialDate.isAfter(lastDate)) {
        initialDate = lastDate;
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
    return GestureDetector(
      onTap: () => _selectDate(context),
      child: Container(
        decoration: BoxDecoration(
          color: AppColor.elementColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
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
    );
  }
}