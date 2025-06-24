import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../controllers/calendar_controller.dart';
import '../../models/event.dart';
import '../widgets/event_dialog.dart';
import 'dart:ui';

class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    DateTime? initialDate;
    String? focusEventId;
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args != null) {
      if (args is DateTime) {
        initialDate = args;
      } else if (args is Map && args['event_id'] != null) {
        focusEventId = args['event_id'].toString();
      }
    }
    final controller = Get.put(CalendarController());
    if (initialDate != null && controller.selectedDate.value != initialDate) {
      controller.selectedDate.value = initialDate;
    }
    // Only open the dialog once per navigation (for event_id deep link)
    final openedDialog = ValueNotifier(false);
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [const Color(0xFF1F3354), const Color(0xFF3E5879)],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            children: [
              AppBar(
                surfaceTintColor: Colors.transparent,
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                title: const Text(
                  'Calendar',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                child: Obx(() {
                  if (controller.isSyncing.value && controller.events.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  // Open dialog after events are loaded
                  if (focusEventId != null &&
                      controller.events.isNotEmpty &&
                      !openedDialog.value) {
                    final event = controller.events.firstWhereOrNull(
                      (e) => e.id == focusEventId,
                    );
                    if (event != null) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        controller.selectedDate.value = event.startTime;
                        Get.dialog(
                          EventDialog(
                            event: event,
                            selectedDate: event.startTime,
                          ),
                        );
                        openedDialog.value = true;
                      });
                    } else {}
                  }
                  return SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 24),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.08),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: TableCalendar(
                              firstDay: DateTime.now().subtract(
                                const Duration(days: 365),
                              ),
                              lastDay: DateTime.now().add(
                                const Duration(days: 365),
                              ),
                              focusedDay: controller.selectedDate.value,
                              calendarFormat: CalendarFormat.month,
                              startingDayOfWeek: StartingDayOfWeek.monday,
                              headerStyle: HeaderStyle(
                                formatButtonVisible: false,
                                titleCentered: true,
                                titleTextStyle: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                                leftChevronIcon: const Icon(
                                  Icons.chevron_left,
                                  color: Colors.black,
                                ),
                                rightChevronIcon: const Icon(
                                  Icons.chevron_right,
                                  color: Colors.black,
                                ),
                              ),
                              calendarStyle: CalendarStyle(
                                todayDecoration: BoxDecoration(
                                  color: const Color(
                                    0xFF1F3354,
                                  ).withOpacity(0.7),
                                  shape: BoxShape.circle,
                                ),
                                selectedDecoration: const BoxDecoration(
                                  color: Color(0xFF1F3354),
                                  shape: BoxShape.circle,
                                ),
                                markerDecoration: const BoxDecoration(
                                  color: Color(0xFF1F3354),
                                  shape: BoxShape.circle,
                                ),
                                markerSize: 6,
                                markerMargin: const EdgeInsets.only(top: 2),
                              ),
                              eventLoader:
                                  (day) => controller.getEventsForDate(day),
                              selectedDayPredicate: (day) {
                                return isSameDay(
                                  controller.selectedDate.value,
                                  day,
                                );
                              },
                              onDaySelected: (selectedDay, focusedDay) {
                                controller.selectedDate.value = selectedDay;
                              },
                            ),
                          ),
                          const SizedBox(height: 24),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4.0,
                            ),
                            child: Text(
                              'Events',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Obx(() {
                            final dayEvents = controller.getEventsForDate(
                              controller.selectedDate.value,
                            );
                            if (dayEvents.isEmpty) {
                              return const Center(
                                child: Text(
                                  'No events for this day',
                                  style: TextStyle(color: Colors.white70),
                                ),
                              );
                            }
                            return ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: dayEvents.length,
                              itemBuilder: (_, index) {
                                final event = dayEvents[index];
                                return Dismissible(
                                  key: Key(event.id),
                                  direction: DismissDirection.endToStart,
                                  background: Container(
                                    margin: const EdgeInsets.symmetric(
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.red.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    alignment: Alignment.centerRight,
                                    padding: const EdgeInsets.only(right: 24),
                                    child: const Icon(
                                      Icons.delete_outline,
                                      color: Colors.white,
                                      size: 32,
                                    ),
                                  ),
                                  onDismissed: (direction) async {
                                    await controller.deleteEvent(event.id);
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      color: Colors.white.withOpacity(0.1),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.08),
                                          blurRadius: 12,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                      border: Border.all(
                                        color: Colors.white24,
                                        width: 1.2,
                                      ),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: BackdropFilter(
                                        filter: ImageFilter.blur(
                                          sigmaX: 12,
                                          sigmaY: 12,
                                        ),
                                        child: ListTile(
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                horizontal: 20,
                                                vertical: 12,
                                              ),
                                          title: Text(
                                            event.title,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18,
                                              color: Colors.white,
                                              shadows: [
                                                Shadow(
                                                  blurRadius: 2,
                                                  color: Colors.black26,
                                                ),
                                              ],
                                            ),
                                          ),
                                          subtitle: Text(
                                            event.description,
                                            style: const TextStyle(
                                              color: Colors.white70,
                                            ),
                                          ),
                                          onTap: () {
                                            showModalBottomSheet(
                                              context: context,
                                              backgroundColor:
                                                  Colors.transparent,
                                              isScrollControlled: true,
                                              builder: (context) {
                                                return Container(
                                                  decoration: const BoxDecoration(
                                                    color: Color(0xFF1F3354),
                                                    borderRadius:
                                                        BorderRadius.vertical(
                                                          top: Radius.circular(
                                                            20,
                                                          ),
                                                        ),
                                                  ),
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.fromLTRB(
                                                          20,
                                                          16,
                                                          20,
                                                          32,
                                                        ),
                                                    child: Column(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Center(
                                                          child: Container(
                                                            width: 40,
                                                            height: 4,
                                                            margin:
                                                                const EdgeInsets.only(
                                                                  bottom: 16,
                                                                ),
                                                            decoration: BoxDecoration(
                                                              color:
                                                                  Colors
                                                                      .white24,
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                    2,
                                                                  ),
                                                            ),
                                                          ),
                                                        ),
                                                        Text(
                                                          event.title,
                                                          style:
                                                              const TextStyle(
                                                                color:
                                                                    Colors
                                                                        .white,
                                                                fontSize: 24,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                        ),
                                                        const SizedBox(
                                                          height: 16,
                                                        ),
                                                        if (event
                                                            .description
                                                            .isNotEmpty)
                                                          _buildDetailRow(
                                                            Icons
                                                                .description_outlined,
                                                            event.description,
                                                          ),
                                                        if (event
                                                            .location
                                                            .isNotEmpty)
                                                          _buildDetailRow(
                                                            Icons.location_on,
                                                            event.location,
                                                          ),
                                                        _buildDetailRow(
                                                          Icons
                                                              .calendar_today_outlined,
                                                          '${event.startTime.toLocal()} - ${event.endTime.toLocal()}',
                                                        ),
                                                        _buildDetailRow(
                                                          Icons.category,
                                                          event.type
                                                              .toString()
                                                              .split('.')
                                                              .last,
                                                        ),
                                                        _buildDetailRow(
                                                          event.additionalDetails['privacy'] ==
                                                                  'public'
                                                              ? Icons.public
                                                              : Icons.lock,
                                                          event.additionalDetails['privacy'] ==
                                                                  'public'
                                                              ? 'Public'
                                                              : 'Private',
                                                        ),
                                                        if (event
                                                            .participants
                                                            .isNotEmpty)
                                                          _buildDetailRow(
                                                            Icons.people,
                                                            event.participants
                                                                .map(
                                                                  (p) =>
                                                                      p.userName ??
                                                                      p.userId,
                                                                )
                                                                .join(', '),
                                                          ),
                                                        const SizedBox(
                                                          height: 24,
                                                        ),
                                                        Row(
                                                          children: [
                                                            Expanded(
                                                              child: ElevatedButton(
                                                                key: const Key('add_event_button'),
                                                                onPressed: () {
                                                                  Navigator.pop(
                                                                    context,
                                                                  ); // Close bottom sheet
                                                                  Get.dialog(
                                                                    EventDialog(
                                                                      event:
                                                                          event,
                                                                      selectedDate:
                                                                          controller
                                                                              .selectedDate
                                                                              .value,
                                                                    ),
                                                                  );
                                                                },
                                                                style: ElevatedButton.styleFrom(
                                                                  backgroundColor:
                                                                      Colors
                                                                          .white24,
                                                                  padding:
                                                                      const EdgeInsets.symmetric(
                                                                        vertical:
                                                                            16,
                                                                      ),
                                                                  shape: RoundedRectangleBorder(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                          12,
                                                                        ),
                                                                  ),
                                                                ),
                                                                child: const Text(
                                                                  'Edit Event',
                                                                  style: TextStyle(
                                                                    color:
                                                                        Colors
                                                                            .white,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                );
                                              },
                                            );
                                          },
                                          trailing: IconButton(
                                            icon: const Icon(
                                              Icons.edit,
                                              color: Color(0xfff2f2f2),
                                            ),
                                            onPressed: () {
                                              Get.dialog(
                                                EventDialog(
                                                  event: event,
                                                  selectedDate:
                                                      controller
                                                          .selectedDate
                                                          .value,
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            );
                          }),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: const Color(0xFF1F3354),
          onPressed: () {
            Get.dialog(
              EventDialog(selectedDate: controller.selectedDate.value),
            );
          },
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, color: Colors.white60, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text, style: const TextStyle(color: Colors.white70)),
          ),
        ],
      ),
    );
  }
}
