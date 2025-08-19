import 'package:flutter_dating_app/db/database_helper.dart';
import 'package:flutter_dating_app/models/event.dart';
import 'package:flutter_dating_app/models/user.dart';

class EventService {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  // Create a new event
  Future<bool> createEvent({
    required String title,
    required String description,
    required DateTime date,
    required String location,
    required int creatorId,
  }) async {
    try {
      // Validate inputs
      if (title.isEmpty) {
        throw Exception('Event title cannot be empty');
      }

      if (description.isEmpty) {
        throw Exception('Event description cannot be empty');
      }

      if (location.isEmpty) {
        throw Exception('Event location cannot be empty');
      }

      // Validate date is in the future
      if (date.isBefore(DateTime.now())) {
        throw Exception('Event date must be in the future');
      }

      // Create event object
      Event event = Event(
        title: title,
        description: description,
        date: date,
        location: location,
        creatorId: creatorId,
      );

      // Insert event into database
      final eventId = await _dbHelper.insertEvent(event);

      // Automatically add creator as an attendee
      if (eventId > 0) {
        await _dbHelper.addEventAttendee(eventId, creatorId);
        return true;
      }

      return false;
    } catch (e) {
      print('Create event error: $e');
      // Re-throw the exception to be caught by the UI
      rethrow;
    }
  }

  // Get all events
  Future<List<Event>> getAllEvents() async {
    try {
      return await _dbHelper.getAllEvents();
    } catch (e) {
      print('Get all events error: $e');
      rethrow;
    }
  }

  // RSVP to an event
  Future<bool> rsvpToEvent(int eventId, int userId) async {
    try {
      // Check if user is already attending
      final attendees = await _dbHelper.getEventAttendees(eventId);
      if (attendees.contains(userId)) {
        throw Exception('You are already attending this event');
      }

      await _dbHelper.addEventAttendee(eventId, userId);
      return true;
    } catch (e) {
      print('RSVP to event error: $e');
      rethrow;
    }
  }

  // Get event attendees
  Future<List<User>> getEventAttendees(int eventId) async {
    try {
      List<int> attendeeIds = await _dbHelper.getEventAttendees(eventId);
      List<User> attendees = [];

      for (int userId in attendeeIds) {
        User? user = await _dbHelper.getUserById(userId);
        if (user != null) {
          attendees.add(user);
        }
      }

      return attendees;
    } catch (e) {
      print('Get event attendees error: $e');
      rethrow;
    }
  }

  // Get events created by a user
  Future<List<Event>> getUserEvents(int userId) async {
    try {
      final db = await _dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'events',
        where: 'creator_id = ?',
        whereArgs: [userId],
      );

      return List.generate(maps.length, (i) => Event.fromMap(maps[i]));
    } catch (e) {
      print('Get user events error: $e');
      rethrow;
    }
  }

  // Get events a user is attending
  Future<List<Event>> getUserAttendingEvents(int userId) async {
    try {
      final db = await _dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.rawQuery('''
        SELECT e.* FROM events e
        INNER JOIN event_attendees ea ON e.id = ea.event_id
        WHERE ea.user_id = ?
      ''', [userId]);

      return List.generate(maps.length, (i) => Event.fromMap(maps[i]));
    } catch (e) {
      print('Get user attending events error: $e');
      rethrow;
    }
  }
}
