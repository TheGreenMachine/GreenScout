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
    this.onChanged,
    this.changeOnNewValue = false,
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
  final Function()? onChanged;
  final bool changeOnNewValue;

  final bool isDense;
  final bool isExpanded;

  final void Function()? setState;

  final AlignmentGeometry alignment;

  @override
  State<Dropdown> createState() => _Dropdown<V>();
}

class _Dropdown<V> extends State<Dropdown> {
  List<DropdownMenuItem<V>> items = [];

  FocusNode node = FocusNode();

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
      onTap: () {
        node.unfocus();
        if (widget.onTap != null) {
          widget.onTap!.call();
        }
      },
      style: widget.textStyle,
      isDense: widget.isDense,
      isExpanded: widget.isExpanded,
      alignment: widget.alignment,
      borderRadius: BorderRadius.circular(10),
      items: items,
      value: widget.inValue != null ? (widget.inValue!.value) : null,
      focusNode: node,
      onChanged: (newValue) => setState(() {
        if (widget.inValue == null) {
          return;
        }

        if (widget.onChanged != null && newValue != widget.inValue!.value) {
          if (widget.changeOnNewValue) {
            widget.inValue!.value = newValue ?? widget.defaultValue;
          }
          widget.onChanged!.call();
        }

        if (!widget.changeOnNewValue) {
          widget.inValue!.value = newValue ?? widget.defaultValue;
        }

        if (widget.setState != null) {
          widget.setState!();
        }
      }),
    );
  }
}
