import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tesoro_regional/core/providers/locale_provider.dart';
import 'package:tesoro_regional/core/services/i18n/app_localizations.dart';
import 'package:tesoro_regional/features/settings/presentation/pages/about_page.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(localeProvider);
    final l10n = AppLocalizations.of(context);

    // Verificación de null safety
    if (l10n == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Configuración'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/'),
          ),
        ),
        body: const Center(
          child: Text('Cargando traducciones...'),
        ),
      );
    }

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) return;
        context.go('/');
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.settings),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/'),
          ),
        ),
        body: ListView(
          children: [
            _buildHeader(context, l10n),
            const Divider(),
            _buildLanguageSection(context, ref, currentLocale, l10n),
            const Divider(),
            _buildAboutSection(context, l10n),
            if (kIsWeb) ...[
              const Divider(),
              _buildWebDownloadSection(context),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.settings,
              size: 40,
              color: Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.settings,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.settingsSubtitle,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageSection(
      BuildContext context,
      WidgetRef ref,
      Locale currentLocale,
      AppLocalizations l10n
      ) {
    return _buildSection(
      context,
      l10n.language,
      [
        _buildLanguageSelector(context, ref, currentLocale, l10n),
      ],
    );
  }

  Widget _buildLanguageSelector(
      BuildContext context,
      WidgetRef ref,
      Locale currentLocale,
      AppLocalizations l10n
      ) {
    final localeNotifier = ref.read(localeProvider.notifier);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Theme.of(context).cardColor,
      ),
      child: ExpansionTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.language,
            color: Theme.of(context).primaryColor,
          ),
        ),
        title: Text(l10n.language),
        subtitle: Text(localeNotifier.getLocaleName(currentLocale)),
        children: [
          _buildLocaleOption(
            context,
            ref,
            const Locale('es', 'CL'),
            currentLocale.languageCode == 'es',
            l10n,
          ),
          _buildLocaleOption(
            context,
            ref,
            const Locale('en', 'US'),
            currentLocale.languageCode == 'en',
            l10n,
          ),
        ],
      ),
    );
  }

  Widget _buildLocaleOption(
      BuildContext context,
      WidgetRef ref,
      Locale locale,
      bool isSelected,
      AppLocalizations l10n,
      ) {
    final localeNotifier = ref.read(localeProvider.notifier);
    final languageName = locale.languageCode == 'es'
        ? l10n.spanish
        : l10n.english;

    return ListTile(
      leading: Icon(
        Icons.language,
        color: isSelected
            ? Theme.of(context).primaryColor
            : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
      ),
      title: Text(languageName),
      trailing: isSelected
          ? Icon(
        Icons.check,
        color: Theme.of(context).primaryColor,
      )
          : null,
      onTap: () {
        localeNotifier.setLocale(locale);

        // Mostrar mensaje después de un breve retraso para que se actualice el idioma
        Future.delayed(const Duration(milliseconds: 100), () {
          final newL10n = AppLocalizations.of(context);
          if (newL10n != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(newL10n.languageChanged),
                duration: const Duration(seconds: 2),
              ),
            );
          }
        });
      },
    );
  }

  Widget _buildWebDownloadSection(BuildContext context) {
    return _buildSection(
      context,
      'Descargar Aplicación',
      [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.blue.withOpacity(0.1),
                Colors.green.withOpacity(0.1),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.blue.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.android,
                      color: Colors.blue,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tesoro Regional',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Versión Android',
                          style: TextStyle(
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
              const Text(
                'Descarga la aplicación completa para Android y disfruta de todas las funcionalidades sin conexión:',
                style: TextStyle(
                  fontSize: 16,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 12),
              const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green, size: 20),
                  SizedBox(width: 8),
                  Expanded(child: Text('Escáner QR integrado')),
                ],
              ),
              const SizedBox(height: 8),
              const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green, size: 20),
                  SizedBox(width: 8),
                  Expanded(child: Text('Mapa interactivo de Ñuble')),
                ],
              ),
              const SizedBox(height: 8),
              const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green, size: 20),
                  SizedBox(width: 8),
                  Expanded(child: Text('Colección de piezas culturales')),
                ],
              ),
              const SizedBox(height: 8),
              const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green, size: 20),
                  SizedBox(width: 8),
                  Expanded(child: Text('Funciona sin conexión')),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _downloadApp(),
                  icon: const Icon(Icons.download, size: 24),
                  label: const Text(
                    'Descargar APK',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                '⚠️ Asegúrate de permitir la instalación de aplicaciones de fuentes desconocidas en tu dispositivo Android.',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.orange,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _downloadApp() async {
    const url = 'https://www.mediafire.com/file/tesoro_regional_app/tesoro_regional.apk/file';

    try {
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(
          Uri.parse(url),
          mode: LaunchMode.externalApplication,
        );
      } else {
        throw 'No se pudo abrir el enlace de descarga';
      }
    } catch (e) {
      // Show error message
      if (kIsWeb) {
        // For web, we can show a dialog with the link
        showDialog(
          context: navigatorKey.currentContext!,
          builder: (context) => AlertDialog(
            title: const Text('Enlace de Descarga'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Copia este enlace en tu navegador:'),
                const SizedBox(height: 12),
                SelectableText(
                  url,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cerrar'),
              ),
            ],
          ),
        );
      }
    }
  }

  Widget _buildAboutSection(BuildContext context, AppLocalizations l10n) {
    return _buildSection(
      context,
      l10n.about,
      [
        _buildSettingItem(
          context,
          l10n.aboutApp,
          Icons.info,
          l10n.aboutAppDesc,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const AboutPage(),
              ),
            );
          },
        ),
        _buildSettingItem(
          context,
          l10n.version,
          Icons.new_releases,
          '1.0.0',
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Tesoro Regional v1.0.0'),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSection(BuildContext context, String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, top: 16, bottom: 8),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ),
        ...items,
      ],
    );
  }

  Widget _buildSettingItem(
      BuildContext context,
      String title,
      IconData icon,
      String subtitle, {
        VoidCallback? onTap,
      }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: Theme.of(context).primaryColor,
        ),
      ),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}

// Global navigator key for accessing context from static methods
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
