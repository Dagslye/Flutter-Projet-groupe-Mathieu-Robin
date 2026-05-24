import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/favoris_provider.dart';
import '../providers/cart_provider.dart';

/// Équivalent exact de FavorisScreen dans TD6.
class FavorisScreen extends StatelessWidget {
  const FavorisScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mes favoris')),
      body: Consumer<FavorisProvider>(
        builder: (context, provider, _) {
          if (provider.favoris.isEmpty) {
            return const Center(child: Text('Aucun favori pour l\'instant.'));
          }
          return ListView.builder(
            itemCount: provider.favoris.length,
            itemBuilder: (context, index) {
              final product = provider.favoris[index];
              return ListTile(
                leading: product.imageUrl != null
                    ? Image.network(
                        product.imageUrl!,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            const Icon(Icons.inventory_2),
                      )
                    : const Icon(Icons.inventory_2),
                title: Text(product.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                subtitle: Text('${product.price.toStringAsFixed(2)} €'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Consumer<CartProvider>(
                      builder: (context, cart, _) => IconButton(
                        icon: Icon(
                          cart.estDansLePanier(product.id)
                              ? Icons.shopping_cart
                              : Icons.add_shopping_cart,
                        ),
                        onPressed: () => cart.ajouterAuPanier(product),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.favorite, color: Colors.red),
                      onPressed: () => provider.toggleFavori(product),
                    ),
                  ],
                ),
                onTap: () => context.push('/article/${product.id}'),
              );
            },
          );
        },
      ),
    );
  }
}
