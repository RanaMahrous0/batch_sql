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
      var results = await batch.commit();
      print(' results : $results');
      return true;
    } catch (e) {
      print('error $e');
      return false;
    }
  }
}
