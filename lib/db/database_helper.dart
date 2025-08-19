import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter_dating_app/models/user.dart';
import 'package:flutter_dating_app/models/message.dart';
import 'package:flutter_dating_app/models/event.dart';
import 'package:flutter_dating_app/models/match.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'dating_app.db');
    return await openDatabase(
      path,
      version: 2, // Increased version for schema update
      onCreate: _createDatabase,
      onUpgrade: _upgradeDatabase,
    );
  }

  Future<void> _upgradeDatabase(
      Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add user_images table in version 2
      await db.execute('''
        CREATE TABLE user_images(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          user_id INTEGER NOT NULL,
          image_path TEXT NOT NULL,
          is_profile INTEGER NOT NULL DEFAULT 0,
          created_at INTEGER NOT NULL,
          FOREIGN KEY (user_id) REFERENCES users (id)
        )
      ''');
    }
  }

  Future<void> _createDatabase(Database db, int version) async {
    // Users table
    await db.execute('''
      CREATE TABLE users(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL,
        phone TEXT,
        age INTEGER NOT NULL,
        gender TEXT NOT NULL,
        bio TEXT,
        interests TEXT,
        profile_image_path TEXT,
        latitude REAL,
        longitude REAL
      )
    ''');

    // Matches table
    await db.execute('''
      CREATE TABLE matches(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        matched_user_id INTEGER NOT NULL,
        match_score INTEGER NOT NULL,
        is_liked INTEGER NOT NULL DEFAULT 0,
        is_matched INTEGER NOT NULL DEFAULT 0,
        created_at INTEGER NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id),
        FOREIGN KEY (matched_user_id) REFERENCES users (id)
      )
    ''');

    // Messages table
    await db.execute('''
      CREATE TABLE messages(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        sender_id INTEGER NOT NULL,
        receiver_id INTEGER NOT NULL,
        text TEXT NOT NULL,
        timestamp INTEGER NOT NULL,
        is_read INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (sender_id) REFERENCES users (id),
        FOREIGN KEY (receiver_id) REFERENCES users (id)
      )
    ''');

    // Events table
    await db.execute('''
      CREATE TABLE events(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT,
        date INTEGER NOT NULL,
        location TEXT,
        creator_id INTEGER NOT NULL,
        FOREIGN KEY (creator_id) REFERENCES users (id)
      )
    ''');

    // Event attendees table
    await db.execute('''
      CREATE TABLE event_attendees(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        event_id INTEGER NOT NULL,
        user_id INTEGER NOT NULL,
        FOREIGN KEY (event_id) REFERENCES events (id),
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');

    // Clubs/Societies table
    await db.execute('''
      CREATE TABLE clubs(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL
      )
    ''');

    // User clubs table
    await db.execute('''
      CREATE TABLE user_clubs(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        club_id INTEGER NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id),
        FOREIGN KEY (club_id) REFERENCES clubs (id)
      )
    ''');

    // User images table (added in version 2)
    if (version >= 2) {
      await db.execute('''
        CREATE TABLE user_images(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          user_id INTEGER NOT NULL,
          image_path TEXT NOT NULL,
          is_profile INTEGER NOT NULL DEFAULT 0,
          created_at INTEGER NOT NULL,
          FOREIGN KEY (user_id) REFERENCES users (id)
        )
      ''');
    }
  }

  // User CRUD operations
  Future<int> insertUser(User user) async {
    Database db = await database;
    return await db.insert('users', user.toMap());
  }

  Future<User?> getUserById(int id) async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }

  Future<User?> getUserByEmail(String email) async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );

    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }

  Future<List<User>> getAllUsers() async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query('users');
    return List.generate(maps.length, (i) => User.fromMap(maps[i]));
  }

  Future<int> updateUser(User user) async {
    Database db = await database;
    return await db.update(
      'users',
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  Future<int> deleteUser(int id) async {
    Database db = await database;
    return await db.delete(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // User images operations
  Future<int> addUserImage(int userId, String imagePath,
      {bool isProfile = false}) async {
    Database db = await database;
    return await db.insert('user_images', {
      'user_id': userId,
      'image_path': imagePath,
      'is_profile': isProfile ? 1 : 0,
      'created_at': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Future<List<String>> getUserImages(int userId) async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query(
      'user_images',
      columns: ['image_path'],
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'created_at DESC',
    );

    return List.generate(maps.length, (i) => maps[i]['image_path'] as String);
  }

  Future<int> deleteUserImage(int userId, String imagePath) async {
    Database db = await database;
    return await db.delete(
      'user_images',
      where: 'user_id = ? AND image_path = ?',
      whereArgs: [userId, imagePath],
    );
  }

  // Match operations
  Future<int> insertMatch(Match match) async {
    Database db = await database;
    // Check if a match already exists for this user and matched user
    List<Map<String, dynamic>> existing = await db.query(
      'matches',
      where: 'user_id = ? AND matched_user_id = ?',
      whereArgs: [match.userId, match.matchedUserId],
    );
    if (existing.isNotEmpty) {
      // Update the existing match
      int matchId = existing.first['id'] as int;
      return await db.update(
        'matches',
        match.toMap(),
        where: 'id = ?',
        whereArgs: [matchId],
      );
    } else {
      // Insert new match
      return await db.insert('matches', match.toMap());
    }
  }

  Future<int> updateMatch(Match match) async {
    Database db = await database;
    return await db.update(
      'matches',
      match.toMap(),
      where: 'id = ?',
      whereArgs: [match.id],
    );
  }

  Future<List<Match>> getMatchesForUser(int userId) async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query(
      'matches',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
    return List.generate(maps.length, (i) => Match.fromMap(maps[i]));
  }

  Future<List<User>> getMatchedUsers(int userId) async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT u.* FROM users u
      INNER JOIN matches m ON u.id = m.matched_user_id
      WHERE m.user_id = ? AND m.is_matched = 1
    ''', [userId]);
    return List.generate(maps.length, (i) => User.fromMap(maps[i]));
  }

  /// Returns all users that the given user has liked (is_liked = 1), regardless of mutual match status
  Future<List<User>> getLikedUsers(int userId) async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT u.* FROM users u
      INNER JOIN matches m ON u.id = m.matched_user_id
      WHERE m.user_id = ? AND m.is_liked = 1
    ''', [userId]);
    return List.generate(maps.length, (i) => User.fromMap(maps[i]));
  }

  // Message operations
  Future<int> insertMessage(Message message) async {
    Database db = await database;
    return await db.insert('messages', message.toMap());
  }

  Future<List<Message>> getMessagesForChat(int userId, int otherUserId) async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT * FROM messages
      WHERE (sender_id = ? AND receiver_id = ?) OR (sender_id = ? AND receiver_id = ?)
      ORDER BY timestamp ASC
    ''', [userId, otherUserId, otherUserId, userId]);
    return List.generate(maps.length, (i) => Message.fromMap(maps[i]));
  }

  Future<List<Map<String, dynamic>>> getChatPreviews(int userId) async {
    Database db = await database;
    return await db.rawQuery('''
      SELECT 
        u.id, u.name, u.profile_image_path,
        m.text, m.timestamp, m.is_read, m.sender_id
      FROM users u
      INNER JOIN (
        SELECT 
          CASE 
            WHEN sender_id = ? THEN receiver_id
            ELSE sender_id
          END as other_user_id,
          text, timestamp, is_read, sender_id,
          MAX(timestamp) as latest_timestamp
        FROM messages
        WHERE sender_id = ? OR receiver_id = ?
        GROUP BY other_user_id
      ) m ON u.id = m.other_user_id
      ORDER BY m.latest_timestamp DESC
    ''', [userId, userId, userId]);
  }

  // Event operations
  Future<int> insertEvent(Event event) async {
    Database db = await database;
    return await db.insert('events', event.toMap());
  }

  Future<List<Event>> getAllEvents() async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query('events');
    return List.generate(maps.length, (i) => Event.fromMap(maps[i]));
  }

  Future<int> addEventAttendee(int eventId, int userId) async {
    Database db = await database;
    return await db.insert('event_attendees', {
      'event_id': eventId,
      'user_id': userId,
    });
  }

  Future<List<int>> getEventAttendees(int eventId) async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query(
      'event_attendees',
      columns: ['user_id'],
      where: 'event_id = ?',
      whereArgs: [eventId],
    );
    return List.generate(maps.length, (i) => maps[i]['user_id'] as int);
  }

  // Club operations
  Future<int> insertClub(String name) async {
    Database db = await database;
    return await db.insert('clubs', {'name': name});
  }

  Future<int> addUserToClub(int userId, int clubId) async {
    Database db = await database;
    return await db.insert('user_clubs', {
      'user_id': userId,
      'club_id': clubId,
    });
  }

  Future<List<Map<String, dynamic>>> getUserClubs(int userId) async {
    Database db = await database;
    return await db.rawQuery('''
      SELECT c.* FROM clubs c
      INNER JOIN user_clubs uc ON c.id = uc.club_id
      WHERE uc.user_id = ?
    ''', [userId]);
  }

  // Calculate match score between two users
  Future<int> calculateMatchScore(int userId1, int userId2) async {
    Database db = await database;

    // Get users
    User? user1 = await getUserById(userId1);
    User? user2 = await getUserById(userId2);

    if (user1 == null || user2 == null) return 0;

    int score = 0;

    // Score based on shared interests
    List<String> interests1 = user1.interests;
    List<String> interests2 = user2.interests;

    for (String interest in interests1) {
      if (interests2.contains(interest)) {
        score += 10;
      }
    }

    // Score based on shared clubs
    List<Map<String, dynamic>> clubs1 = await getUserClubs(userId1);
    List<Map<String, dynamic>> clubs2 = await getUserClubs(userId2);

    List<int> clubIds1 = clubs1.map((c) => c['id'] as int).toList();
    List<int> clubIds2 = clubs2.map((c) => c['id'] as int).toList();

    for (int clubId in clubIds1) {
      if (clubIds2.contains(clubId)) {
        score += 15;
      }
    }

    return score;
  }
}
