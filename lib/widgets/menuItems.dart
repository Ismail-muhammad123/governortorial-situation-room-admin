import 'package:flutter/material.dart';

class SideMenuItem extends StatelessWidget {
  final String label;
  final IconData menuIconData;
  final bool selected;
  final Color color;
  const SideMenuItem({
    super.key,
    required this.label,
    required this.menuIconData,
    this.selected = false,
    this.color = Colors.black,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            menuIconData,
            color: selected ? Colors.green : color,
          ),
          Text(
            label.toString(),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: selected ? Colors.green : color,
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.0),
            child: Divider(),
          ),
        ],
      ),
    );
  }
}
