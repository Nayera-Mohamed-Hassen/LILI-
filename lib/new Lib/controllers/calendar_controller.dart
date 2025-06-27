import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/event.dart' as myevent;
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/calendar_service.dart';
import '../../user_session.dart';
import '../../services/notification_service.dart';
import '../../services/user_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../config.dart';

class CalendarController extends GetxController {
  final RxList<myevent.Event> events = <myevent.Event>[].obs;
  final Rx<DateTime> selectedDate = DateTime.now().obs;
  final Rx<myevent.Event?> selectedEvent = Rx<myevent.Event?>(null);
  final RxBool isSyncing = false.obs;
  SharedPreferences? prefs;

  @override
  void onInit() {
    super.onInit();
    _initPrefs();
    fetchEvents();
  }

  Future<void> _initPrefs() async {
    prefs = await SharedPreferences.getInstance();
  }

  Future<void> fetchEvents() async {
    try {
      isSyncing.value = true;
      final userId = UserSession().getUserId();
      final houseId = UserSession().getHouseId();
      if (userId == null || userId.isEmpty) {
        return;
      }
      final fetchedEvents = await CalendarService.fetchEvents(
        userId: userId,
        houseId: houseId,
      );
      events.assignAll(fetchedEvents);
    } catch (e, st) {
    } finally {
      isSyncing.value = false;
    }
  }

  List<myevent.Event> getEventsForDate(DateTime date) {
    final dateOnly = DateTime(date.year, date.month, date.day);
    return events.where((event) {
      final eventDate = DateTime(
        event.startTime.year,
        event.startTime.month,
        event.startTime.day,
      );
      return eventDate == dateOnly;
    }).toList();
  }

  Future<void> addEventFromForm(Map<String, dynamic> eventData) async {
    try {
      isSyncing.value = true;
      final userId = UserSession().getUserId();
      final houseId =
          UserSession().getHouseId != null ? UserSession().getHouseId() : null;
      if (userId == null || userId.isEmpty) return;
      eventData['creator_id'] = userId;
      eventData['house_id'] = houseId;
      await CalendarService.addEvent(eventData);
      await fetchEvents();
      // --- Notification logic ---
      final notificationService = NotificationService();
      final isPublic = eventData['privacy'] == 'public';
      List<String> recipientIds = [];
      if (isPublic && houseId != null && houseId.isNotEmpty) {
        // Fetch all household users
        try {
          final url = Uri.parse(
            '${AppConfig.apiBaseUrl}/user/household-users/$userId',
          );
          final response = await http.get(url);
          if (response.statusCode == 200) {
            final List<dynamic> data = jsonDecode(response.body);
            recipientIds =
                data.map<String>((u) => u['user_id'].toString()).toList();
          }
        } catch (e) {
          recipientIds = [userId]; // fallback: at least notify self
        }
      } else {
        recipientIds = [userId];
      }
      await notificationService.sendNotification(
        userIds: recipientIds,
        title: 'New Event Added',
        body: '"${eventData['title']}" was added to the calendar.',
        type: 'event',
        data: {
          'event_title': eventData['title'],
          'event_id': eventData['id'] ?? '',
        },
      );
      // --- End notification logic ---
    } finally {
      isSyncing.value = false;
    }
  }

  Future<void> deleteEvent(String eventId) async {
    events.removeWhere((e) => e.id == eventId);
    try {
      isSyncing.value = true;
      await CalendarService.deleteEvent(eventId);
      await fetchEvents();
    } finally {
      isSyncing.value = false;
    }
  }

  void markEventAsCompleted(String eventId) {
    final index = events.indexWhere((e) => e.id == eventId);
    if (index != -1) {
      final event = events[index];
      events[index] = event.copyWith(isCompleted: true);
    }
  }

  Future<void> editEvent(String eventId, Map<String, dynamic> eventData) async {
    try {
      isSyncing.value = true;
      await CalendarService.updateEvent(eventId, eventData);
      await fetchEvents();
    } finally {
      isSyncing.value = false;
    }
  }
}
