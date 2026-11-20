import '../database/database_helper.dart';
import '../models/user_model.dart';

class AuthService {
  // Singleton
  AuthService._internal();
  static final AuthService instance = AuthService._internal();

  UserModel? _currentUser;
  UserModel? get currentUser => _currentUser;

  bool get isLoggedIn => _currentUser != null;
  bool get isAdmin => _currentUser?.role == 'admin';
  bool get isStudent => _currentUser?.role == 'student';
  bool get isGuard => _currentUser?.role == 'guard';

  void setCurrentUser(UserModel? user) {
    _currentUser = user;
  }

  void logout() {
    _currentUser = null;
  }

  /// Login with email and password
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    final db = await DatabaseHelper.instance.database;
    final normalizedEmail = email.trim().toLowerCase();

    final results = await db.query(
      'users',
      where: 'LOWER(email) = ?',
      whereArgs: [normalizedEmail],
      limit: 1,
    );

    if (results.isEmpty) {
      throw Exception('No account found with this email.');
    }

    final user = UserModel.fromMap(results.first);
    final isPasswordValid = DatabaseHelper.verifyPassword(
      password,
      user.passwordHash,
      user.passwordSalt,
    );

    if (!isPasswordValid) {
      throw Exception('Incorrect password. Please try again.');
    }

    _currentUser = user;
    return user;
  }

  /// Register student account
  Future<UserModel> registerStudent({
    required String name,
    required String rollNumber,
    required String email,
    required String password,
  }) async {
    final db = await DatabaseHelper.instance.database;
    final cleanEmail = email.trim().toLowerCase();
    final cleanRollNumber = rollNumber.trim().toUpperCase();

    // Check email uniqueness
    final emailCheck = await db.query(
      'users',
      where: 'LOWER(email) = ?',
      whereArgs: [cleanEmail],
    );
    if (emailCheck.isNotEmpty) {
      throw Exception('An account with this email already exists.');
    }

    // Check roll number uniqueness
    final rollCheck = await db.query(
      'users',
      where: 'UPPER(roll_number) = ?',
      whereArgs: [cleanRollNumber],
    );
    if (rollCheck.isNotEmpty) {
      throw Exception('A student with this roll number is already registered.');
    }

    final salt = DatabaseHelper.generateSalt();
    final hash = DatabaseHelper.hashPassword(password, salt);

    final id = await db.insert('users', {
      'name': name.trim(),
      'roll_number': cleanRollNumber,
      'email': cleanEmail,
      'password_hash': hash,
      'password_salt': salt,
      'role': 'student',
    });

    final newUser = UserModel(
      id: id,
      name: name.trim(),
      rollNumber: cleanRollNumber,
      email: cleanEmail,
      passwordHash: hash,
      passwordSalt: salt,
      role: 'student',
    );

    _currentUser = newUser;
    return newUser;
  }

  /// Admin feature: Create guard account
  Future<UserModel> createGuardAccount({
    required String name,
    required String email,
    required String password,
  }) async {
    if (!isAdmin) {
      throw Exception(
        'Unauthorized: Only administrators can create guard accounts.',
      );
    }

    final db = await DatabaseHelper.instance.database;
    final cleanEmail = email.trim().toLowerCase();

    final check = await db.query(
      'users',
      where: 'LOWER(email) = ?',
      whereArgs: [cleanEmail],
    );
    if (check.isNotEmpty) {
      throw Exception('An account with this email already exists.');
    }

    final salt = DatabaseHelper.generateSalt();
    final hash = DatabaseHelper.hashPassword(password, salt);

    final id = await db.insert('users', {
      'name': name.trim(),
      'roll_number': null,
      'email': cleanEmail,
      'password_hash': hash,
      'password_salt': salt,
      'role': 'guard',
    });

    return UserModel(
      id: id,
      name: name.trim(),
      rollNumber: null,
      email: cleanEmail,
      passwordHash: hash,
      passwordSalt: salt,
      role: 'guard',
    );
  }

  /// Get list of guard accounts for admin view
  Future<List<UserModel>> getGuards() async {
    final db = await DatabaseHelper.instance.database;
    final results = await db.query(
      'users',
      where: 'role = ?',
      whereArgs: ['guard'],
      orderBy: 'name ASC',
    );
    return results.map((m) => UserModel.fromMap(m)).toList();
  }

  /// Get user by ID
  Future<UserModel?> getUserById(int id) async {
    final db = await DatabaseHelper.instance.database;
    final results = await db.query('users', where: 'id = ?', whereArgs: [id]);
    if (results.isEmpty) return null;
    return UserModel.fromMap(results.first);
  }
}
