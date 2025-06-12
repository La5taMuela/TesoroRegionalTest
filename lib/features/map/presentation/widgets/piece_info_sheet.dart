// piece_info_sheet.dart
import 'package:flutter/material.dart';
import 'package:tesoro_regional/features/map/domain/entities/strategic_point.dart';

class PieceInfoSheet extends StatelessWidget {
  final StrategicPoint point;
  final VoidCallback onUnlock;
  final bool isInRange;
  final String distance;

  const PieceInfoSheet({
    super.key,
    required this.point,
    required this.onUnlock,
    required this.isInRange,
    required this.distance,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            point.name,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            point.description,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          if (point.isUnlocked)
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check, color: Colors.green),
                  const SizedBox(width: 8),
                  Text(
                    'Pieza desbloqueada',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            )
          else
            ElevatedButton(
              onPressed: isInRange ? onUnlock : null,
              child: const Text('Desbloquear Pieza'),
            ),
          if (!isInRange && !point.isUnlocked)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Column(
                children: [
                  Text(
                    'Distancia actual: ${distance}m (requeridos ${point.activationRadius}m)',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: (double.tryParse(distance) ?? 0) /
                        point.activationRadius,
                    backgroundColor: Colors.grey[200],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
