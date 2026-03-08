import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:developer';
import '../models/client_model.dart';

class DatabaseHelper {
  static const _databaseName = "AdvocateDirectory.db";
  static const _databaseVersion = 1;
  static const table = 'clients';

  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  Future _onCreate(Database db, int version) async {
    // 🌟 Yahan humne table mein hearingDate ka naya column add kiya hai 🌟
    await db.execute('''
          CREATE TABLE $table (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            image TEXT NOT NULL,
            name TEXT NOT NULL,
            email TEXT NOT NULL,
            age INTEGER NOT NULL,
            hearingDate TEXT NOT NULL 
          )
          ''');
  }

  Future<int> insert(ClientModel client) async {
    try {
      Database db = await instance.database;
      return await db.insert(table, client.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
    } catch (e) {
      log('Insert Error: $e');
      return -1;
    }
  }

  Future<List<ClientModel>> queryAllRows() async {
    try {
      Database db = await instance.database;
      final List<Map<String, dynamic>> maps = await db.query(table, orderBy: 'id DESC');
      return List.generate(maps.length, (i) {
        return ClientModel.fromMap(maps[i]);
      });
    } catch (e) {
      log('Query Error: $e');
      return [];
    }
  }

  Future<int> update(ClientModel client) async {
    try {
      Database db = await instance.database;
      return await db.update(table, client.toMap(), where: 'id = ?', whereArgs: [client.id]);
    } catch (e) {
      log('Update Error: $e');
      return -1;
    }
  }

  Future<int> delete(int id) async {
    try {
      Database db = await instance.database;
      return await db.delete(table, where: 'id = ?', whereArgs: [id]);
    } catch (e) {
      log('Delete Error: $e');
      return -1;
    }
  }

  Future close() async {
    Database db = await instance.database;
    db.close();
  }
}