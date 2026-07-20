import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:smart_shopping_chatbot/shared/widgets/main_shell.dart';
import 'package:smart_shopping_chatbot/features/products/presentation/screens/home_screen.dart';
import 'package:smart_shopping_chatbot/features/chat/presentation/screens/chat_list_screen.dart';
import 'package:smart_shopping_chatbot/features/chat/presentation/screens/chat_screen.dart';
import 'package:smart_shopping_chatbot/features/products/presentation/screens/search_screen.dart';
import 'package:smart_shopping_chatbot/features/profile/presentation/screens/profile_screen.dart';
import 'package:smart_shopping_chatbot/features/products/presentation/screens/product_detail_screen.dart';
import 'package:smart_shopping_chatbot/features/products/presentation/screens/compare_screen.dart';
import 'package:smart_shopping_chatbot/features/auth/presentation/screens/login_screen.dart';
import 'package:smart_shopping_chatbot/features/auth/presentation/screens/register_screen.dart';

// ---------------------------------------------------------------------------
// Navigation keys — used to preserve navigator state per branch.
// ---------------------------------------------------------------------------
final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _homeNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'home');
final _chatNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'chat');
final _searchNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'search');
final _profileNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'profile');

// ---------------------------------------------------------------------------
// GoRouter provider
// ---------------------------------------------------------------------------

/// Riverpod provider that exposes the app's [GoRouter] instance.
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/home',
    routes: [
      // ── Bottom-navigation shell (4 tabs) ──────────────────────────────
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainShell(navigationShell: navigationShell);
        },
        branches: [
          // Tab 0 — Home
          StatefulShellBranch(
            navigatorKey: _homeNavigatorKey,
            routes: [
              GoRoute(
                path: '/home',
                name: 'home',
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: HomeScreen()),
              ),
            ],
          ),

          // Tab 1 — Chat
          StatefulShellBranch(
            navigatorKey: _chatNavigatorKey,
            routes: [
              GoRoute(
                path: '/chat',
                name: 'chatList',
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: ChatListScreen()),
              ),
            ],
          ),

          // Tab 2 — Search
          StatefulShellBranch(
            navigatorKey: _searchNavigatorKey,
            routes: [
              GoRoute(
                path: '/search',
                name: 'search',
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: SearchScreen()),
              ),
            ],
          ),

          // Tab 3 — Profile
          StatefulShellBranch(
            navigatorKey: _profileNavigatorKey,
            routes: [
              GoRoute(
                path: '/profile',
                name: 'profile',
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: ProfileScreen()),
              ),
            ],
          ),
        ],
      ),

      // ── Top-level routes (pushed over bottom nav) ─────────────────────
      GoRoute(
        path: '/chat/:id',
        name: 'chat',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final chatId = state.pathParameters['id']!;
          return ChatScreen(chatId: chatId);
        },
      ),

      GoRoute(
        path: '/product/:id',
        name: 'productDetail',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final productId = state.pathParameters['id']!;
          return ProductDetailScreen(productId: productId);
        },
      ),

      GoRoute(
        path: '/compare',
        name: 'compare',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const CompareScreen(),
      ),

      GoRoute(
        path: '/login',
        name: 'login',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const LoginScreen(),
      ),

      GoRoute(
        path: '/register',
        name: 'register',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const RegisterScreen(),
      ),
    ],

    // Redirect '/' to '/home'
    redirect: (context, state) {
      if (state.matchedLocation == '/') return '/home';
      return null;
    },
  );
});
