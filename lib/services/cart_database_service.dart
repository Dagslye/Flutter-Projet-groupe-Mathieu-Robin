import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import '../models/cart_item.dart';

/// Équivalent exact de WatchlistDatabaseService dans TD6.
/// Persiste le panier de l'utilisateur en SQLite.
/// [databasePath] est injectable pour les tests in-memory (même pattern TD6).
class CartDatabaseService {
  final String? databasePath;
  Database? _db;

  CartDatabaseService({this.databasePath});

  Future<Database> get _database async {
    _db ??= await _openDatabase();
    return _db!;
  }

  Future<Database> _openDatabase() async {
    final path = databasePath ?? p.join(await getDatabasesPath(), 'cart.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE cart (
            product_id INTEGER PRIMARY KEY,
            data TEXT NOT NULL
          )
        ''');
      },
    );
  }

  Future<List<CartItem>> getCart() async {
    final db = await _database;
    final rows = await db.query('cart');
    return rows
        .map((row) => CartItem.fromJson(
            jsonDecode(row['data'] as String) as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveCart(List<CartItem> items) async {
    final db = await _database;
    await db.transaction((txn) async {
      await txn.delete('cart');
      for (final item in items) {
        await txn.insert('cart', {
          'product_id': item.product.id,
          'data': jsonEncode(item.toJson()),
        });
      }
    });
  }

  Future<void> clearCart() async {
    final db = await _database;
    await db.delete('cart');
  }

  Future<void> close() async => _db?.close();
}
