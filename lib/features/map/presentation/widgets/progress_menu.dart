import 'package:flutter/material.dart';
import 'package:tesoro_regional/features/map/domain/entities/strategic_point.dart';

class ProgressMenu extends StatelessWidget {
  final List<StrategicPoint> points;
  final VoidCallback onClose;

  const ProgressMenu({
    super.key,
    required this.points,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final unlockedPoints = points.where((p) => p.isUnlocked).length;
    final totalPoints = points.length;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Progreso: $unlockedPoints/$totalPoints piezas',
                style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            SizedBox(
              width: 200,
              height: 300,
              child: ListView.builder(
                itemCount: points.length,
                itemBuilder: (ctx, index) {
                  final point = points[index];
                  return ListTile(
                    leading: point.isUnlocked
                        ? const Icon(Icons.check_circle, color: Colors.green)
                        : const Icon(Icons.lock, color: Colors.grey),
                    title: Text(point.name),
                    subtitle: Text(point.description),
                  );
                },
              ),
            ),
            TextButton(
              onPressed: onClose,
              child: const Text('Cerrar'),
            ),
          ],
        ),
      ),
    );
  }
}