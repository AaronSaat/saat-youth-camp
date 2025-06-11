import 'package:flutter/material.dart';

class CustomSingleChoice extends StatefulWidget {
  final List<String> options;
  final ValueChanged<String> onSelected;
  final String? selectedValue;

  const CustomSingleChoice({
    Key? key,
    required this.options,
    required this.onSelected,
    this.selectedValue,
  }) : super(key: key);

  @override
  State<CustomSingleChoice> createState() => _CustomSingleChoiceState();
}

class _CustomSingleChoiceState extends State<CustomSingleChoice> {
  String? _selectedValue;

  @override
  void initState() {
    super.initState();
    _selectedValue = widget.selectedValue;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...List.generate(widget.options.length, (index) {
          final value = widget.options[index];
          final isSelected = _selectedValue == value;
          return ListTile(
            leading: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.black, width: 2),
                color: Colors.white,
              ),
              child:
                  isSelected
                      ? Center(
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      )
                      : null,
            ),
            title: Text(value, style: const TextStyle(color: Colors.white)),
            onTap: () {
              setState(() {
                _selectedValue = value;
              });
              widget.onSelected(value);
            },
            contentPadding: EdgeInsets.zero,
            visualDensity: VisualDensity.compact,
          );
        }),
      ],
    );
  }
}
