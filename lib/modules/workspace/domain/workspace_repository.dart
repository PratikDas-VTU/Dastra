import 'models/workspace_record.dart';
import '../data/database_helper.dart';

class WorkspaceRepository {
  final WorkspaceDatabaseHelper _dbHelper;
  
  WorkspaceRepository(this._dbHelper);

  Future<void> insertRecord(WorkspaceRecord record) async {
    final db = await _dbHelper.database;
    await db.insert(
      'workspace_records',
      record.toMap(),
    );
  }

  Future<List<WorkspaceRecord>> getAllRecords() async {
    final db = await _dbHelper.database;
    final result = await db.query('workspace_records', where: 'isDeleted = 0', orderBy: 'createdAt DESC');
    return result.map((map) => WorkspaceRecord.fromMap(map)).toList();
  }

  Future<void> deleteRecord(String id) async {
    final db = await _dbHelper.database;
    await db.update(
      'workspace_records',
      {'isDeleted': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> toggleFavorite(String id, bool isFavorite) async {
    final db = await _dbHelper.database;
    await db.update(
      'workspace_records',
      {'isFavorite': isFavorite ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<String>> getRecentlyUsedToolIds(int limit) async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery(
      'SELECT toolId, MAX(createdAt) as lastUsed FROM workspace_records WHERE isDeleted = 0 GROUP BY toolId ORDER BY lastUsed DESC LIMIT ?',
      [limit],
    );
    return result.map((map) => map['toolId'] as String).toList();
  }

  Future<List<String>> getMostUsedToolIds(int limit) async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery(
      'SELECT toolId, COUNT(*) as count FROM workspace_records WHERE isDeleted = 0 GROUP BY toolId ORDER BY count DESC LIMIT ?',
      [limit],
    );
    return result.map((map) => map['toolId'] as String).toList();
  }

  Future<void> clearAllRecords() async {
    final db = await _dbHelper.database;
    await db.update(
      'workspace_records',
      {'isDeleted': 1},
    );
  }
}
