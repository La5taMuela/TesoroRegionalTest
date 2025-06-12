import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tesoro_regional/core/services/storage/pieces_storage_service.dart';

class ItataMapWidget extends StatelessWidget {
  final List<String> collectedPieces;
  final Function(String) onPieceInfo;

  const ItataMapWidget({
    super.key,
    required this.collectedPieces,
    required this.onPieceInfo,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (details) {
        _handleTap(context, details.localPosition);
      },
      child: Container(
        width: double.infinity,
        height: double.infinity,
        child: Stack(
          children: [
            // SVG Base
            SvgPicture.string(
              _getColoredSvg(),
              fit: BoxFit.contain,
            ),
            // Overlay con información de piezas
            ..._buildPieceOverlays(context),
          ],
        ),
      ),
    );
  }

  String _getColoredSvg() {
    String svgContent = '''<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<svg xmlns="http://www.w3.org/2000/svg" width="550" height="430" version="1.0">
  <g id="itata">
    <title>Provincia de Itata</title>
    ${_getPathForElement('Ranquil', 'M50,50 L150,50 L150,150 L50,150 Z')}
    ${_getPathForElement('Portezuelo', 'M170,50 L270,50 L270,150 L170,150 Z')}
    ${_getPathForElement('Ninhue', 'M290,50 L390,50 L390,150 L290,150 Z')}
    ${_getPathForElement('Coelemu', 'M50,170 L150,170 L150,270 L50,270 Z')}
    ${_getPathForElement('Treguaco', 'M170,170 L270,170 L270,270 L170,270 Z')}
    ${_getPathForElement('Quirihue', 'M290,170 L390,170 L390,270 L290,270 Z')}
    ${_getPathForElement('Cobquecura', 'M120,290 L320,290 L320,380 L120,380 Z')}
  </g>
</svg>''';
    return svgContent;
  }

  String _getPathForElement(String elementId, String pathData) {
    final piece = PiecesStorageService.allPieces.firstWhere(
          (p) => p['svgElement'] == elementId,
      orElse: () => {},
    );

    String fillColor = '#fbeebe'; // Color por defecto
    if (piece.isNotEmpty && collectedPieces.contains(piece['id'])) {
      fillColor = piece['color'];
    }

    return '''<path
      d="$pathData"
      style="fill:$fillColor;fill-opacity:0.8;stroke:#d39062;stroke-width:2;stroke-opacity:1"
      id="$elementId" />''';
  }

  List<Widget> _buildPieceOverlays(BuildContext context) {
    List<Widget> overlays = [];

    // Posiciones aproximadas para cada elemento del SVG
    final Map<String, Offset> positions = {
      'Ranquil': const Offset(0.18, 0.23),
      'Portezuelo': const Offset(0.44, 0.23),
      'Ninhue': const Offset(0.71, 0.23),
      'Coelemu': const Offset(0.18, 0.51),
      'Treguaco': const Offset(0.44, 0.51),
      'Quirihue': const Offset(0.71, 0.51),
      'Cobquecura': const Offset(0.44, 0.79),
    };

    for (final piece in PiecesStorageService.allPieces) {
      final elementId = piece['svgElement'];
      final position = positions[elementId];
      if (position != null) {
        final isCollected = collectedPieces.contains(piece['id']);
        overlays.add(
          Positioned(
            left: position.dx * 400 - 12, // Ajustar según el tamaño del SVG
            top: position.dy * 300 - 12,
            child: GestureDetector(
              onTap: () => onPieceInfo(piece['id']),
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: isCollected
                      ? Color(int.parse(piece['color'].replaceFirst('#', '0xFF')))
                      : Colors.grey[400],
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  isCollected
                      ? (piece['type'] == 'map' ? Icons.place : Icons.qr_code)
                      : Icons.lock,
                  color: Colors.white,
                  size: 14,
                ),
              ),
            ),
          ),
        );
      }
    }

    return overlays;
  }

  void _handleTap(BuildContext context, Offset localPosition) {
    // Convertir posición local a coordenadas relativas del SVG
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final relativeX = localPosition.dx / size.width;
    final relativeY = localPosition.dy / size.height;

    // Detectar qué elemento fue tocado basado en las coordenadas
    final Map<String, Rect> hitBoxes = {
      'Ranquil': const Rect.fromLTWH(0.09, 0.12, 0.18, 0.23),
      'Portezuelo': const Rect.fromLTWH(0.31, 0.12, 0.18, 0.23),
      'Ninhue': const Rect.fromLTWH(0.53, 0.12, 0.18, 0.23),
      'Coelemu': const Rect.fromLTWH(0.09, 0.40, 0.18, 0.23),
      'Treguaco': const Rect.fromLTWH(0.31, 0.40, 0.18, 0.23),
      'Quirihue': const Rect.fromLTWH(0.53, 0.40, 0.18, 0.23),
      'Cobquecura': const Rect.fromLTWH(0.22, 0.67, 0.36, 0.21),
    };

    for (final entry in hitBoxes.entries) {
      if (entry.value.contains(Offset(relativeX, relativeY))) {
        final piece = PiecesStorageService.allPieces.firstWhere(
              (p) => p['svgElement'] == entry.key,
          orElse: () => {},
        );
        if (piece.isNotEmpty) {
          onPieceInfo(piece['id']);
        }
        break;
      }
    }
  }
}
