/// Équivalent de Serie dans TD6.
/// Supporte le format Platzi Fake Store API ET notre format toJson().
///
/// Format API Platzi (doc officielle https://fakeapi.platzi.com/en/rest/products/) :
/// {
///   "id": 4, "title": "...", "price": 687, "description": "...",
///   "category": { "id": 5, "name": "Others", "image": "...", "slug": "others" },
///   "images": ["https://i.imgur.com/...", "https://..."]
/// }
class Product {
  final int id;
  final String title;
  final double price;
  final String description;
  final String category;
  final String? imageUrl;

  const Product({
    required this.id,
    required this.title,
    required this.price,
    required this.description,
    required this.category,
    this.imageUrl,
  });

  /// L'API Platzi retourne 'images' comme List<String> d'URLs directes.
  /// Ex: ["https://i.imgur.com/QkIa5tT.jpeg", "https://..."]
  /// On prend la première. Nettoyage des crochets conservé pour robustesse.
  static String? _parseImage(dynamic images) {
    if (images == null) return null;
    if (images is List && images.isNotEmpty) {
      final raw = images[0].toString().replaceAll(RegExp(r'[\[\]"\\]'), '').trim();
      return raw.isNotEmpty ? raw : null;
    }
    return null;
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    // Supporte le format Platzi Fake Store API (clés 'title', 'images', 'category' objet…)
    // ET notre format toJson() (clés 'title', 'imageUrl', 'category' string)
    final categoryData = json['category'];
    final String categoryName = categoryData is Map
        ? (categoryData['name'] as String? ?? 'Inconnu')
        : (json['category'] as String? ?? 'Inconnu');

    return Product(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? 'Sans titre',
      // price est un number dans l'API (int ou double)
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      description: json['description'] as String? ?? '',
      category: categoryName,
      // Cherche d'abord 'images' (format API), sinon 'imageUrl' (format toJson)
      imageUrl: _parseImage(json['images']) ?? json['imageUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'price': price,
        'description': description,
        'category': category,
        'imageUrl': imageUrl,
      };

  @override
  bool operator ==(Object other) => other is Product && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
