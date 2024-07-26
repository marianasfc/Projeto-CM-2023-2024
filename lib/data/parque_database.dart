import 'package:projeto_emel_cm/model/parque.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class ParqueDatabase {
  static final ParqueDatabase instance = ParqueDatabase._init();
  static Database? _database;

  ParqueDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('parques.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
  CREATE TABLE parque(
    id TEXT PRIMARY KEY,
    nome TEXT NOT NULL,
    id_parque TEXT NOT NULL,
    capacidade_max INTEGER NULL,
    ocupacao INTEGER NULL,
    data_ocupacao TEXT NULL,
    latitude TEXT NULL,
    longitude TEXT NULL,
    tipo TEXT NULL
  )
  ''');
  }

  Future<List<Parque>> getParques() async {
    final db = await instance.database;
    if (_database == null){
      throw Exception('Forgot to initialize the database');
    }

    final result = await db.query('parque');
    return result.map((json) => Parque.fromDB(json)).toList();
  }

  Future<Parque> getParque(String id) async {
    final db = await instance.database;
    if (_database == null){
      throw Exception('Forgot to initialize the database');
    }

    List result = await db.rawQuery("SELECT * FROM parque WHERE id = ?'", [id]);
    if(result.isNotEmpty){
      return Parque.fromDB(result.first);
    }else{
      throw Exception('Inexistent parque $id');
    }
  }

  Future<void> insert(Parque parque) async {
    final db = await instance.database;
    if (_database == null){
      throw Exception('Forgot to initialize the database');
    }

    await db.insert('parque', parque.toDB());
  }

  Future<void> deleteAll() async {
    final db = await instance.database;
    if (_database == null){
      throw Exception('Forgot to initialize the database');
    }

    await db.rawDelete('DELETE FROM parque');
  }
}