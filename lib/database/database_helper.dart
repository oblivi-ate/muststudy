import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'must_study.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // 创建用户表
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username VARCHAR(50) UNIQUE NOT NULL,
        password VARCHAR(255) NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // 创建学习记录表
    await db.execute('''
      CREATE TABLE study_records (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        subject VARCHAR(50) NOT NULL,
        study_time INTEGER NOT NULL,
        date DATE NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (user_id) REFERENCES users(id)
      )
    ''');

    // 创建学习目标表
    await db.execute('''
      CREATE TABLE study_goals (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        subject VARCHAR(50) NOT NULL,
        target_time INTEGER NOT NULL,
        start_date DATE NOT NULL,
        end_date DATE NOT NULL,
        status VARCHAR(20) DEFAULT 'active',
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (user_id) REFERENCES users(id)
      )
    ''');

    // 创建学习统计表
    await db.execute('''
      CREATE TABLE study_statistics (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        total_study_time INTEGER DEFAULT 0,
        longest_streak INTEGER DEFAULT 0,
        current_streak INTEGER DEFAULT 0,
        last_study_date DATE,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (user_id) REFERENCES users(id)
      )
    ''');
  }

  // 用户相关操作
  Future<int> insertUser(Map<String, dynamic> user) async {
    Database db = await database;
    return await db.insert('users', user);
  }

  Future<Map<String, dynamic>?> getUserByUsername(String username) async {
    Database db = await database;
    List<Map<String, dynamic>> results = await db.query(
      'users',
      where: 'username = ?',
      whereArgs: [username],
    );
    return results.isNotEmpty ? results.first : null;
  }

  // 学习记录相关操作
  Future<int> insertStudyRecord(Map<String, dynamic> record) async {
    Database db = await database;
    return await db.insert('study_records', record);
  }

  Future<List<Map<String, dynamic>>> getStudyRecords(int userId, {DateTime? date}) async {
    Database db = await database;
    if (date != null) {
      return await db.query(
        'study_records',
        where: 'user_id = ? AND date = ?',
        whereArgs: [userId, date.toString().split(' ')[0]],
      );
    }
    return await db.query(
      'study_records',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
  }

  // 学习目标相关操作
  Future<int> insertStudyGoal(Map<String, dynamic> goal) async {
    Database db = await database;
    return await db.insert('study_goals', goal);
  }

  Future<List<Map<String, dynamic>>> getStudyGoals(int userId) async {
    Database db = await database;
    return await db.query(
      'study_goals',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
  }

  // 学习统计相关操作
  Future<Map<String, dynamic>?> getStudyStatistics(int userId) async {
    Database db = await database;
    List<Map<String, dynamic>> results = await db.query(
      'study_statistics',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
    return results.isNotEmpty ? results.first : null;
  }

  Future<void> updateStudyStatistics(int userId, Map<String, dynamic> statistics) async {
    Database db = await database;
    await db.update(
      'study_statistics',
      statistics,
      where: 'user_id = ?',
      whereArgs: [userId],
    );
  }
} 