// RF-0303: Incident type chips widget
import 'package:flutter/material.dart';

import '../../domain/constants/incident_types.dart';

class IncidentTypeChipsWidget extends StatefulWidget {
  final Function(String) onSelected;
  final String? selectedType;

  const IncidentTypeChipsWidget({
    super.key,
    required this.onSelected,
    this.selectedType,
  });

  @override
  State<IncidentTypeChipsWidget> createState() =>
      _IncidentTypeChipsWidgetState();
}

class _IncidentTypeChipsWidgetState extends State<IncidentTypeChipsWidget> {
  String? _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.selectedType;
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: kIncidentTypes.map((type) {
        final isSelected = _selected == type['value'];
        return FilterChip(
          label: Text(type['label']!),
          selected: isSelected,
          onSelected: (selected) {
            setState(() => _selected = selected ? type['value'] : null);
            widget.onSelected(type['value']!);
          },
        );
      }).toList(),
    );
  }
}
