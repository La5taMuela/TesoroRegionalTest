import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../domain/entities/province.dart';
class InteractiveNubleMap extends StatelessWidget {
  final Function(Province) onProvinceSelected;
  final String? selectedProvinceId;
  final List<String> collectedProvinces;

  const InteractiveNubleMap({
    super.key,
    required this.onProvinceSelected,
    this.selectedProvinceId,
    required this.collectedProvinces,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapUp: (details) {
        // Lógica para detectar qué provincia fue tocada
        // Esto depende de cómo esté estructurado tu SVG
      },
      child: SvgPicture.asset(
        'assets/maps/nuble_map.svg',
        semanticsLabel: 'Mapa de Ñuble',
        colorFilter: ColorFilter.mode(
          Colors.grey.withOpacity(0.3),
          BlendMode.srcIn,
        ),
        // Usar un widget más avanzado para manejar interacciones con SVG
      ),
    );
  }
}

// Clase de ayuda para provincias
class Province {
  final String id;
  final String name;
  final String color;
  final String svgPath;

  Province({
    required this.id,
    required this.name,
    required this.color,
    required this.svgPath,
  });
}