import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../model/ReportGira.dart';

class ReportGiraDatabase {
  static final ReportGiraDatabase instance = ReportGiraDatabase._init();
  static Database? _database;

  ReportGiraDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('reportGira.db');
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
      CREATE TABLE reportGira(
        id TEXT PRIMARY KEY,
        giraId TEXT NULL,
        notas TEXT NULL,
        problema TEXT NULL
      )
    ''');
  }

  Future<List<ReportGira>> getReportGira() async {
    final db = await instance.database;
    if (_database == null) {
      throw Exception('Forgot to initialize the database');
    }

    final result = await db.query('reportGira');
    return result.map((json) => ReportGira.fromDB(json)).toList();
  }

  Future<List<ReportGira>> getIncidente(String giraId) async {
    final db = await instance.database;
    if (_database == null) {
      throw Exception('Forgot to initialize the database');
    }

    final results = await db.rawQuery("SELECT * FROM reportGira WHERE giraId = ?", [giraId]);
    return results.map((result) => ReportGira.fromDB(result)).toList();
  }

  Future<void> insert(ReportGira reportGira) async {
    final db = await instance.database;
    if (_database == null) {
      throw Exception('Forgot to initialize the database');
    }

    await db.insert('reportGira', reportGira.toMap());
  }

  Future<void> deleteAll() async {
    final db = await instance.database;
    if (_database == null) {
      throw Exception('Forgot to initialize the database');
    }

    await db.rawDelete('DELETE FROM reportGira');
  }
}