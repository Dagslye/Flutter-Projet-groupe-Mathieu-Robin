import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'screens/product_list_screen.dart';
import 'screens/product_detail_screen.dart';
import 'screens/favoris_screen.dart';
import 'screens/cart_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/propose_article_screen.dart';

/// Navigation GoRouter — même structure que TD6.
/// Routes protégées : panier et proposition d'article nécessitent une connexion.
final GoRouter router = GoRouter(
  initialLocation: '/articles',
  redirect: (context, state) {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final protectedRoutes = ['/panier', '/proposer'];
    final isProtected = protectedRoutes.any((r) => state.matchedLocation.startsWith(r));

    if (isProtected && !auth.isAuthenticated) {
      return '/login?redirect=${state.matchedLocation}';
    }
    return null;
  },
  routes: [
    GoRoute(
      path: '/articles',
      name: 'articles',
      builder: (context, state) => const ProductListScreen(),
    ),
    GoRoute(
      path: '/article/:id',
      name: 'article-detail',
      builder: (context, state) {
        final id = int.parse(state.pathParameters['id']!);
        return ProductDetailScreen(productId: id);
      },
    ),
    GoRoute(
      path: '/favoris',
      name: 'favoris',
      builder: (context, state) => const FavorisScreen(),
    ),
    GoRoute(
      path: '/panier',
      name: 'panier',
      builder: (context, state) => const CartScreen(),
    ),
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (context, state) {
        final redirect = state.uri.queryParameters['redirect'];
        return LoginScreen(redirectAfter: redirect);
      },
    ),
    GoRoute(
      path: '/register',
      name: 'register',
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/proposer',
      name: 'proposer',
      builder: (context, state) => const ProposeArticleScreen(),
    ),
  ],
  errorBuilder: (context, state) => Scaffold(
    body: Center(child: Text('Page introuvable : ${state.error}')),
  ),
);
