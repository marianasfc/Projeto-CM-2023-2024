import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../model/report.dart';

class IncidentesDatabase {
  static final IncidentesDatabase instance = IncidentesDatabase._init();
  static Database? _database;

  IncidentesDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('incidentes.db');
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
      CREATE TABLE incidente(
        id TEXT PRIMARY KEY,
        parqueId TEXT NULL,
        gravidade INTEGER NOT NULL,
        data TEXT NULL,
        hora TEXT NULL,
        notas TEXT NULL,
        fotografia TEXT NULL
      )
    ''');
  }

  Future<List<Report>> getIncidentes() async {
    final db = await instance.database;
    if (_database == null) {
      throw Exception('Forgot to initialize the database');
    }

    final result = await db.query('incidente');
    return result.map((json) => Report.fromDB(json)).toList();
  }

  Future<List<Report>> getIncidente(String parqueId) async {
    final db = await instance.database;
    if (_database == null) {
      throw Exception('Forgot to initialize the database');
    }

    final results = await db.rawQuery("SELECT * FROM incidente WHERE parqueId = ?", [parqueId]);
    return results.map((result) => Report.fromDB(result)).toList();
  }

  Future<void> insert(Report incidente) async {
    final db = await instance.database;
    if (_database == null) {
      throw Exception('Forgot to initialize the database');
    }

    await db.insert('incidente', incidente.toDB());
  }

  Future<void> deleteAll() async {
    final db = await instance.database;
    if (_database == null) {
      throw Exception('Forgot to initialize the database');
    }

    await db.rawDelete('DELETE FROM incidente');
  }
}