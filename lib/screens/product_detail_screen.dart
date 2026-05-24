import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../providers/product_provider.dart';
import '../providers/favoris_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/auth_provider.dart';

/// Équivalent de SerieDetailScreen dans TD6.
/// FutureBuilder pour charger le détail, boutons favoris et panier.
class ProductDetailScreen extends StatelessWidget {
  final int productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Détail article')),
      body: FutureBuilder<Product>(
        future: context.read<ProductProvider>().fetchProductById(productId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Erreur : ${snapshot.error}'));
          }
          final product = snapshot.data!;
          return _buildDetail(context, product);
        },
      ),
    );
  }

  Widget _buildDetail(BuildContext context, Product product) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          if (product.imageUrl != null)
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  product.imageUrl!,
                  height: 220,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Icon(Icons.image_not_supported, size: 100),
                ),
              ),
            ),
          const SizedBox(height: 16),

          // Titre + prix
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(product.title,
                    style: Theme.of(context).textTheme.headlineSmall),
              ),
              const SizedBox(width: 8),
              Text(
                '${product.price.toStringAsFixed(2)} €',
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(color: Theme.of(context).colorScheme.primary),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(product.category,
              style: TextStyle(color: Colors.grey[600], fontSize: 14)),
          const SizedBox(height: 12),
          Text(product.description),
          const SizedBox(height: 24),

          // Bouton Favoris — Consumer comme TD6
          Consumer<FavorisProvider>(
            builder: (context, favoris, _) {
              final isFavori = favoris.estFavori(product.id);
              return ElevatedButton.icon(
                onPressed: () => favoris.toggleFavori(product),
                icon: Icon(isFavori ? Icons.favorite : Icons.favorite_border),
                label: Text(isFavori ? 'Retirer des favoris' : 'Ajouter aux favoris'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 44),
                  backgroundColor: isFavori ? Colors.red[50] : null,
                  foregroundColor: isFavori ? Colors.red : null,
                ),
              );
            },
          ),
          const SizedBox(height: 8),

          // Bouton Panier — nécessite authentification
          Consumer2<CartProvider, AuthProvider>(
            builder: (context, cart, auth, _) {
              final inCart = cart.estDansLePanier(product.id);
              final item = cart.getItem(product.id);
              return Column(
                children: [
                  if (inCart && item != null)
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => cart.retirerDuPanier(product.id),
                            icon: const Icon(Icons.remove_shopping_cart),
                            label: const Text('Retirer du panier'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove, size: 18),
                                onPressed: () =>
                                    cart.decrementerQuantite(product.id),
                              ),
                              Text('${item.quantity}',
                                  style: const TextStyle(fontWeight: FontWeight.bold)),
                              IconButton(
                                icon: const Icon(Icons.add, size: 18),
                                onPressed: () => cart.ajouterAuPanier(product),
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  else
                    ElevatedButton.icon(
                      onPressed: () {
                        if (!auth.isAuthenticated) {
                          context.push('/login?redirect=/article/${product.id}');
                          return;
                        }
                        cart.ajouterAuPanier(product);
                      },
                      icon: const Icon(Icons.add_shopping_cart),
                      label: const Text('Ajouter au panier'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 44),
                      ),
                    ),
                  if (!auth.isAuthenticated)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        'Connexion requise pour acheter',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                        textAlign: TextAlign.center,
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
