import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tesoro_regional/core/utils/qr_validator.dart';
import 'package:tesoro_regional/core/services/storage/pieces_storage_service.dart';

abstract class QRScannerService {
  Future<String?> scanQR();
  Future<bool> requestCameraPermission();
  Future<bool> hasCameraPermission();
  Future<QRScanResult> validateAndProcessQR(String qrCode);
}

class QRScanResult {
  final bool isValid;
  final String? keyword;
  final String? errorMessage;
  final QRFormat format;
  final bool isPiece;
  final String? pieceId;
  final String? pieceName;

  QRScanResult({
    required this.isValid,
    this.keyword,
    this.errorMessage,
    required this.format,
    this.isPiece = false,
    this.pieceId,
    this.pieceName,
  });
}

enum QRFormat { legacy, structured, invalid }

class QRScannerServiceImpl implements QRScannerService {
  final PiecesStorageService _piecesService = PiecesStorageService();

  @override
  Future<bool> hasCameraPermission() async {
    final status = await Permission.camera.status;
    return status.isGranted;
  }

  @override
  Future<bool> requestCameraPermission() async {
    final status = await Permission.camera.request();
    return status.isGranted;
  }

  @override
  Future<String?> scanQR() async {
    try {
      // Check camera permission first
      if (!await hasCameraPermission()) {
        final granted = await requestCameraPermission();
        if (!granted) {
          throw PlatformException(
            code: 'PERMISSION_DENIED',
            message: 'Permiso de cámara denegado',
          );
        }
      }

      // This will be handled by the QRScannerPage widget
      // The actual scanning is done through the UI
      return null;

    } on PlatformException catch (e) {
      print('Error scanning QR: ${e.message}');
      return null;
    }
  }

  @override
  Future<QRScanResult> validateAndProcessQR(String qrCode) async {
    // First check if it's a collectible piece
    final piece = _piecesService.getPieceByQRCode(qrCode);

    if (piece != null) {
      // It's a collectible piece!
      final wasNewPiece = await _piecesService.collectPiece(piece['id']);

      return QRScanResult(
        isValid: true,
        keyword: qrCode,
        format: QRFormat.structured,
        isPiece: true,
        pieceId: piece['id'],
        pieceName: piece['name'],
        errorMessage: wasNewPiece
            ? '¡Pieza colectada: ${piece['name']}!'
            : 'Ya tienes esta pieza: ${piece['name']}',
      );
    }

    // If not a piece, validate as regular QR
    if (!QRValidator.isValidTesoroRegionalCode(qrCode)) {
      return QRScanResult(
        isValid: false,
        errorMessage: QRValidator.getValidationErrorMessage(qrCode),
        format: QRFormat.invalid,
      );
    }

    final keyword = QRValidator.extractKeyword(qrCode);
    final format = QRValidator.isStructuredFormat(qrCode)
        ? QRFormat.structured
        : QRFormat.legacy;

    return QRScanResult(
      isValid: true,
      keyword: keyword,
      format: format,
    );
  }
}
