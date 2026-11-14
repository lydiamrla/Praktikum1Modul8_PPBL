import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class StatusSiagaBadge extends StatelessWidget {
  final String status;

  const StatusSiagaBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color warnaBadge;
    if (status == 'SIAGA') {
      warnaBadge = AppTheme.alertRed;
    } else if (status == 'WASPADA') {
      warnaBadge = Colors.orange.shade700;
    } else {
      warnaBadge = AppTheme.tealAccent;
    }

    return Container(
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: warnaBadge,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.shield_outlined, size: 14, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            status,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}