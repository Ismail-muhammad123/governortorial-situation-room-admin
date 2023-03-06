import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ProgressBarWidget extends StatelessWidget {
  final String label;
  final double maxValue, value;
  final Color backgroundColor, progressColor;
  const ProgressBarWidget({
    super.key,
    required this.label,
    required this.maxValue,
    required this.value,
    this.backgroundColor = Colors.green,
    this.progressColor = const Color.fromARGB(255, 6, 75, 10),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                "${NumberFormat('###,###,###,###').format(value)} of ${NumberFormat('###,###,###,###').format(maxValue)}", // TODO format the numbers
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          Stack(
            children: [
              Container(
                height: 6,
                width: double.maxFinite,
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              Container(
                height: 6,
                width: (value / maxValue) * 800,
                decoration: BoxDecoration(
                  color: progressColor,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
