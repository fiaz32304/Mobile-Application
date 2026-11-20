import 'dart:io';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../database/database_helper.dart';

class _GoogleAuthClient extends http.BaseClient {
  final Map<String, String> _headers;
  final http.Client _client = http.Client();

  _GoogleAuthClient(this._headers);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers.addAll(_headers);
    return _client.send(request);
  }
}

class GoogleDriveService {
  GoogleDriveService._internal();
  static final GoogleDriveService instance = GoogleDriveService._internal();

  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  GoogleSignInAccount? _currentUser;

  GoogleSignInAccount? get currentUser => _currentUser;
  bool get isSignedIn => _currentUser != null;

  static const String _backupFileName = 'university_events_backup.db';
  static const String _webClientId =
      '712786697851-8t6b37cr1tjhnpj0jp73jibij7vdjg3j.apps.googleusercontent.com';

  Future<void> initialize() async {
    try {
      await _googleSignIn.initialize(
        serverClientId: _webClientId,
      );
    } catch (_) {}
  }

  Future<GoogleSignInAccount?> signIn() async {
    try {
      await initialize();
      final account = await _googleSignIn.authenticate();

      await account.authorizationClient.authorizeScopes([
        drive.DriveApi.driveFileScope,
        drive.DriveApi.driveAppdataScope,
      ]);
      _currentUser = account;
      return account;
    } catch (e) {
      throw Exception('Google Sign-In Failed: $e');
    }
  }

  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
    } catch (_) {}
    _currentUser = null;
  }

  Future<http.Client> _getAuthenticatedClient() async {
    var account = _currentUser;
    account ??= await signIn();
    if (account == null) {
      throw Exception('User is not signed in to Google.');
    }

    try {
      final auth = await account.authorizationClient.authorizeScopes([
        drive.DriveApi.driveFileScope,
        drive.DriveApi.driveAppdataScope,
      ]);
      return _GoogleAuthClient({'Authorization': 'Bearer ${auth.accessToken}'});
    } catch (_) {
      _currentUser = null;
      account = await signIn();
      if (account == null) {
        throw Exception('User cancelled Google Drive permissions.');
      }
      final auth = await account.authorizationClient.authorizeScopes([
        drive.DriveApi.driveFileScope,
        drive.DriveApi.driveAppdataScope,
      ]);
      return _GoogleAuthClient({'Authorization': 'Bearer ${auth.accessToken}'});
    }
  }

  /// Upload SQLite database file to Google Drive
  Future<String> uploadBackup() async {
    final client = await _getAuthenticatedClient();
    final driveApi = drive.DriveApi(client);

    final dbPath = await getDatabasesPath();
    final localDbFile = File(join(dbPath, 'university_events.db'));

    if (!await localDbFile.exists()) {
      throw Exception('Local database file does not exist.');
    }

    final fileSize = await localDbFile.length();
    final media = drive.Media(localDbFile.openRead(), fileSize);

    // Search for existing backup file on Google Drive
    final fileList = await driveApi.files.list(
      q: "name = '$_backupFileName' and trashed = false",
      $fields: 'files(id, name, modifiedTime)',
    );

    if (fileList.files != null && fileList.files!.isNotEmpty) {
      // Update existing backup file
      final existingFileId = fileList.files!.first.id!;
      final updatedFile = await driveApi.files.update(
        drive.File()..name = _backupFileName,
        existingFileId,
        uploadMedia: media,
      );
      return 'Backup updated successfully on Google Drive! (ID: ${updatedFile.id})';
    } else {
      // Create new backup file
      final newFile = drive.File()
        ..name = _backupFileName
        ..description =
            'Backup database for University Event Management System';

      final createdFile = await driveApi.files.create(
        newFile,
        uploadMedia: media,
      );
      return 'Backup created successfully on Google Drive! (ID: ${createdFile.id})';
    }
  }

  /// Download backup file from Google Drive and restore local database
  Future<String> restoreBackup() async {
    final client = await _getAuthenticatedClient();
    final driveApi = drive.DriveApi(client);

    // Search for existing backup file on Google Drive
    final fileList = await driveApi.files.list(
      q: "name = '$_backupFileName' and trashed = false",
      $fields: 'files(id, name, modifiedTime)',
    );

    if (fileList.files == null || fileList.files!.isEmpty) {
      throw Exception('No backup file found on Google Drive.');
    }

    final backupFileId = fileList.files!.first.id!;

    // Download file content from Google Drive
    final drive.Media downloadedMedia = await driveApi.files.get(
      backupFileId,
      downloadOptions: drive.DownloadOptions.fullMedia,
    ) as drive.Media;

    final List<int> dataBytes = [];
    await for (final chunk in downloadedMedia.stream) {
      dataBytes.addAll(chunk);
    }

    if (dataBytes.isEmpty) {
      throw Exception('Downloaded backup file is empty or corrupted.');
    }

    // Close active database before replacing file
    await DatabaseHelper.instance.close();

    final dbPath = await getDatabasesPath();
    final localDbFile = File(join(dbPath, 'university_events.db'));

    // Write downloaded bytes to local database file
    await localDbFile.writeAsBytes(dataBytes, flush: true);

    // Re-open database
    await DatabaseHelper.instance.database;

    return 'Database restored successfully from Google Drive backup!';
  }

  /// Get details of last backup on Google Drive
  Future<drive.File?> getLatestBackupInfo() async {
    try {
      final client = await _getAuthenticatedClient();
      final driveApi = drive.DriveApi(client);

      final fileList = await driveApi.files.list(
        q: "name = '$_backupFileName' and trashed = false",
        $fields: 'files(id, name, modifiedTime, size)',
      );

      if (fileList.files != null && fileList.files!.isNotEmpty) {
        return fileList.files!.first;
      }
    } catch (_) {}
    return null;
  }
}
