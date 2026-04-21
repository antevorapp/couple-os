import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/theme/app_theme.dart';
import 'features/auth/auth_screen.dart';
import 'features/chat/chat_screen.dart';
import 'features/love_score/who_loves_more_screen.dart';
import 'features/settings/settings_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://zdwfohdovaaysaslywpw.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inpkd2ZvaGRvdmFheXNhc2x5d3B3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzY3NTUwNjQsImV4cCI6MjA5MjMzMTA2NH0.48eR5g57q3Zv78ZA3VqHAscsq7pSuvi2SwLgB6eCI5A',
  );

  runApp(const ProviderScope(child: CoupleOsApp()));
}

final _router = GoRouter(
  initialLocation: '/auth',
  redirect: (context, state) {
    final session = Supabase.instance.client.auth.currentSession;
    final isAuth = state.matchedLocation == '/auth';
    if (session == null && !isAuth) return '/auth';
    if (session != null && isAuth) return '/home';
    return null;
  },
  routes: [
    GoRoute(path: '/auth', builder: (_, _) => const AuthScreen()),
    ShellRoute(
      builder: (context, state, child) => _HomeShell(child: child),
      routes: [
        GoRoute(path: '/home', builder: (_, _) => const WhoLovesMoreScreen()),
        GoRoute(path: '/chat', builder: (_, _) => const ChatScreen()),
        GoRoute(path: '/settings', builder: (_, _) => const SettingsScreen()),
      ],
    ),
  ],
);

class CoupleOsApp extends StatelessWidget {
  const CoupleOsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Couple OS',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      routerConfig: _router,
    );
  }
}

class _HomeShell extends StatelessWidget {
  final Widget child;

  const _HomeShell({required this.child});

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    if (location == '/chat') return 1;
    if (location == '/settings') return 2;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex(context),
        onTap: (i) {
          switch (i) {
            case 0:
              context.go('/home');
            case 1:
              context.go('/chat');
            case 2:
              context.go('/settings');
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_border),
            activeIcon: Icon(Icons.favorite),
            label: 'Aşk Skoru',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            activeIcon: Icon(Icons.chat_bubble),
            label: 'Sohbet',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            activeIcon: Icon(Icons.settings),
            label: 'Ayarlar',
          ),
        ],
      ),
    );
  }
}
