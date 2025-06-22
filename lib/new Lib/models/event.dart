import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

enum EventType { birthday, appointment, meeting, reminder, general, other }

enum RecurrenceType { none, daily, weekly, monthly, yearly }

class EventParticipant {
  final String userId;
  final String? userName;

  EventParticipant({required this.userId, this.userName});

  factory EventParticipant.fromApiJson(Map<String, dynamic> json) {
    print('[DEBUG] EventParticipant.fromApiJson input: $json');
    return EventParticipant(
      userId: json['user_id']?['\$oid'] ?? json['user_id'] ?? '',
      userName: json['user_name'],
    );
  }
}

class Event {
  final String id;
  final String title;
  final String description;
  final DateTime startTime;
  final DateTime endTime;
  final EventType type;
  final Color color;
  final String location;
  final List<EventParticipant> participants;
  final String creatorId;
  final RecurrenceType recurrence;
  final bool isCompleted;
  final bool isCancelled;
  final List<String> attachments;
  final Map<String, dynamic> additionalDetails;
  final DateTime createdAt;
  final DateTime? lastModified;

  Event({
    required this.id,
    required this.title,
    required this.description,
    required this.startTime,
    required this.endTime,
    required this.type,
    required this.color,
    required this.location,
    required this.participants,
    required this.creatorId,
    this.recurrence = RecurrenceType.none,
    this.isCompleted = false,
    this.isCancelled = false,
    this.attachments = const [],
    this.additionalDetails = const {},
    required this.createdAt,
    this.lastModified,
  });

  Event copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? startTime,
    DateTime? endTime,
    EventType? type,
    Color? color,
    String? location,
    List<EventParticipant>? participants,
    String? creatorId,
    RecurrenceType? recurrence,
    bool? isCompleted,
    bool? isCancelled,
    List<String>? attachments,
    Map<String, dynamic>? additionalDetails,
    DateTime? createdAt,
    DateTime? lastModified,
  }) {
    return Event(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      type: type ?? this.type,
      color: color ?? this.color,
      location: location ?? this.location,
      participants: participants ?? this.participants,
      creatorId: creatorId ?? this.creatorId,
      recurrence: recurrence ?? this.recurrence,
      isCompleted: isCompleted ?? this.isCompleted,
      isCancelled: isCancelled ?? this.isCancelled,
      attachments: attachments ?? this.attachments,
      additionalDetails: additionalDetails ?? this.additionalDetails,
      createdAt: createdAt ?? this.createdAt,
      lastModified: lastModified ?? DateTime.now(),
    );
  }

  factory Event.fromApiJson(Map<String, dynamic> json) {
    print('[DEBUG] Event.fromApiJson input: $json');
    List<EventParticipant> parsedParticipants = [];
    if (json['participants'] is List) {
      for (var p in (json['participants'] as List)) {
        print('[DEBUG] Parsing participant: $p');
        if (p is Map<String, dynamic>) {
          parsedParticipants.add(EventParticipant.fromApiJson(p));
        } else {
          print('[DEBUG] Skipping non-map participant: $p');
        }
      }
    }
    final Map<String, dynamic> additionalDetails = {};
    if (json.containsKey('privacy')) {
      additionalDetails['privacy'] = json['privacy'];
    }
    return Event(
      id: (json['_id'] is Map && json['_id']['\$oid'] != null)
          ? json['_id']['\$oid']
          : (json['_id'] ?? const Uuid().v4()),
      title: json['title'] ?? 'No Title',
      description: json['description'] ?? '',
      startTime: _parseDate(json['start_time']),
      endTime: _parseDate(json['end_time']),
      type: _parseEventType(json['type'] ?? 'general'),
      color: _getColorForType(json['type'] ?? 'general'),
      location: json['location'] ?? '',
      participants: parsedParticipants,
      creatorId: json['creator_id']?.toString() ?? '',
      recurrence: RecurrenceType.none,
      isCompleted: json['status'] == 'completed',
      isCancelled: json['status'] == 'cancelled',
      attachments: [],
      additionalDetails: additionalDetails,
      createdAt: json['created_at'] != null ? _parseDate(json['created_at']) : DateTime.now(),
      lastModified: json['updated_at'] != null ? _parseDate(json['updated_at']) : null,
    );
  }

  static DateTime _parseDate(dynamic value) {
    if (value is String) {
      return DateTime.parse(value).toLocal();
    }
    if (value is Map && value['\$date'] != null) {
      return DateTime.parse(value['\$date']).toLocal();
    }
    throw Exception('Invalid date format: $value');
  }

  static EventType _parseEventType(String type) {
    switch (type.toLowerCase()) {
      case 'birthday':
        return EventType.birthday;
      case 'appointment':
        return EventType.appointment;
      case 'meeting':
        return EventType.meeting;
      case 'reminder':
        return EventType.reminder;
      case 'general':
        return EventType.general;
      default:
        return EventType.other;
    }
  }

  static Color _getColorForType(String type) {
    switch (type.toLowerCase()) {
      case 'birthday':
        return Colors.pink;
      case 'appointment':
        return Colors.blue;
      case 'meeting':
        return Colors.green;
      case 'reminder':
        return Colors.orange;
      case 'general':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'start_time': startTime.toUtc().toIso8601String(),
      'end_time': endTime.toUtc().toIso8601String(),
      'type': type.toString().split('.').last,
      'location': location,
      'participants': participants,
      'created_by': creatorId,
      'status':
          isCompleted ? 'completed' : (isCancelled ? 'cancelled' : 'upcoming'),
    };
  }
}
