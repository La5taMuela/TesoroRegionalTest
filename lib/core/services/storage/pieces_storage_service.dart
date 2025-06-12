import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class PiecesStorageService {
  static const String _collectedPiecesKey = 'collected_pieces';
  static const String _provincePiecesKey = 'province_pieces';

  // Province pieces data
  final Map<String, Map<String, dynamic>> _provincePieces = {
    'Itata': {
      'id': 'province_itata',
      'name': 'Provincia de Itata',
      'description': 'Provincia ubicada en la región de Ñuble, conocida por sus viñedos y tradiciones rurales.',
      'category': 'Provincias',
      'qrCode': 'Ñuble-Itata',
      'imageUrl': '/placeholder.svg?height=200&width=300',
      'isUnlocked': false,
    },
    'Diguillín': {
      'id': 'province_diguillin',
      'name': 'Provincia de Diguillín',
      'description': 'Provincia central de Ñuble, donde se encuentra la capital regional Chillán.',
      'category': 'Provincias',
      'qrCode': 'Ñuble-Diguillin',
      'imageUrl': '/placeholder.svg?height=200&width=300',
      'isUnlocked': false,
    },
    'Punilla': {
      'id': 'province_punilla',
      'name': 'Provincia de Punilla',
      'description': 'Provincia montañosa de Ñuble, famosa por sus termas y paisajes cordilleranos.',
      'category': 'Provincias',
      'qrCode': 'Ñuble-Punilla',
      'imageUrl': '/placeholder.svg?height=200&width=300',
      'isUnlocked': false,
    },
  };

  static const String _piecesKey = 'collected_pieces';

  // Definición de las 6 piezas
  static const List<Map<String, dynamic>> allPieces = [
    // Piezas del mapa (3)
    {
      'id': 'map_plaza_chillan',
      'name': 'Plaza de Armas de Chillán',
      'type': 'map',
      'siteType': 'plaza',
      'color': '#4CAF50',
      'description': 'Centro histórico de Chillán, punto de encuentro cultural y social.',
      'lat': -36.6062,
      'lng': -72.1025,
    },
    {
      'id': 'map_mercado_chillan',
      'name': 'Mercado de Chillán',
      'type': 'map',
      'siteType': 'market',
      'color': '#2196F3',
      'description': 'Mercado tradicional de la región, famoso por su gastronomía y artesanía local.',
      'lat': -36.6055,
      'lng': -72.1030,
    },
    {
      'id': 'map_catedral_chillan',
      'name': 'Catedral de Chillán',
      'type': 'map',
      'siteType': 'religious',
      'color': '#FF9800',
      'description': 'Patrimonio religioso de Chillán, reconstruida después del terremoto de 1939.',
      'lat': -36.6070,
      'lng': -72.1020,
    },
    // Piezas QR (3) - Provincias
    {
      'id': 'qr_provincia_itata',
      'name': 'Provincia de Itata',
      'type': 'qr',
      'svgFile': 'itata.svg',
      'color': '#9C27B0',
      'description': 'Provincia famosa por sus viñedos...',
      'qrCode': 'ÑUBLE-ITATA-2024',
    },
    {
      'id': 'qr_provincia_diguillin',
      'name': 'Provincia de Diguillín',
      'type': 'qr',
      'svgFile': 'diguillin.svg',
      'color': '#E91E63',
      'description': 'Provincia que alberga la capital regional...',
      'qrCode': 'ÑUBLE-DIGUILLIN-2024',
    },
    {
      'id': 'qr_provincia_punilla',
      'name': 'Provincia de Punilla',
      'type': 'qr',
      'svgFile': 'punilla.svg',
      'color': '#FF5722',
      'description': 'Provincia con importantes recursos hídricos...',
      'qrCode': 'ÑUBLE-PUNILLA-2024',
    },
  ];

  Future<List<Map<String, dynamic>>> getCollectedPieces() async {
    final prefs = await SharedPreferences.getInstance();
    final collectedPiecesJson = prefs.getStringList(_collectedPiecesKey) ?? [];
    final provincePiecesJson = prefs.getStringList(_provincePiecesKey) ?? [];

    List<Map<String, dynamic>> allPieces = [];

    // Add regular pieces
    for (String pieceJson in collectedPiecesJson) {
      try {
        allPieces.add(Map<String, dynamic>.from(json.decode(pieceJson)));
      } catch (e) {
        print('Error parsing piece: $e');
      }
    }

    // Add province pieces
    for (String pieceJson in provincePiecesJson) {
      try {
        allPieces.add(Map<String, dynamic>.from(json.decode(pieceJson)));
      } catch (e) {
        print('Error parsing province piece: $e');
      }
    }

    return allPieces;
  }

  Future<bool> collectPiece(String pieceId) async {
    final prefs = await SharedPreferences.getInstance();
    final collectedPieces = prefs.getStringList(_collectedPiecesKey) ?? [];

    // Check if piece is already collected
    for (String pieceJson in collectedPieces) {
      try {
        final piece = json.decode(pieceJson);
        if (piece['id'] == pieceId) {
          return false; // Already collected
        }
      } catch (e) {
        print('Error checking piece: $e');
      }
    }

    // Add new piece (this would normally come from a database)
    final newPiece = {
      'id': pieceId,
      'name': 'Pieza Cultural',
      'description': 'Una pieza cultural de la región de Ñuble.',
      'category': 'General',
      'collectedAt': DateTime.now().toIso8601String(),
      'isUnlocked': true,
    };

    collectedPieces.add(json.encode(newPiece));
    await prefs.setStringList(_collectedPiecesKey, collectedPieces);

    return true; // New piece collected
  }

  Future<bool> collectProvincePiece(String provinceName) async {
    final prefs = await SharedPreferences.getInstance();
    final provincePieces = prefs.getStringList(_provincePiecesKey) ?? [];

    // Check if province is already collected
    for (String pieceJson in provincePieces) {
      try {
        final piece = json.decode(pieceJson);
        if (piece['name'].contains(provinceName)) {
          return false; // Already collected
        }
      } catch (e) {
        print('Error checking province piece: $e');
      }
    }

    // Get province data
    final provinceData = _provincePieces[provinceName];
    if (provinceData == null) return false;

    // Mark as collected
    final collectedProvince = Map<String, dynamic>.from(provinceData);
    collectedProvince['isUnlocked'] = true;
    collectedProvince['collectedAt'] = DateTime.now().toIso8601String();

    provincePieces.add(json.encode(collectedProvince));
    await prefs.setStringList(_provincePiecesKey, provincePieces);

    return true; // New province collected
  }

  Future<bool> isPieceCollected(String pieceId) async {
    final collectedPieces = await getCollectedPieces();
    return collectedPieces.any((piece) => piece['id'] == pieceId);
  }

  Future<Map<String, dynamic>> getPiecesStats() async {
    final collectedPieces = await getCollectedPieces();
    final mapPieces = collectedPieces.where((piece) =>
    piece['type'] == 'map'
    ).length;
    final qrPieces = collectedPieces.where((piece) =>
    piece['type'] == 'qr'
    ).length;

    return {
      'total': collectedPieces.length,
      'mapPieces': mapPieces,
      'qrPieces': qrPieces,
      'percentage': (collectedPieces.length / allPieces.length * 100).round(),
    };
  }

  Map<String, dynamic>? getPieceById(String pieceId) {
    try {
      return allPieces.firstWhere((piece) => piece['id'] == pieceId);
    } catch (e) {
      return null;
    }
  }

  Map<String, dynamic>? getPieceByQRCode(String qrCode) {
    // Check province pieces first
    for (final entry in _provincePieces.entries) {
      if (entry.value['qrCode'] == qrCode) {
        return entry.value;
      }
    }

    // Could check other pieces here
    return null;
  }

  List<Map<String, dynamic>> getMapPieces() {
    return allPieces.where((piece) => piece['type'] == 'map').toList();
  }

  List<Map<String, dynamic>> getQRPieces() {
    return allPieces.where((piece) => piece['type'] == 'qr').toList();
  }

  Future<void> clearAllPieces() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_piecesKey);
  }

  Future<int> getCollectedCount() async {
    final pieces = await getCollectedPieces();
    return pieces.length;
  }

  Future<double> getCompletionPercentage() async {
    final collectedCount = await getCollectedCount();
    const totalPieces = 20; // Adjust based on total available pieces
    return (collectedCount / totalPieces) * 100;
  }
}
