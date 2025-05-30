import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'providers/auth_provider.dart';
import 'screens/all_categories_screen.dart'; // Import the new screen
import 'screens/auth_screen.dart';
import 'screens/category_screen.dart';
import 'screens/create_listing_screen.dart';
import 'screens/home_screen.dart';
import 'screens/listing_detail_screen.dart';
import 'screens/listings_screen.dart';
import 'screens/my_listings_screen.dart';
import 'utils/theme.dart';

class StansListApp extends StatelessWidget {
  const StansListApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    return MaterialApp.router(
      title: 'Stan\'s List',
      theme: AppTheme.lightTheme,
      routerConfig: _createRouter(authProvider),
      debugShowCheckedModeBanner: false,
    );
  }
}

GoRouter _createRouter(AuthProvider authProvider) {
  return GoRouter(
    refreshListenable: authProvider,
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/auth',
        builder: (context, state) => const AuthScreen(),
      ),
      GoRoute(
        path: '/listings',
        builder: (context, state) => const ListingsScreen(),
      ),
      GoRoute(
        path: '/category/:category',
        builder: (context, state) {
          final category = state.pathParameters['category']!;
          return CategoryScreen(category: category);
        },
      ),
      GoRoute(
        path: '/create',
        builder: (context, state) =>
            const CreateListingScreen(), // For creating new listings
      ),
      GoRoute(
        path: '/listing/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return ListingDetailScreen(listingId: id);
        },
      ),
      GoRoute(
        path: '/listing/:id/edit',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return CreateListingScreen(
              listingId: id); // For editing existing listings
        },
      ),
      GoRoute(
        path: '/my-posts', // Changed from /my-listings
        name: 'my-listings', // Keep name for potential internal references
        builder: (context, state) => const MyListingsScreen(),
      ),
      GoRoute(
        // Add route for AllCategoriesScreen
        path: '/categories',
        builder: (context, state) => const AllCategoriesScreen(),
      ),
    ],
    redirect: (BuildContext context, GoRouterState state) {
      final bool loggedIn = authProvider.currentUser != null;
      final String currentLocation = state.uri.toString();

      // Define protected routes that require authentication
      final protectedRoutes = ['/create', '/my-posts'];
      final bool isTryingToAccessProtectedRoute =
          protectedRoutes.any((route) => currentLocation == route);

      // Check for edit route specifically as it contains a parameter
      final bool isTryingToAccessEditRoute =
          RegExp(r'^/listing/.+/edit$').hasMatch(currentLocation);

      // If user is not logged in and trying to access a protected route (create, my-posts, or edit), redirect to /auth
      if (!loggedIn &&
          (isTryingToAccessProtectedRoute || isTryingToAccessEditRoute)) {
        return '/auth';
      }

      // If user is logged in and trying to access /auth, redirect to home
      if (loggedIn && currentLocation == '/auth') {
        return '/';
      }

      // No redirect needed for other cases (e.g., public routes, or logged-in user accessing allowed routes)
      return null;
    },
  );
}
