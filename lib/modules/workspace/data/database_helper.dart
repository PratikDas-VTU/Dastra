import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../../../core/storage/storage_service.dart';

class WorkspaceDatabaseHelper {
  final StorageService storageService;
  Database? _database;

  WorkspaceDatabaseHelper(this.storageService);

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('dastra_workspace.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    final dbPath = await storageService.getDatabasePath(filePath);
    
    // Ensure the directory exists
    await Directory(dirname(dbPath)).create(recursive: true);

    return await databaseFactory.openDatabase(
      dbPath,
      options: OpenDatabaseOptions(
        version: 2,
        onCreate: _createDB,
        onUpgrade: _upgradeDB,
      ),
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
CREATE TABLE workspace_records (
  id TEXT PRIMARY KEY,
  toolId TEXT NOT NULL,
  toolName TEXT NOT NULL,
  engineId TEXT,
  inputPath TEXT NOT NULL,
  outputPath TEXT NOT NULL,
  outputFolder TEXT NOT NULL,
  outputExtension TEXT NOT NULL,
  inputSize INTEGER NOT NULL,
  outputSize INTEGER NOT NULL,
  processingTime INTEGER NOT NULL,
  createdAt TEXT NOT NULL,
  status TEXT NOT NULL,
  isFavorite INTEGER NOT NULL DEFAULT 0,
  isDeleted INTEGER NOT NULL DEFAULT 0,
  tags TEXT,
  notes TEXT,
  thumbnailPath TEXT,
  projectId TEXT
)
''');
  }

  Future _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE workspace_records ADD COLUMN tags TEXT;');
      await db.execute('ALTER TABLE workspace_records ADD COLUMN notes TEXT;');
      await db.execute('ALTER TABLE workspace_records ADD COLUMN thumbnailPath TEXT;');
      await db.execute('ALTER TABLE workspace_records ADD COLUMN projectId TEXT;');
    }
  }

  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}
