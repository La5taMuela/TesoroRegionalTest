import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';
import 'dart:async';
import 'dart:ui' as ui;
import 'package:qr_flutter/qr_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:gal/gal.dart';
import 'package:tesoro_regional/core/services/i18n/app_localizations.dart';

class QRGeneratorPage extends StatefulWidget {
  const QRGeneratorPage({super.key});

  @override
  State<QRGeneratorPage> createState() => _QRGeneratorPageState();
}

class _QRGeneratorPageState extends State<QRGeneratorPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Lista predefinida de QRs de provincias
  final List<GeneratedQR> _provinceQRs = [
    GeneratedQR(
      code: 'PROVINCIA_ITATA_2024',
      keyword: 'Itata',
      generatedAt: DateTime.now().subtract(const Duration(days: 1)),
      displayContent: 'PROVINCIA_ITATA_2024',
      actualCode: 'PROVINCIA_ITATA_2024',
      description: 'Provincia famosa por sus viñedos y tradición vitivinícola ancestral.',
    ),
    GeneratedQR(
      code: 'PROVINCIA_DIGUILLIN_2024',
      keyword: 'Diguillín',
      generatedAt: DateTime.now().subtract(const Duration(days: 1)),
      displayContent: 'PROVINCIA_DIGUILLIN_2024',
      actualCode: 'PROVINCIA_DIGUILLIN_2024',
      description: 'Provincia que alberga la capital regional Chillán y las Termas de Chillán.',
    ),
    GeneratedQR(
      code: 'PROVINCIA_PUNILLA_2024',
      keyword: 'Punilla',
      generatedAt: DateTime.now().subtract(const Duration(days: 1)),
      displayContent: 'PROVINCIA_PUNILLA_2024',
      actualCode: 'PROVINCIA_PUNILLA_2024',
      description: 'Provincia con importantes recursos hídricos y tradiciones campesinas.',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 1, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    if (l10n == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('QR de Provincias'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: _buildProvinceQRsTab(l10n),
    );
  }

  Widget _buildProvinceQRsTab(AppLocalizations l10n) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildInfoCard(
          'Códigos QR de Provincias',
          'Escanea estos códigos QR para desbloquear las provincias de Ñuble en el mapa',
          Icons.map,
        ),
        const SizedBox(height: 24),
        ..._provinceQRs.map((qr) => _buildQRCard(qr, l10n)),
      ],
    );
  }

  Widget _buildInfoCard(String title, String description, IconData icon) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: TextStyle(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQRCard(GeneratedQR qr, AppLocalizations l10n) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Provincia de ${qr.keyword}',
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              qr.description,
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),

            Center(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(12),
                child: QrImageView(
                  data: qr.code,
                  version: QrVersions.auto,
                  size: 200.0,
                  backgroundColor: Colors.white,
                  errorStateBuilder: (context, error) {
                    return const Center(
                      child: Text(
                        'Error al generar QR',
                        style: TextStyle(color: Colors.red),
                      ),
                    );
                  },
                ),
              ),
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _copyQRToClipboard(qr),
                    icon: const Icon(Icons.copy, size: 16),
                    label: const Text('Copiar', style: TextStyle(fontSize: 12)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _saveQR(qr),
                    icon: const Icon(Icons.download, size: 16),
                    label: const Text('Guardar', style: TextStyle(fontSize: 12)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveQR(GeneratedQR qr) async {
    try {
      if (!await Gal.hasAccess()) {
        final hasAccess = await Gal.requestAccess();
        if (!hasAccess) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Se requiere permiso para acceder a la galería'),
                backgroundColor: Colors.red,
              ),
            );
          }
          return;
        }
      }

      final qrImage = await _generateQRImage(qr.code);
      final tempDir = await getTemporaryDirectory();
      final fileName = 'QR_${qr.keyword}_${DateTime.now().millisecondsSinceEpoch}.png';
      final file = File('${tempDir.path}/$fileName');

      await file.writeAsBytes(qrImage);
      await Gal.putImage(file.path);
      await file.delete();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('QR de ${qr.keyword} guardado en galería'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar QR: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<Uint8List> _generateQRImage(String data) async {
    final qrPainter = QrPainter(
      data: data,
      version: QrVersions.auto,
      gapless: true,
    );

    const size = 300.0;
    const imageSize = Size(size, size);

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    canvas.drawRect(
      const Rect.fromLTWH(0, 0, size, size),
      Paint()..color = Colors.white,
    );

    qrPainter.paint(canvas, imageSize);

    final picture = recorder.endRecording();
    final img = await picture.toImage(size.toInt(), size.toInt());
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);

    return byteData!.buffer.asUint8List();
  }

  void _copyQRToClipboard(GeneratedQR qr) {
    Clipboard.setData(ClipboardData(text: qr.code));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Código QR copiado al portapapeles'),
      ),
    );
  }
}

class GeneratedQR {
  final String code;
  final String keyword;
  final DateTime generatedAt;
  final String displayContent;
  final String actualCode;
  final String description;

  GeneratedQR({
    required this.code,
    required this.keyword,
    required this.generatedAt,
    this.displayContent = '',
    this.actualCode = '',
    this.description = '',
  });
}
