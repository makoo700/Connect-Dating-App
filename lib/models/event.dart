class Event {
  final int? id;
  final String title;
  final String description;
  final DateTime date;
  final String location;
  final int creatorId;
  final List<int> attendeeIds;

  Event({
    this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.location,
    required this.creatorId,
    this.attendeeIds = const [],
  });

  // Convert Event object to a Map for SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'date': date.millisecondsSinceEpoch,
      'location': location,
      'creator_id': creatorId,
      // Attendees are stored in a separate table
    };
  }

  // Create an Event object from a Map from SQLite
  factory Event.fromMap(Map<String, dynamic> map) {
    return Event(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      date: DateTime.fromMillisecondsSinceEpoch(map['date']),
      location: map['location'],
      creatorId: map['creator_id'],
      // Attendees are loaded separately
    );
  }

  // Create a copy of the Event with updated fields
  Event copyWith({
    int? id,
    String? title,
    String? description,
    DateTime? date,
    String? location,
    int? creatorId,
    List<int>? attendeeIds,
  }) {
    return Event(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      date: date ?? this.date,
      location: location ?? this.location,
      creatorId: creatorId ?? this.creatorId,
      attendeeIds: attendeeIds ?? this.attendeeIds,
    );
  }
}
