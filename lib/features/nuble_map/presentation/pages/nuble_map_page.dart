import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tesoro_regional/core/services/i18n/app_localizations.dart';
import '../widgets/interactive_nuble_map.dart' hide Province;
import '../../domain/entities/province.dart';
import '../../data/nuble_data.dart';

class NubleMapPage extends StatefulWidget {
  const NubleMapPage({super.key});

  @override
  State<NubleMapPage> createState() => _NubleMapPageState();
}

class _NubleMapPageState extends State<NubleMapPage> {
  String? _selectedProvinceId;

  void _onProvinceSelected(Province province) {
    setState(() {
      _selectedProvinceId = province.id;
    });


  }

  void _showProvinceDialog(Province province) {
    final l10n = AppLocalizations.of(context);
    final languageCode = l10n?.locale.languageCode ?? 'es';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(province.getName(languageCode)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Capital: ${province.capital}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(province.getDescription(languageCode)),
            const SizedBox(height: 12),
            Text(
              '${province.cities.length} ciudades para explorar',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n?.cancel ?? 'Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.go('/province/${province.id}');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(int.parse(province.color.replaceFirst('#', '0xFF'))),
              foregroundColor: Colors.white,
            ),
            child: Text(l10n?.exploreProvince ?? 'Explorar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) return;
        context.go('/');
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n?.nubleMap ?? 'Mapa de Ñuble'),
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/'),
          ),
        ),
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isLargeScreen = constraints.maxWidth > 800;
              final maxWidth = isLargeScreen ? 1200.0 : double.infinity;

              return Center(
                child: Container(
                  constraints: BoxConstraints(maxWidth: maxWidth),
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Padding(
                      padding: EdgeInsets.all(isLargeScreen ? 32 : 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Título y descripción
                          Container(
                            padding: EdgeInsets.all(isLargeScreen ? 24 : 16),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Theme.of(context).primaryColor,
                                  Theme.of(context).primaryColor.withAlpha(204),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.map,
                                  size: isLargeScreen ? 64 : 48,
                                  color: Colors.white,
                                ),
                                SizedBox(height: isLargeScreen ? 16 : 12),
                                Text(
                                  l10n?.nubleRegion ?? 'Región de Ñuble',
                                  style: TextStyle(
                                    fontSize: isLargeScreen ? 28 : 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: isLargeScreen ? 12 : 8),
                                Text(
                                  l10n?.selectProvince ?? 'Selecciona una provincia para explorarla',
                                  style: TextStyle(
                                    fontSize: isLargeScreen ? 16 : 14,
                                    color: Colors.white70,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: isLargeScreen ? 40 : 32),

                          // Mapa interactivo
                          Container(
                            height: isLargeScreen ? 500 : 400,
                            child: InteractiveNubleMap(
                              selectedProvinceId: _selectedProvinceId, collectedProvinces: [], onProvinceSelected: (Province ) {  },
                            ),
                          ),

                          SizedBox(height: isLargeScreen ? 24 : 16),

                          // Botones de provincias
                          _buildProvinceButtons(context, isLargeScreen),

                          SizedBox(height: isLargeScreen ? 24 : 16),

                          // Instrucciones
                          Container(
                            padding: EdgeInsets.all(isLargeScreen ? 20 : 16),
                            decoration: BoxDecoration(
                              color: Colors.blue[50],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.blue[200]!),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  color: Colors.blue[700],
                                  size: isLargeScreen ? 24 : 20,
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Haz clic en los botones de las provincias para explorar sus detalles.',
                                    style: TextStyle(
                                      fontSize: isLargeScreen ? 14 : 12,
                                      color: Colors.blue[700],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildProvinceButtons(BuildContext context, bool isLargeScreen) {
    final l10n = AppLocalizations.of(context);
    final languageCode = l10n?.locale.languageCode ?? 'es';

    return Wrap(
      spacing: isLargeScreen ? 20 : 12,
      runSpacing: isLargeScreen ? 16 : 12,
      alignment: WrapAlignment.center,
      children: NubleData.provinces.map((province) {
        final isSelected = _selectedProvinceId == province.id;

        return ElevatedButton(
          onPressed: () => _onProvinceSelected(province),
          style: ElevatedButton.styleFrom(
            backgroundColor: isSelected
                ? Color(int.parse(province.color.replaceFirst('#', '0xFF')))
                : Colors.white,
            foregroundColor: isSelected ? Colors.white : Colors.grey[800],
            padding: EdgeInsets.symmetric(
              horizontal: isLargeScreen ? 24 : 16,
              vertical: isLargeScreen ? 16 : 12,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(
                color: Color(int.parse(province.color.replaceFirst('#', '0xFF'))),
                width: 2,
              ),
            ),
            elevation: 4,
            shadowColor: Colors.black.withOpacity(0.1),
          ),
          child: Text(
            province.getName(languageCode),
            style: TextStyle(
              fontSize: isLargeScreen ? 16 : 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      }).toList(),
    );
  }

}
