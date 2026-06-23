import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/user.dart';
import '../models/gundam.dart';
import '../models/order.dart';
import '../models/order_item.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'gundam_store.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            email TEXT NOT NULL,
            password TEXT NOT NULL,
            role TEXT NOT NULL,
            name TEXT NOT NULL
          )
        ''');

        await db.execute('''
          CREATE TABLE gundams (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            grade TEXT NOT NULL,
            scale TEXT NOT NULL,
            series TEXT NOT NULL,
            price REAL NOT NULL,
            stock INTEGER NOT NULL,
            imageUrl TEXT NOT NULL
          )
        ''');

        await db.execute('''
          CREATE TABLE orders (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id INTEGER NOT NULL,
            total_amount REAL NOT NULL,
            address TEXT NOT NULL,
            phone TEXT NOT NULL,
            status TEXT NOT NULL,
            created_at TEXT NOT NULL,
            FOREIGN KEY (user_id) REFERENCES users (id)
          )
        ''');

        await db.execute('''
          CREATE TABLE order_items (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            order_id INTEGER NOT NULL,
            gundam_id INTEGER NOT NULL,
            quantity INTEGER NOT NULL,
            price REAL NOT NULL,
            FOREIGN KEY (order_id) REFERENCES orders (id),
            FOREIGN KEY (gundam_id) REFERENCES gundams (id)
          )
        ''');

        await _insertInitialData(db);
      },
    );
  }

  Future<void> _insertInitialData(Database db) async {
    await db.insert('users', {
      'email': 'admin@gundam.com',
      'password': '123456',
      'role': 'admin',
      'name': 'Admin',
    });

    await db.insert('users', {
      'email': 'user@gundam.com',
      'password': '123456',
      'role': 'customer',
      'name': 'Nguyễn Văn A',
    });

    final gundams = [
      {
        'name': 'RX-78-2 Gundam',
        'grade': 'HG',
        'scale': '1/144',
        'series': 'Mobile Suit Gundam',
        'price': 350000.0,
        'stock': 15,
        'imageUrl': 'https://images.unsplash.com/photo-1608889175250-c3b0c1667d3a?w=800&q=80',
      },
      {
        'name': 'MSN-06S Sinanju',
        'grade': 'MG',
        'scale': '1/100',
        'series': 'Gundam Unicorn',
        'price': 1200000.0,
        'stock': 8,
        'imageUrl': 'https://images.unsplash.com/photo-1632283032338-7bb4324f9e42?w=800&q=80',
      },
      {
        'name': 'Strike Freedom Gundam',
        'grade': 'MG',
        'scale': '1/100',
        'series': 'Gundam SEED Destiny',
        'price': 1500000.0,
        'stock': 5,
        'imageUrl': 'https://images.unsplash.com/photo-1608889825103-eb5ed706fc64?w=800&q=80',
      },
      {
        'name': 'Unicorn Gundam Destroy Mode',
        'grade': 'RG',
        'scale': '1/144',
        'series': 'Gundam Unicorn',
        'price': 650000.0,
        'stock': 12,
        'imageUrl': 'https://images.unsplash.com/photo-1606663889134-b1dedb5ed8b7?w=800&q=80',
      },
      {
        'name': 'Wing Gundam Zero EW',
        'grade': 'MG',
        'scale': '1/100',
        'series': 'Gundam Wing',
        'price': 980000.0,
        'stock': 7,
        'imageUrl': 'https://images.unsplash.com/photo-1580477667995-2b94f01c9516?w=800&q=80',
      },
      {
        'name': 'Barbatos Lupus Rex',
        'grade': 'HG',
        'scale': '1/144',
        'series': 'Iron-Blooded Orphans',
        'price': 380000.0,
        'stock': 20,
        'imageUrl': 'https://images.unsplash.com/photo-1569003339405-ea396a5a8a90?w=800&q=80',
      },
      {
        'name': 'Nu Gundam Ver.Ka',
        'grade': 'MG',
        'scale': '1/100',
        'series': "Char's Counterattack",
        'price': 1800000.0,
        'stock': 3,
        'imageUrl': 'https://images.unsplash.com/photo-1615486364103-3e6be4988e92?w=800&q=80',
      },
      {
        'name': 'Exia PG',
        'grade': 'PG',
        'scale': '1/60',
        'series': 'Gundam 00',
        'price': 4500000.0,
        'stock': 2,
        'imageUrl': 'https://images.unsplash.com/photo-1596727147705-61a532a659bd?w=800&q=80',
      },
    ];

    for (final g in gundams) {
      await db.insert('gundams', g);
    }
  }

  Future<User?> getUserByEmail(String email) async {
    final db = await database;
    final result = await db.query('users', where: 'email = ?', whereArgs: [email]);
    if (result.isEmpty) return null;
    return User.fromMap(result.first);
  }

  Future<int> insertUser(User user) async {
    final db = await database;
    return await db.insert('users', {
      'email': user.email,
      'password': user.password,
      'role': user.role,
      'name': user.name,
    });
  }

  Future<List<Gundam>> getGundams() async {
    final db = await database;
    final result = await db.query('gundams');
    return result.map((map) => Gundam.fromMap(map)).toList();
  }

  Future<Gundam?> getGundamById(int id) async {
    final db = await database;
    final result = await db.query('gundams', where: 'id = ?', whereArgs: [id]);
    if (result.isEmpty) return null;
    return Gundam.fromMap(result.first);
  }

  Future<int> insertGundam(Gundam gundam) async {
    final db = await database;
    return await db.insert('gundams', {
      'name': gundam.name,
      'grade': gundam.grade,
      'scale': gundam.scale,
      'series': gundam.series,
      'price': gundam.price,
      'stock': gundam.stock,
      'imageUrl': gundam.imageUrl,
    });
  }

  Future<int> updateGundam(Gundam gundam) async {
    final db = await database;
    return await db.update(
      'gundams',
      {
        'name': gundam.name,
        'grade': gundam.grade,
        'scale': gundam.scale,
        'series': gundam.series,
        'price': gundam.price,
        'stock': gundam.stock,
        'imageUrl': gundam.imageUrl,
      },
      where: 'id = ?',
      whereArgs: [gundam.id],
    );
  }

  Future<int> deleteGundam(int id) async {
    final db = await database;
    return await db.delete('gundams', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> updateGundamStock(int id, int quantityToSubtract) async {
    final db = await database;
    await db.rawUpdate(
      'UPDATE gundams SET stock = stock - ? WHERE id = ?',
      [quantityToSubtract, id],
    );
  }

  Future<int> insertOrder(Order order) async {
    final db = await database;
    return await db.insert('orders', {
      'user_id': order.userId,
      'total_amount': order.totalAmount,
      'address': order.address,
      'phone': order.phone,
      'status': order.status,
      'created_at': order.createdAt,
    });
  }

  Future<void> insertOrderItem(OrderItem item) async {
    final db = await database;
    await db.insert('order_items', {
      'order_id': item.orderId,
      'gundam_id': item.gundamId,
      'quantity': item.quantity,
      'price': item.price,
    });
  }

  Future<List<Order>> getOrders() async {
    final db = await database;
    final result = await db.query('orders', orderBy: 'created_at DESC');
    return result.map((map) => Order.fromMap(map)).toList();
  }

  Future<List<Order>> getOrdersByUserId(int userId) async {
    final db = await database;
    final result = await db.query(
      'orders',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'created_at DESC',
    );
    return result.map((map) => Order.fromMap(map)).toList();
  }

  Future<List<OrderItem>> getOrderItems(int orderId) async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT order_items.*, gundams.name as gundamName
      FROM order_items
      LEFT JOIN gundams ON order_items.gundam_id = gundams.id
      WHERE order_items.order_id = ?
    ''', [orderId]);
    return result.map((map) => OrderItem.fromMap(map)).toList();
  }

  Future<int> updateOrderStatus(int orderId, String status) async {
    final db = await database;
    return await db.update(
      'orders',
      {'status': status},
      where: 'id = ?',
      whereArgs: [orderId],
    );
  }

  Future<int> getOrderCount() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM orders');
    return result.first['count'] as int;
  }

  Future<double> getTotalRevenue() async {
    final db = await database;
    final result = await db.rawQuery(
      "SELECT COALESCE(SUM(total_amount), 0) as total FROM orders WHERE status = 'Completed'",
    );
    return (result.first['total'] as num).toDouble();
  }
}
