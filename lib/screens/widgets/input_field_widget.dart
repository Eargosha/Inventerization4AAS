import 'package:flutter/material.dart';
import 'package:inventerization_4aas/constants/theme/app_colors.dart';
import 'package:inventerization_4aas/constants/theme/app_text_styles.dart';

class InputField extends StatefulWidget {
  final String placeholder;
  final bool obscureText;
  final ValueChanged<String?> onChanged;
  final void Function()? onTap;
  final bool search;
  final bool dropdown;
  final bool dropdownWithSearch;
  final bool date;
  final List<String>? dropdownItems;
  final String? initialValue;
  final String? selectedTitle;
  final FormFieldValidator<String>? validator;

  const InputField({
    super.key,
    required this.placeholder,
    this.obscureText = false,
    required this.onChanged,
    this.onTap,
    this.search = false,
    this.dropdown = false,
    this.dropdownWithSearch = false,
    this.date = false,
    this.dropdownItems,
    this.validator,
    this.initialValue,
    this.selectedTitle,
  });

  @override
  State<InputField> createState() => _InputFieldState();
}

class _InputFieldState extends State<InputField> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void didUpdateWidget(covariant InputField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialValue != widget.initialValue) {
      _controller.text = widget.initialValue ?? '';
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // --- Выпадающий список ---
    if (widget.dropdown) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: DropdownButtonFormField<String>(
          icon: const Icon(Icons.expand_more),
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFF0F2F5),
            hintText:widget. placeholder,
            hintStyle: const TextStyle(color: Color(0xFF60758A), fontSize: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(width: 2, color: AppColor.accentColor),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            isDense: true,
            prefixIcon: widget.search
                ? Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Icon(
                      Icons.search,
                      size: 32,
                      color: const Color(0xFF60758A),
                    ),
                  )
                : null,
          ),
          value: null,
          items: widget.dropdownItems?.map((item) {
            return DropdownMenuItem<String>(value: item, child: Text(item));
          }).toList(),
          onChanged: widget.onChanged,
          onTap: widget.onTap == null ? () {} : widget.onTap,
          style: const TextStyle(color: Color(0xFF111418), fontSize: 16),
          borderRadius: BorderRadius.circular(8),
          dropdownColor: Colors.white,
          validator: widget.validator,
        ),
      );
    }

    // --- Выпадающий список с поиском ---
    if (widget.dropdownWithSearch) {
      return GestureDetector(
        onTap: widget.onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: const Color(0xFFF0F2F5),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Expanded(
                child: widget.selectedTitle == null ? Text(
                  widget.placeholder,
                  style: const TextStyle(color: Color.fromRGBO(106, 107, 109, 1), fontSize: 16),
                ) : Text(
                  widget.selectedTitle!,
                  style: AppTextStyle.style16w400,
                ),
              ),
              Icon(Icons.expand_more, color: Color.fromRGBO(96,96,96,1)),
            ],
          ),
        ),
      );
    }

    // --- Поле для выбора даты ---
    if (widget.date) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: TextFormField(
          controller: _controller,
          readOnly: true,
          onTap: () async {
            final selectedDate = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(1900),
              lastDate: DateTime(2100),
            );

            if (selectedDate != null) {
              final formattedDate =
                  "${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}";
              _controller.text = formattedDate;
              widget.onChanged(formattedDate);
            }
          },
          validator: widget.validator,
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFF0F2F5),
            hintText: widget.placeholder,
            hintStyle: AppTextStyle.style16w400,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(width: 2, color: AppColor.accentColor),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            isDense: true,
            suffixIcon: const Icon(
              Icons.calendar_today,
              size: 20,
              color: Color(0xFF60758A),
            ),
          ),
          style: const TextStyle(color: Color(0xFF111418), fontSize: 16),
        ),
      );
    }

    // --- Обычный текстовый ввод с валидацией ---
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextFormField(
        initialValue: widget.initialValue,
        obscureText: widget.obscureText,
        onChanged: widget.onChanged,
        validator: widget.validator, // <-- validator передаётся сюда
        decoration: InputDecoration(
          filled: true,
          fillColor: const Color(0xFFF0F2F5),
          hintText: widget.placeholder,
          hintStyle: AppTextStyle.style16w400,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(width: 2, color: AppColor.accentColor),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          isDense: true,
          prefixIcon: widget.search
              ? Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Icon(
                    Icons.search,
                    size: 32,
                    color: const Color(0xFF60758A),
                  ),
                )
              : null,
        ),
        style: const TextStyle(color: Color(0xFF111418), fontSize: 16),
      ),
    );
  }
}
