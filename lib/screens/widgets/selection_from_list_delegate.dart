import 'package:flutter/material.dart';
import 'package:inventerization_4aas/constants/theme/app_colors.dart';

class SelectFromListDelegate extends SearchDelegate<String?> {

  final List<String> listOfStrings;

  SelectFromListDelegate(this.listOfStrings);

  @override
  List<Widget> buildActions(BuildContext context) => [
    IconButton(icon: const Icon(Icons.clear), onPressed: () => query = ''),
  ];

  @override
  Widget buildLeading(BuildContext context) => IconButton(
    icon: const Icon(Icons.arrow_back),
    onPressed: Navigator.of(context).pop,
  );

  @override
  Widget buildResults(BuildContext context) {
    final filtered = listOfStrings
        .where(
          (c) => c.toLowerCase().contains(query.toLowerCase()),
        )
        .take(100)
        .toList();

    return _buildList(filtered);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final filtered = listOfStrings
        .where(
          (c) => c.toLowerCase().contains(query.toLowerCase()),
        )
        .take(100)
        .toList();

    return _buildList(filtered);
  }

  Widget _buildList(List<String> list) {
    return ListView.builder(
      itemCount: list.length,
      itemBuilder: (context, i) {
        final element = list[i];
        return ListTile(
          tileColor: i % 2 == 0 ? AppColor.elementColor : Colors.transparent,
          title: Text(element),
          onTap: () {
            close(context, element);
          },
        );
      },
    );
  } 
}

