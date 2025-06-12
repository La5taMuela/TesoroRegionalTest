import 'package:go_router/go_router.dart';
import 'package:tesoro_regional/features/home/presentation/pages/home_page.dart';
import 'package:tesoro_regional/features/puzzle/presentation/pages/puzzle_page.dart';
import 'package:tesoro_regional/features/puzzle/presentation/pages/collected_pieces_page.dart';
import 'package:tesoro_regional/features/map/presentation/pages/map_page.dart';
import 'package:tesoro_regional/features/missions/presentation/pages/missions_page.dart';
import 'package:tesoro_regional/features/stories/presentation/pages/stories_page.dart';
import 'package:tesoro_regional/features/settings/presentation/pages/settings_page.dart';
import 'package:tesoro_regional/features/minigames/presentation/pages/minigames_page.dart';
import 'package:tesoro_regional/features/minigames/presentation/pages/trivia_page.dart';
import 'package:tesoro_regional/features/minigames/presentation/pages/memory_game_page.dart';
import 'package:tesoro_regional/features/minigames/presentation/pages/puzzle_slider_page.dart';
import 'package:tesoro_regional/features/qr_scanner/presentation/pages/qr_scanner_page.dart';
import 'package:tesoro_regional/features/nuble_map/presentation/pages/nuble_map_page.dart';
import 'package:tesoro_regional/features/nuble_map/presentation/pages/province_detail_page.dart';
import 'package:tesoro_regional/features/nuble_map/presentation/pages/city_detail_page.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: '/puzzle',
        builder: (context, state) => const PuzzlePage(),
      ),
      GoRoute(
        path: '/collected-pieces',
        builder: (context, state) => const CollectedPiecesPage(),
      ),
      GoRoute(
        path: '/map',
        builder: (context, state) => const MapPage(),
      ),
      GoRoute(
        path: '/missions',
        builder: (context, state) => const MissionsPage(),
      ),
      GoRoute(
        path: '/stories',
        builder: (context, state) => const StoriesPage(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsPage(),
      ),
      GoRoute(
        path: '/minigames',
        builder: (context, state) => const MinigamesPage(),
      ),
      GoRoute(
        path: '/trivia',
        builder: (context, state) => const TriviaPage(),
      ),
      GoRoute(
        path: '/memory-game',
        builder: (context, state) => const MemoryGamePage(),
      ),
      GoRoute(
        path: '/puzzle-slider',
        builder: (context, state) => const PuzzleSliderPage(),
      ),
      GoRoute(
        path: '/nuble-map',
        builder: (context, state) => const NubleMapPage(),
      ),
      GoRoute(
        path: '/province/:provinceId',
        builder: (context, state) {
          final provinceId = state.pathParameters['provinceId']!;
          return ProvinceDetailPage(provinceId: provinceId);
        },
      ),
      GoRoute(
        path: '/city/:cityId',
        builder: (context, state) {
          final cityId = state.pathParameters['cityId']!;
          return CityDetailPage(cityId: cityId);
        },
      ),
    ],
  );
}
