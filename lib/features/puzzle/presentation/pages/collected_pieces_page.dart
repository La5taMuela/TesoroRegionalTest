import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:tesoro_regional/core/services/storage/pieces_storage_service.dart';
import 'package:tesoro_regional/core/services/i18n/app_localizations.dart';

class CollectedPiecesPage extends StatefulWidget {
  const CollectedPiecesPage({super.key});

  @override
  State<CollectedPiecesPage> createState() => _CollectedPiecesPageState();
}

class _CollectedPiecesPageState extends State<CollectedPiecesPage> {
  final PiecesStorageService _piecesService = PiecesStorageService();
  List<String> _collectedPieces = [];
  Map<String, dynamic> _stats = {
    'total': 0,
    'mapPieces': 0,
    'qrPieces': 0,
    'percentage': 0,
  };

  @override
  void initState() {
    super.initState();
    _loadCollectedPieces();
  }

  Future<void> _loadCollectedPieces() async {
    final collectedPieces = await _piecesService.getCollectedPieces();
    final stats = await _piecesService.getPiecesStats();

    setState(() {
      _collectedPieces = collectedPieces.cast<String>();
      _stats = stats;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Piezas Colectadas'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadCollectedPieces,
            tooltip: 'Actualizar',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildProgressHeader(),
          Expanded(
            child: _buildPiecesContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.explore,
                color: Theme.of(context).primaryColor,
                size: 24,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Progreso Total',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_stats['total']} de 6 piezas colectadas (${_stats['percentage']}%)',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: _stats['percentage'] / 100,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).primaryColor,
              ),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildProgressItem(
                  'Mapa',
                  _stats['mapPieces'],
                  3,
                  Icons.map,
                  Colors.blue,
                ),
              ),
              Expanded(
                child: _buildProgressItem(
                  'QR Provincias',
                  _stats['qrPieces'],
                  3,
                  Icons.qr_code,
                  Colors.purple,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressItem(
      String title,
      int current,
      int total,
      IconData icon,
      Color color,
      ) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          '$current/$total',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: current == total ? Colors.green : Colors.grey[700],
          ),
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: current / total,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(
              current == total ? Colors.green : color,
            ),
            minHeight: 4,
          ),
        ),
      ],
    );
  }

  Widget _buildPiecesContent() {
    if (_collectedPieces.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            const Text(
              'No has colectado ninguna pieza',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Explora el mapa o escanea QRs para colectar piezas',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () => context.push('/map'),
                  icon: const Icon(Icons.map),
                  label: const Text('Explorar Mapa'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                ),
                const SizedBox(width: 16),

              ],
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Provincias Colectadas',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildProvincesGrid(),
          const SizedBox(height: 24),
          const Text(
            'Sitios Descubiertos',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildMapPiecesGrid(),
        ],
      ),
    );
  }

  Widget _buildProvincesGrid() {
    // Obtener todas las piezas QR
    final qrPieces = PiecesStorageService.allPieces
        .where((piece) => piece['type'] == 'qr')
        .toList();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.8,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: qrPieces.length,
      itemBuilder: (context, index) {
        final piece = qrPieces[index];
        final isCollected = _collectedPieces.contains(piece['id']);

        return _buildProvinceCard(piece, isCollected);
      },
    );
  }

  Widget _buildProvinceCard(Map<String, dynamic> piece, bool isCollected) {
    final svgPath = 'assets/nuble_svg/${piece['svgFile']}';

    return GestureDetector(
      onTap: () => _showPieceDetails(piece, isCollected),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: isCollected
                ? HexColor(piece['color'])
                : Colors.grey.withOpacity(0.3),
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 80,
              width: 80,
              padding: const EdgeInsets.all(8),
              child: SvgPicture.asset(
                svgPath,
                colorFilter: ColorFilter.mode(
                  isCollected
                      ? HexColor(piece['color'])
                      : Colors.grey.withOpacity(0.3),
                  BlendMode.srcIn,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              piece['name'],
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isCollected ? Colors.black87 : Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isCollected ? Icons.check_circle : Icons.lock,
                  size: 14,
                  color: isCollected ? Colors.green : Colors.grey,
                ),
                const SizedBox(width: 4),
                Text(
                  isCollected ? 'Colectada' : 'Bloqueada',
                  style: TextStyle(
                    fontSize: 12,
                    color: isCollected ? Colors.green : Colors.grey,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapPiecesGrid() {
    // Obtener todas las piezas del mapa
    final mapPieces = PiecesStorageService.allPieces
        .where((piece) => piece['type'] == 'map')
        .toList();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.8,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: mapPieces.length,
      itemBuilder: (context, index) {
        final piece = mapPieces[index];
        final isCollected = _collectedPieces.contains(piece['id']);

        return _buildMapPieceCard(piece, isCollected);
      },
    );
  }

  Widget _buildMapPieceCard(Map<String, dynamic> piece, bool isCollected) {
    return GestureDetector(
      onTap: () => _showPieceDetails(piece, isCollected),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: isCollected
                ? HexColor(piece['color'])
                : Colors.grey.withOpacity(0.3),
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 60,
              width: 60,
              decoration: BoxDecoration(
                color: isCollected
                    ? HexColor(piece['color']).withOpacity(0.2)
                    : Colors.grey.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getIconForType(piece['siteType']),
                color: isCollected
                    ? HexColor(piece['color'])
                    : Colors.grey.withOpacity(0.5),
                size: 32,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              piece['name'],
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isCollected ? Colors.black87 : Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isCollected ? Icons.check_circle : Icons.lock,
                  size: 14,
                  color: isCollected ? Colors.green : Colors.grey,
                ),
                const SizedBox(width: 4),
                Text(
                  isCollected ? 'Descubierto' : 'Bloqueado',
                  style: TextStyle(
                    fontSize: 12,
                    color: isCollected ? Colors.green : Colors.grey,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'plaza':
        return Icons.park;
      case 'market':
        return Icons.store;
      case 'religious':
        return Icons.church;
      case 'museum':
        return Icons.museum;
      case 'historical':
        return Icons.account_balance;
      default:
        return Icons.place;
    }
  }

  void _showPieceDetails(Map<String, dynamic> piece, bool isCollected) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              isCollected ? Icons.check_circle : Icons.lock,
              color: isCollected ? Colors.green : Colors.grey,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                piece['name'],
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (piece['type'] == 'qr') ...[
              Center(
                child: Container(
                  height: 120,
                  width: 120,
                  padding: const EdgeInsets.all(8),
                  child: SvgPicture.asset(
                    'assets/nuble_svg/${piece['svgFile']}',
                    colorFilter: ColorFilter.mode(
                      isCollected
                          ? HexColor(piece['color'])
                          : Colors.grey.withOpacity(0.3),
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
            ] else ...[
              Center(
                child: Container(
                  height: 80,
                  width: 80,
                  decoration: BoxDecoration(
                    color: isCollected
                        ? HexColor(piece['color']).withOpacity(0.2)
                        : Colors.grey.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _getIconForType(piece['siteType']),
                    color: isCollected
                        ? HexColor(piece['color'])
                        : Colors.grey.withOpacity(0.5),
                    size: 40,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 16),
            Text(
              'Tipo: ${piece['type'] == 'qr' ? 'Provincia (QR)' : 'Sitio Cultural (Mapa)'}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(piece['description']),
            const SizedBox(height: 16),
            if (!isCollected) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.amber,
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: Colors.amber,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        piece['type'] == 'qr'
                            ? 'Escanea el código QR de esta provincia para desbloquearla'
                            : 'Visita este lugar para desbloquearlo',
                        style: const TextStyle(
                          color: Colors.amber,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        actions: [
          if (piece['type'] == 'qr' && !isCollected)
            TextButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
                context.push('/qr-scanner');
              },
              icon: const Icon(Icons.qr_code_scanner),
              label: const Text('Escanear QR'),
            ),
          if (piece['type'] == 'map' && !isCollected)
            TextButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
                context.push('/map');
              },
              icon: const Icon(Icons.map),
              label: const Text('Ir al Mapa'),
            ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }
}

class HexColor extends Color {
  static int _getColorFromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF" + hexColor;
    }
    return int.parse(hexColor, radix: 16);
  }

  HexColor(final String hexColor) : super(_getColorFromHex(hexColor));
}
