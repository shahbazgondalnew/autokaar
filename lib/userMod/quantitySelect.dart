import 'package:flutter/material.dart';

class QuantitySelector extends StatefulWidget {
  final int initialQuantity;
  final void Function(int) onChanged;
  //quantity

  QuantitySelector({required this.initialQuantity, required this.onChanged});

  @override
  _QuantitySelectorState createState() => _QuantitySelectorState();
}

class _QuantitySelectorState extends State<QuantitySelector> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller =
        TextEditingController(text: widget.initialQuantity.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text('Quantity: '),
        SizedBox(
          width: 60,
          child: TextField(
            keyboardType: TextInputType.number,
            controller: _controller,
            onChanged: (value) {
              final int parsedValue = int.tryParse(value) ?? 0;
              widget.onChanged(parsedValue);
            },
          ),
        ),
      ],
    );
  }
}
