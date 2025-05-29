import 'package:flutter/material.dart';

class FiltersHorizontal extends StatelessWidget {
  final List<String> filters;
  final Set<String> selected;
  final Function(String) onToggle;

  const FiltersHorizontal({
    required this.filters,
    required this.selected,
    required this.onToggle,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = selected.contains(filter);
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: FilterChip(
              label: Text(filter),
              selected: isSelected,
              onSelected: (_) => onToggle(filter),
            ),
          );
        },
      ),
    );
  }
}
