import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';
import '../providers/favoris_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/cart_badge_button.dart';

/// Équivalent de SerieListScreen dans TD6.
/// ListView de produits + recherche + filtre catégorie.
class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Chargement après le premier frame — même pattern que TD6
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().fetchProducts();
      context.read<ProductProvider>().fetchCategories();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Marketplace'),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite),
            onPressed: () => context.push('/favoris'),
          ),
          const CartBadgeButton(),
          if (auth.isAuthenticated)
            PopupMenuButton<String>(
              icon: const Icon(Icons.person),
              onSelected: (value) {
                if (value == 'logout') {
                  context.read<AuthProvider>().logout();
                } else if (value == 'proposer') {
                  context.push('/proposer');
                }
              },
              itemBuilder: (_) => [
                PopupMenuItem(
                  value: 'info',
                  enabled: false,
                  child: Text(auth.user?.name ?? ''),
                ),
                const PopupMenuItem(value: 'proposer', child: Text('Proposer un article')),
                const PopupMenuItem(value: 'logout', child: Text('Se déconnecter')),
              ],
            )
          else
            IconButton(
              icon: const Icon(Icons.login),
              onPressed: () => context.push('/login'),
            ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildCategoryFilter(),
          Expanded(child: _buildProductList()),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Rechercher un article...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    context.read<ProductProvider>().clearFilters();
                  },
                )
              : null,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          isDense: true,
        ),
        onSubmitted: (value) =>
            context.read<ProductProvider>().setSearchQuery(value),
        onChanged: (value) {
          setState(() {}); // pour afficher/cacher le bouton clear
          if (value.isEmpty) context.read<ProductProvider>().clearFilters();
        },
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return Consumer<ProductProvider>(
      builder: (context, provider, _) {
        if (provider.categories.isEmpty) return const SizedBox.shrink();
        return SizedBox(
          height: 40,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: provider.categories.length + 1,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              if (index == 0) {
                final selected = provider.selectedCategoryId == null;
                return FilterChip(
                  label: const Text('Tous'),
                  selected: selected,
                  onSelected: (_) => provider.setCategory(null),
                );
              }
              final cat = provider.categories[index - 1];
              final catId = cat['id'] as int;
              final selected = provider.selectedCategoryId == catId;
              return FilterChip(
                label: Text(cat['name'] as String? ?? ''),
                selected: selected,
                onSelected: (_) => provider.setCategory(selected ? null : catId),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildProductList() {
    return Consumer<ProductProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (provider.error != null) {
          return Center(child: Text(provider.error!));
        }
        if (provider.products.isEmpty) {
          return const Center(child: Text('Aucun article trouvé.'));
        }
        return ListView.builder(
          itemCount: provider.products.length,
          itemBuilder: (context, index) {
            final product = provider.products[index];
            return Consumer2<FavorisProvider, CartProvider>(
              builder: (context, favoris, cart, _) {
                final isFavori = favoris.estFavori(product.id);
                final inCart = cart.estDansLePanier(product.id);
                return ListTile(
                  leading: product.imageUrl != null
                      ? Image.network(
                          product.imageUrl!,
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(Icons.image_not_supported),
                        )
                      : const Icon(Icons.inventory_2),
                  title: Text(product.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                  subtitle: Text('${product.category} · ${product.price.toStringAsFixed(2)} €'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(
                          isFavori ? Icons.favorite : Icons.favorite_border,
                          color: isFavori ? Colors.red : null,
                        ),
                        onPressed: () => favoris.toggleFavori(product),
                      ),
                      IconButton(
                        icon: Icon(
                          inCart ? Icons.shopping_cart : Icons.add_shopping_cart,
                          color: inCart ? Theme.of(context).colorScheme.primary : null,
                        ),
                        onPressed: () => cart.ajouterAuPanier(product),
                      ),
                    ],
                  ),
                  onTap: () => context.push('/article/${product.id}'),
                );
              },
            );
          },
        );
      },
    );
  }
}
