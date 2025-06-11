import 'package:flutter/material.dart';

class CustomMultipleChoice extends StatefulWidget {
  final List<String> options;
  final ValueChanged<List<String>> onSelected;
  final List<String>? selectedValues;

  const CustomMultipleChoice({
    Key? key,
    required this.options,
    required this.onSelected,
    this.selectedValues,
  }) : super(key: key);

  @override
  State<CustomMultipleChoice> createState() => _CustomMultipleChoiceState();
}

class _CustomMultipleChoiceState extends State<CustomMultipleChoice> {
  late List<String> _selectedValues;

  @override
  void initState() {
    super.initState();
    _selectedValues =
        widget.selectedValues != null
            ? List<String>.from(widget.selectedValues!)
            : [];
  }

  void _onOptionTapped(String value) {
    setState(() {
      if (_selectedValues.contains(value)) {
        _selectedValues.remove(value);
      } else {
        _selectedValues.add(value);
      }
    });
    widget.onSelected(_selectedValues);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...List.generate(widget.options.length, (index) {
          final value = widget.options[index];
          final isSelected = _selectedValues.contains(value);
          return ListTile(
            leading: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.rectangle,
                border: Border.all(color: Colors.black, width: 2),
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
              child:
                  isSelected
                      ? Center(
                        child: Icon(
                          Icons.check,
                          size: 18,
                          color: Theme.of(context).primaryColor,
                        ),
                      )
                      : null,
            ),
            title: Text(value, style: const TextStyle(color: Colors.white)),
            onTap: () => _onOptionTapped(value),
            contentPadding: EdgeInsets.zero,
            visualDensity: VisualDensity.compact,
          );
        }),
      ],
    );
  }
}
