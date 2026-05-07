// RF-0303: Incident type chips widget
import 'package:flutter/material.dart';

class IncidentTypeChipsWidget extends StatefulWidget {
  final Function(String) onSelected;
  final String? selectedType;

  const IncidentTypeChipsWidget({
    Key? key,
    required this.onSelected,
    this.selectedType,
  }) : super(key: key);

  @override
  State<IncidentTypeChipsWidget> createState() => _IncidentTypeChipsWidgetState();
}

class _IncidentTypeChipsWidgetState extends State<IncidentTypeChipsWidget> {
  String? _selected;

  final List<Map<String, String>> _types = [
    {'label': 'Robo', 'value': 'robo'},
    {'label': 'Accidente', 'value': 'accidente'},
    {'label': 'Sospechoso', 'value': 'sospechoso'},
    {'label': 'Daño vial', 'value': 'daño_vial'},
    {'label': 'Otro', 'value': 'otro'},
  ];

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
      children: _types.map((type) {
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
