import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../modele/redacteur.dart';

class DatabaseManager {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }
    _database = await initialisation();
    return _database!;
  }

  Future<Database> initialisation() async {
    final String chemin = join(await getDatabasesPath(), 'redacteurs.db');

    return await openDatabase(
      chemin,
      version: 1,
      onCreate: (Database db, int version) async {
        await db.execute('''
          CREATE TABLE redacteurs(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nom TEXT,
            prenom TEXT,
            email TEXT
          )
        ''');
      },
    );
  }

  Future<List<Redacteur>> getAllRedacteurs() async {
    final Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query('redacteurs');

    return List.generate(maps.length, (i) {
      return Redacteur.fromMap(maps[i]);
    });
  }

  Future<int> insertRedacteur(Redacteur redacteur) async {
    final Database db = await database;
    return await db.insert(
      'redacteurs',
      redacteur.toMap()..remove('id'),
    );
  }

  Future<int> updateRedacteur(Redacteur redacteur) async {
    final Database db = await database;
    return await db.update(
      'redacteurs',
      redacteur.toMap(),
      where: 'id = ?',
      whereArgs: [redacteur.id],
    );
  }

  Future<int> deleteRedacteur(int id) async {
    final Database db = await database;
    return await db.delete(
      'redacteurs',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}