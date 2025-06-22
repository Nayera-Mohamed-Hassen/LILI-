import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/event.dart' as myevent;
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/calendar_service.dart';
import '../../user_session.dart';

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
      print('[DEBUG] Fetching events for userId=$userId, houseId=$houseId');
      if (userId == null || userId.isEmpty) {
        print('[DEBUG] No userId found, aborting fetchEvents');
        return;
      }
      final fetchedEvents = await CalendarService.fetchEvents(userId: userId, houseId: houseId);
      print('[DEBUG] Fetched events: $fetchedEvents');
      events.assignAll(fetchedEvents);
    } catch (e, st) {
      print('[DEBUG] Failed to fetch events: $e');
      print(st);
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
      final houseId = UserSession().getHouseId != null ? UserSession().getHouseId() : null;
      if (userId == null || userId.isEmpty) return;
      eventData['creator_id'] = userId;
      eventData['house_id'] = houseId;
      await CalendarService.addEvent(eventData);
      await fetchEvents();
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
