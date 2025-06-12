import 'package:flutter/material.dart';

class MapLayersMenu extends StatelessWidget {
  final Function(String) onLayerSelected;
  final VoidCallback onClose;

  const MapLayersMenu({
    super.key,
    required this.onLayerSelected,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 250, // Ancho fijo para evitar problemas de layout
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text('Tipo de Mapa',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.6,
                  maxWidth: 250, // Añadir límite de ancho
                ),
                child: ListView.builder( // Usar builder para mejor rendimiento
                  shrinkWrap: true,
                  itemCount: 3,
                  itemBuilder: (context, index) {
                    final options = [
                      ['OpenStreetMap', 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png'],
                      ['Satélite', 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}'],
                      ['Topográfico', 'https://{s}.tile.opentopomap.org/{z}/{x}/{y}.png']
                    ];
                    return _buildLayerOption(options[index][0], options[index][1]);
                  },
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: TextButton(
                  onPressed: onClose,
                  child: const Text('Cerrar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLayerOption(String name, String url) {
    return ListTile(
      title: Text(name),
      onTap: () => onLayerSelected(url),
    );
  }
}