import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:student_management/models/student.dart';

class DatabaseStudents {
  static Database? _database;
  static const _databaseVersion = 2;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    String path = join(dbPath, 'estudiantes.db');
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE estudiantes(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        studentId TEXT NOT NULL,
        nombre TEXT NOT NULL,
        edad INTEGER NOT NULL,
        correo TEXT NOT NULL,
        telefono TEXT,
        direccion TEXT,
        genero TEXT,
        grado TEXT,
        nombreTutor TEXT,
        fechaInscripcion TEXT,
        notas TEXT,
        promedioCalificacion REAL
      )
      ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < newVersion) {
      await db.execute('DROP TABLE IF EXISTS estudiantes');
      await _createDB(db, newVersion);
    }
  }

  Future<void> insertEstudiante(Student student) async {
    final db = await database;
    await db.insert('estudiantes', student.toMap());
  }

  Future<List<Student>> getEstudiantes() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('estudiantes');
    return List.generate(maps.length, (i) {
      return Student.fromMap(maps[i]);
    });
  }

  Future<int> updateEstudiante(Student student) async {
    final db = await database;
    return await db.update(
      'estudiantes',
      student.toMap(),
      where: 'id = ?',
      whereArgs: [student.id],
    );
  }

  Future<void> deleteEstudiante(int id) async {
    final db = await database;
    await db.delete(
      'estudiantes',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
