import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';

/// Équivalent de WatchlistScreen dans TD6.
/// Affiche les articles du panier avec quantités et total.
class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mon panier')),
      body: Consumer<CartProvider>(
        builder: (context, cart, _) {
          if (cart.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (cart.items.isEmpty) {
            return const Center(child: Text('Votre panier est vide.'));
          }
          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: cart.items.length,
                  itemBuilder: (context, index) {
                    final item = cart.items[index];
                    return ListTile(
                      leading: item.product.imageUrl != null
                          ? Image.network(
                              item.product.imageUrl!,
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  const Icon(Icons.inventory_2),
                            )
                          : const Icon(Icons.inventory_2),
                      title: Text(item.product.title,
                          maxLines: 1, overflow: TextOverflow.ellipsis),
                      subtitle: Text(
                          '${item.product.price.toStringAsFixed(2)} € × ${item.quantity}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${item.totalPrice.toStringAsFixed(2)} €',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          // Même DropdownButton-like que WatchlistScreen TD6
                          // ici on utilise +/- comme pour un panier
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline),
                            onPressed: () =>
                                cart.decrementerQuantite(item.product.id),
                          ),
                          Text('${item.quantity}'),
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline),
                            onPressed: () =>
                                cart.ajouterAuPanier(item.product),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () =>
                                cart.retirerDuPanier(item.product.id),
                          ),
                        ],
                      ),
                      onTap: () => context.push('/article/${item.product.id}'),
                    );
                  },
                ),
              ),
              _buildTotal(context, cart),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTotal(BuildContext context, CartProvider cart) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Total (${cart.itemCount} article${cart.itemCount > 1 ? 's' : ''})'),
                Text(
                  '${cart.total.toStringAsFixed(2)} €',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () => _showValidationDialog(context, cart),
            child: const Text('Valider le panier'),
          ),
        ],
      ),
    );
  }

  void _showValidationDialog(BuildContext context, CartProvider cart) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirmer l\'achat'),
        content: Text(
            'Total : ${cart.total.toStringAsFixed(2)} €\n'
            '${cart.itemCount} article${cart.itemCount > 1 ? 's' : ''}\n\n'
            'Confirmer votre commande ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              cart.validerPanier();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Commande validée ! Merci pour votre achat.')),
              );
            },
            child: const Text('Confirmer'),
          ),
        ],
      ),
    );
  }
}
