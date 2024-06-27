import 'package:sqflite/sqflite.dart';

class SqlHelper {
  Database? db;

  Future<void> initDatabase() async {
    try {
      db = await openDatabase(
        "pay_pos.db",
        version: 1,
        onCreate: (db, version) {
          print('database done');
        },
      );
    } catch (e) {
      print('error $e');
    }
  }

  Future<bool> createTable() async {
    try {
      var batch = db!.batch();
      batch.rawQuery("""
      PRAGMA foreign_keys = ON
      """);
      batch.rawQuery("""
      PRAGMA foreign_keys
      """);
      batch.execute('''
      CREATE TABLE if not exists categories(
        id INTEGER PRIMARY KEY ,
        name TEXT not null,
        description text not null
      )
    ''');
      batch.execute('''
      CREATE TABLE if not exists products(
        id INTEGER PRIMARY KEY ,
        name TEXT not null,
        description text not null,
        price double not null,
        stock intger not null,
        isAvaliable boolean not null,
        image text,
        categoryId intger not null,
        foreign key(categoryId) references categories (id)
        on delete restrict
      )
    ''');
      batch.execute('''
      CREATE TABLE if not exists clients(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT not null,
        email text,
        phone text,
        address text
      )
    ''');
      batch.execute('''
      CREATE TABLE if not exists orders(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        label TEXT not null,
        totalPrice real,
        discount real,
        clientId integer NOT NULL,
        foreign key(clientId) references clients (id)
        on delete restrict
      )
    ''');
      batch.execute('''
      CREATE TABLE if not exists orderProductItems(
        orderId integer,
        productId integer,
        productCount integer,
        foreign key(productId) references products (id)
        on delete restrict
      )
    ''');
      batch.execute('''
      CREATE TABLE if not exists exchangeRate(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        label integer ,
        value real 

      )
    ''');
      var results = await batch.commit();
      db!.insert('exchangeRate', {'label': 1, 'value': 11712.25});
      print(' results : $results');

      return true;
    } catch (e) {
      print('error $e');
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> queryItems(
      {String? price, int offset = 0, int limit = 10}) async {
    if (price != null) {
      return await db!.query(
        'products',
        where: 'price = ?',
        whereArgs: [price],
        limit: limit,
        offset: offset,
      );
    } else {
      return await db!.query('products', limit: limit, offset: offset);
    }
  }
 
}
