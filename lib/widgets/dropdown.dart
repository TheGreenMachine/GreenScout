import 'package:flutter/material.dart';
import 'package:green_scout/utils/reference.dart';

class Dropdown<V> extends StatefulWidget {
  const Dropdown({
    super.key,
    required this.entries,
    required this.inValue,
    required this.defaultValue,
    required this.textStyle,
    this.padding,
    this.menuMaxHeight,
    this.onTap,
    this.isDense = false,
    this.isExpanded = false,
    this.alignment = AlignmentDirectional.centerStart,
    this.setState,
  });

  final Map<String, V> entries;
  final Reference<V>? inValue;
  final V defaultValue;

  final TextStyle? textStyle;

  final EdgeInsetsGeometry? padding;
  final double? menuMaxHeight;

  final Function()? onTap;
  final bool isDense;
  final bool isExpanded;

  final void Function()? setState;

  final AlignmentGeometry alignment;

  @override
  State<Dropdown> createState() => _Dropdown<V>();
}

class _Dropdown<V> extends State<Dropdown> {
  List<DropdownMenuItem<V>> items = [];

  @override
  void initState() {
    super.initState();

    for (var entry in widget.entries.entries) {
      items.add(
        DropdownMenuItem(
          value: entry.value,
          alignment: widget.alignment,
          child: Text(
            entry.key,
            style: widget.textStyle,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButton<V>(
      padding: widget.padding,
      menuMaxHeight: widget.menuMaxHeight,
      onTap: widget.onTap,
      style: widget.textStyle,
      isDense: widget.isDense,
      isExpanded: widget.isExpanded,
      alignment: widget.alignment,
      borderRadius: BorderRadius.circular(10),
      items: items,
      value: widget.inValue != null ? (widget.inValue!.value) : null,
      onChanged: (newValue) => setState(() {
        if (widget.inValue == null) {
          return;
        }

        widget.inValue!.value = newValue ?? widget.defaultValue;

        if (widget.setState != null) {
          widget.setState!();
        }
      }),
    );
  }
}
