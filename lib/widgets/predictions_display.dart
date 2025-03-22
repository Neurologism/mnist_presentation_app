import 'package:flutter/material.dart';

class PredictionsDisplay extends StatelessWidget {
  const PredictionsDisplay({super.key, required this.predictions, this.height});

  final Map<int, double> predictions;
  final double? height;

  String toPercent(double value) {
    return '${(value * 100).toStringAsFixed(2)}%';
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SizedBox(
          height: height,
          child: Row(
            children: predictions.entries.map((entry) {
              // Calculate the height based on the prediction value
              final double progressPercentage = entry.value;

              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 1.0),
                  child: Container(
                    color: Colors.grey[300],
                    child: Stack(
                      alignment: Alignment.bottomCenter,
                      children: [
                        FractionallySizedBox(
                          heightFactor: progressPercentage,
                          widthFactor: 1.0,
                          alignment: Alignment.bottomCenter,
                          child: Container(
                            color: Colors.blue,
                          ),
                        ),
                        // Text overlay
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                entry.key.toString(),
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                (entry.value).toStringAsFixed(2),
                                style: const TextStyle(
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}