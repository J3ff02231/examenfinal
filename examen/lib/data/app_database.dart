import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart' as sqflite;
import 'package:sqflite_common_ffi/sqflite_ffi.dart' as ffi;

class AppDatabase {
  AppDatabase._internal();

  static final AppDatabase _instance = AppDatabase._internal();

  factory AppDatabase() => _instance;

  sqflite.Database? _database;

  Future<sqflite.Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<sqflite.Database> _initDatabase() async {
    final databasePath = await _getDatabasePath();
    final path = join(databasePath, 'academy_app.db');

    final factory = _getFactory();

    return factory.openDatabase(
      path,
      options: sqflite.OpenDatabaseOptions(
        version: 1,
        onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE courses(
            id INTEGER PRIMARY KEY,
            title TEXT NOT NULL,
            description TEXT NOT NULL,
            instructor TEXT NOT NULL,
            duration TEXT NOT NULL,
            category TEXT NOT NULL
          )
        ''');

        await db.execute('''
          CREATE TABLE progress(
            course_id INTEGER PRIMARY KEY,
            completed_lessons INTEGER NOT NULL,
            total_lessons INTEGER NOT NULL
          )
        ''');

        await _seedData(db);
        },
        onOpen: (db) async {
        await _ensureSeedData(db);
        },
      ),
    );
  }

  sqflite.DatabaseFactory _getFactory() {
    if (_isDesktop()) {
      ffi.sqfliteFfiInit();
      return ffi.databaseFactoryFfi;
    }

    return sqflite.databaseFactory;
  }

  Future<String> _getDatabasePath() async {
    if (_isDesktop()) {
      ffi.sqfliteFfiInit();
      return ffi.databaseFactoryFfi.getDatabasesPath();
    }

    return sqflite.getDatabasesPath();
  }

  bool _isDesktop() {
    if (kIsWeb) {
      return false;
    }

    return defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.linux ||
        defaultTargetPlatform == TargetPlatform.macOS;
  }

  Future<void> _ensureSeedData(sqflite.Database db) async {
    final result = await db.rawQuery('SELECT COUNT(*) as total FROM courses');
    final total = sqflite.Sqflite.firstIntValue(result) ?? 0;

    if (total == 0) {
      await _seedData(db);
    }
  }

  Future<void> _seedData(sqflite.Database db) async {
    final batch = db.batch();

    final courses = [
      {
        'id': 1,
        'title': 'Flutter desde cero',
        'description':
            'Aprende widgets, navegacion y construccion de interfaces modernas.',
        'instructor': 'Ana Rivera',
        'duration': '6 semanas',
        'category': 'Mobile',
      },
      {
        'id': 2,
        'title': 'SQLite practico',
        'description':
            'Guarda datos locales y crea aplicaciones con persistencia simple.',
        'instructor': 'Carlos Mena',
        'duration': '4 semanas',
        'category': 'Base de datos',
      },
      {
        'id': 3,
        'title': 'Riverpod esencial',
        'description':
            'Administra estado de forma ordenada y separa la UI de la logica.',
        'instructor': 'Lucia Torres',
        'duration': '5 semanas',
        'category': 'Estado',
      },
      {
        'id': 4,
        'title': 'Arquitectura limpia',
        'description':
            'Organiza tu proyecto en capas para hacerlo escalable y mantenible.',
        'instructor': 'Diego Paz',
        'duration': '3 semanas',
        'category': 'Arquitectura',
      },
    ];

    final progress = [
      {
        'course_id': 1,
        'completed_lessons': 3,
        'total_lessons': 10,
      },
      {
        'course_id': 2,
        'completed_lessons': 5,
        'total_lessons': 8,
      },
      {
        'course_id': 3,
        'completed_lessons': 2,
        'total_lessons': 12,
      },
      {
        'course_id': 4,
        'completed_lessons': 1,
        'total_lessons': 6,
      },
    ];

    for (final course in courses) {
      batch.insert('courses', course);
    }

    for (final item in progress) {
      batch.insert('progress', item);
    }

    await batch.commit(noResult: true);
  }
}
