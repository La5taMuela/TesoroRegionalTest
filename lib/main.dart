import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tesoro_regional/app/app.dart';
import 'package:tesoro_regional/core/di/service_locator.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  setupServiceLocator(); // Asegúrate de llamar esto primero

  runApp(
    const ProviderScope(
      child: TesoroRegionalApp(),
    ),
  );
}