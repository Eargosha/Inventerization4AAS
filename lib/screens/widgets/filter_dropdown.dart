import 'package:flutter/material.dart';
import 'package:inventerization_4aas/constants/theme/app_colors.dart';
import 'package:inventerization_4aas/constants/theme/app_text_styles.dart';

class FilterDropdown extends StatefulWidget {
  final String title;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const FilterDropdown({
    Key? key,
    required this.title,
    required this.items,
    required this.onChanged,
  }) : super(key: key);

  @override
  State<FilterDropdown> createState() => _FilterDropdownState();
}

class _FilterDropdownState extends State<FilterDropdown> {
  late String? _selectedItem;

  @override
  void initState() {
    super.initState();
    if (widget.items.isNotEmpty) {
      _selectedItem = widget.items.first;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColor.elementColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: _selectedItem,
            isDense: true,
            icon: Icon(
              Icons.keyboard_arrow_down_outlined,
              size: 32,
              color: AppColor.textPrimary,
            ),
            items: widget.items.map((String item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Text(
                  item,
                  style: AppTextStyle.style16w400.copyWith(
                    color: AppColor.textPrimary,
                  ),
                ),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                _selectedItem = newValue;
              });
              widget.onChanged(newValue);
            },
          ),
        ),
      ),
    );
  }
}