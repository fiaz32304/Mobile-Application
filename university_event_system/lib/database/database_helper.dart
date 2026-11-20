import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static const String _databaseName = 'university_events.db';
  static const int _databaseVersion = 1;

  // Singleton instance
  DatabaseHelper._internal();
  static final DatabaseHelper instance = DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _databaseName);

    final db = await openDatabase(
      path,
      version: _databaseVersion,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON;');
      },
      onCreate: _onCreate,
    );

    await _ensureDefaultUsers(db);
    return db;
  }

  Future<void> _onCreate(Database db, int version) async {
    // 1. Users Table
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        roll_number TEXT UNIQUE,
        email TEXT UNIQUE NOT NULL,
        password_hash TEXT NOT NULL,
        password_salt TEXT NOT NULL,
        role TEXT NOT NULL
      )
    ''');

    // 2. Events Table
    await db.execute('''
      CREATE TABLE events (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        category TEXT NOT NULL,
        event_date TEXT NOT NULL,
        event_time TEXT NOT NULL,
        venue TEXT NOT NULL,
        ticket_price REAL NOT NULL,
        capacity INTEGER NOT NULL,
        created_by INTEGER NOT NULL,
        FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE CASCADE
      )
    ''');

    // 3. Registrations Table
    await db.execute('''
      CREATE TABLE registrations (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        student_id INTEGER NOT NULL,
        event_id INTEGER NOT NULL,
        status TEXT NOT NULL,
        registration_date TEXT NOT NULL,
        FOREIGN KEY (student_id) REFERENCES users(id) ON DELETE CASCADE,
        FOREIGN KEY (event_id) REFERENCES events(id) ON DELETE CASCADE
      )
    ''');

    // 4. Payments Table
    await db.execute('''
      CREATE TABLE payments (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        registration_id INTEGER UNIQUE NOT NULL,
        amount REAL NOT NULL,
        payment_method TEXT NOT NULL,
        transaction_reference TEXT NOT NULL,
        payment_status TEXT NOT NULL,
        verified_by INTEGER,
        verified_at TEXT,
        FOREIGN KEY (registration_id) REFERENCES registrations(id) ON DELETE CASCADE,
        FOREIGN KEY (verified_by) REFERENCES users(id) ON DELETE SET NULL
      )
    ''');

    // 5. Tickets Table
    await db.execute('''
      CREATE TABLE tickets (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        registration_id INTEGER UNIQUE NOT NULL,
        ticket_code TEXT UNIQUE NOT NULL,
        verification_token TEXT UNIQUE NOT NULL,
        ticket_status TEXT NOT NULL,
        issued_at TEXT NOT NULL,
        used_at TEXT,
        verified_by INTEGER,
        FOREIGN KEY (registration_id) REFERENCES registrations(id) ON DELETE CASCADE,
        FOREIGN KEY (verified_by) REFERENCES users(id) ON DELETE SET NULL
      )
    ''');

    // Seed Demo Data
    await _seedInitialData(db);
  }

  // Password hashing helpers
  static String generateSalt([int length = 16]) {
    final random = Random.secure();
    final values = List<int>.generate(length, (i) => random.nextInt(256));
    return base64Url.encode(values);
  }

  static String hashPassword(String password, String salt) {
    final bytes = utf8.encode(salt + password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  static bool verifyPassword(
    String password,
    String storedHash,
    String storedSalt,
  ) {
    final calculatedHash = hashPassword(password, storedSalt);
    return calculatedHash == storedHash;
  }

  Future<void> _ensureDefaultUsers(Database db) async {
    // 1. Ensure Primary Admin (abdullah123@gmail.com)
    final admin1 = await db.query(
      'users',
      where: 'LOWER(email) = ?',
      whereArgs: ['abdullah123@gmail.com'],
    );
    if (admin1.isEmpty) {
      final salt = generateSalt();
      final hash = hashPassword('admin123', salt);
      await db.insert('users', {
        'name': 'System Administrator',
        'roll_number': null,
        'email': 'abdullah123@gmail.com',
        'password_hash': hash,
        'password_salt': salt,
        'role': 'admin',
      });
    }

    // 2. Ensure Secondary Admin Alias (admin@university.edu)
    final admin2 = await db.query(
      'users',
      where: 'LOWER(email) = ?',
      whereArgs: ['admin@university.edu'],
    );
    if (admin2.isEmpty) {
      final salt = generateSalt();
      final hash = hashPassword('admin123', salt);
      await db.insert('users', {
        'name': 'System Administrator',
        'roll_number': null,
        'email': 'admin@university.edu',
        'password_hash': hash,
        'password_salt': salt,
        'role': 'admin',
      });
    }

    // 3. Ensure Student (fiaz1983@gmail.com)
    final student1 = await db.query(
      'users',
      where: 'LOWER(email) = ?',
      whereArgs: ['fiaz1983@gmail.com'],
    );
    if (student1.isEmpty) {
      final salt = generateSalt();
      final hash = hashPassword('Fiaz1983', salt);
      await db.insert('users', {
        'name': 'Fiaz Ahmad',
        'roll_number': 'FA24-BSE-127',
        'email': 'fiaz1983@gmail.com',
        'password_hash': hash,
        'password_salt': salt,
        'role': 'student',
      });
    }

    // 4. Ensure Guard (guard@university.edu)
    final guard1 = await db.query(
      'users',
      where: 'LOWER(email) = ?',
      whereArgs: ['guard@university.edu'],
    );
    if (guard1.isEmpty) {
      final salt = generateSalt();
      final hash = hashPassword('guard123', salt);
      await db.insert('users', {
        'name': 'Officer Tariq',
        'roll_number': null,
        'email': 'guard@university.edu',
        'password_hash': hash,
        'password_salt': salt,
        'role': 'guard',
      });
    }
  }

  Future<void> _seedInitialData(DatabaseExecutor db) async {
    await _ensureDefaultUsers(db as Database);
  }

  // Close database
  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}
