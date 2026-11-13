import 'package:flutter/material.dart';

import '../utils/risk_advisor.dart';

class AdviceCard extends StatelessWidget {
  final Advice advice;

  const AdviceCard({super.key, required this.advice});

  @override
  Widget build(BuildContext context) {
    Color color;
    IconData icon;

    switch (advice.level) {
      case RiskLevel.high:
        color = Colors.red.shade50;
        icon = Icons.warning_amber_rounded;
        break;
      case RiskLevel.medium:
        color = Colors.orange.shade50;
        icon = Icons.info_outline;
        break;
      case RiskLevel.low:
        color = Colors.green.shade50;
        icon = Icons.check_circle_outline;
        break;
    }

    return Card(
      color: color,
      child: ListTile(
        leading: Icon(icon, color: Colors.black87),
        title: Text(advice.title,
            style: const TextStyle(
                fontWeight: FontWeight.bold, color: Colors.black87)),
        subtitle:
            Text(advice.message, style: const TextStyle(color: Colors.black87)),
      ),
    );
  }
}
