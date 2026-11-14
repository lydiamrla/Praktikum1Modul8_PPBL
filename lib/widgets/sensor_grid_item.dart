import 'package:flutter/material.dart';
import '../models/sensor_info.dart';
import '../theme/app_theme.dart';

class SensorGridItem extends StatelessWidget {
  final SensorInfo sensor;
  final VoidCallback onTap;

  const SensorGridItem({
    super.key,
    required this.sensor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Icon(
                  sensor.ikon,
                  size: 30,
                  color: AppTheme.navyPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                sensor.nama,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
              Text(
                '${sensor.nilaiTerkini} ${sensor.satuan}',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: sensor.isDarurat
                      ? AppTheme.alertRed
                      : AppTheme.tealAccent,
                ),
              ),
            ],
          ),
          if (sensor.isDarurat)
            Positioned(
              top: -4,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.alertRed,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Darurat',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}