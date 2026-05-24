import 'package:marketplace_app/models/product.dart';
import 'package:marketplace_app/models/cart_item.dart';

// ─── Données JSON brutes (format Platzi Fake Store API) ──────────────────────
// Équivalent de mockSeriesJson dans TD6

final List<Map<String, dynamic>> mockProductsJson = [
  {
    'id': 1,
    'title': 'Chaise ergonomique',
    'price': 149.99,
    'description': 'Chaise de bureau confortable et ergonomique.',
    'category': {'id': 1, 'name': 'Furniture'},
    'images': ['https://placeimg.com/640/480/any'],
  },
  {
    'id': 2,
    'title': 'Clavier mécanique',
    'price': 89.95,
    'description': 'Clavier mécanique RGB pour gaming.',
    'category': {'id': 2, 'name': 'Electronics'},
    'images': ['https://placeimg.com/640/480/tech'],
  },
];

// ─── Objets Product prêts à l'emploi dans les tests ─────────────────────────
// Équivalent de testSerie1 / testSerie2 dans TD6

const testProduct1 = Product(
  id: 1,
  title: 'Chaise ergonomique',
  price: 149.99,
  description: 'Chaise de bureau confortable et ergonomique.',
  category: 'Furniture',
  imageUrl: 'https://placeimg.com/640/480/any',
);

const testProduct2 = Product(
  id: 2,
  title: 'Clavier mécanique',
  price: 89.95,
  description: 'Clavier mécanique RGB pour gaming.',
  category: 'Electronics',
  imageUrl: 'https://placeimg.com/640/480/tech',
);

// CartItem de test
final testCartItem1 = CartItem(product: testProduct1, quantity: 2);
final testCartItem2 = CartItem(product: testProduct2);
