import 'package:flutter/material.dart';

class FilterDialog extends StatefulWidget {
  final double minPrice;
  final double maxPrice;
  final double selectedMaxPrice;
  final void Function(double selectedMaxPrice) onApply;

  const FilterDialog({
    super.key,
    required this.minPrice,
    required this.maxPrice,
    required this.selectedMaxPrice,
    required this.onApply,
  });

  @override
  State<FilterDialog> createState() => _FilterDialogState();
}

class _FilterDialogState extends State<FilterDialog> {
  late double currentMax;

  @override
  void initState() {
    super.initState();
    currentMax = widget.selectedMaxPrice;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Filtru după preț"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Preț maxim: ${currentMax.toStringAsFixed(0)} €",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Slider(
            value: currentMax,
            min: widget.minPrice,
            max: widget.maxPrice,
            divisions: ((widget.maxPrice - widget.minPrice) / 5).round(),
            label: "${currentMax.toStringAsFixed(0)} €",
            onChanged: (value) {
              setState(() {
                currentMax = value;
              });
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Anulează"),
        ),
        ElevatedButton(
          onPressed: () {
            widget.onApply(currentMax);
            Navigator.pop(context);
          },
          child: const Text("Aplică"),
        ),
      ],
    );
  }
}
