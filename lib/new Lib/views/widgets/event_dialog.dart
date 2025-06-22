import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:LILI/new Lib/models/event.dart';
import '../../controllers/calendar_controller.dart';
import 'dart:ui';

class EventDialog extends StatefulWidget {
  final Event? event;
  final DateTime selectedDate;

  const EventDialog({super.key, this.event, required this.selectedDate});

  @override
  State<EventDialog> createState() => _EventDialogState();
}

class _EventDialogState extends State<EventDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _locationController;
  late DateTime _startDate;
  late TimeOfDay _startTime;
  late DateTime _endDate;
  late TimeOfDay _endTime;
  late String _eventType;
  late bool _isPublic;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.event?.title ?? '');
    _descriptionController = TextEditingController(
      text: widget.event?.description ?? '',
    );
    _locationController = TextEditingController(
      text: widget.event?.location ?? '',
    );

    _startDate = widget.event?.startTime ?? widget.selectedDate;
    _startTime = TimeOfDay.fromDateTime(
      widget.event?.startTime ??
          widget.selectedDate.add(const Duration(hours: 1)),
    );

    _endDate = widget.event?.endTime ?? widget.selectedDate;
    _endTime = TimeOfDay.fromDateTime(
      widget.event?.endTime ??
          widget.selectedDate.add(const Duration(hours: 2)),
    );

    _eventType = widget.event?.type
        .toString()
        .split('.')
        .last ?? 'general';
    _isPublic = (widget.event != null &&
        widget.event!.additionalDetails['privacy'] == 'public');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 8,
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
          border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.2),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              decoration: const BoxDecoration(
                color: Color(0xFF1F3354),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.event == null ? 'Add Event' : 'Edit Event',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.1,
                    ),
                  ),
                  InkWell(
                    onTap: () =>
                        Navigator.of(context, rootNavigator: true).pop(),
                    child: const Icon(
                        Icons.close, color: Colors.white, size: 24),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: _titleController,
                        decoration: InputDecoration(
                          labelText: 'Title',
                          prefixIcon: const Icon(Icons.title,
                              color: Color(0xFF1F3354)),
                          filled: true,
                          fillColor: Colors.grey[100],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        validator: (value) =>
                        value == null || value.isEmpty ? 'Enter a title' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _descriptionController,
                        decoration: InputDecoration(
                          labelText: 'Description',
                          prefixIcon: const Icon(Icons.description,
                              color: Color(0xFF1F3354)),
                          filled: true,
                          fillColor: Colors.grey[100],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        maxLines: 2,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _locationController,
                        decoration: InputDecoration(
                          labelText: 'Location',
                          prefixIcon: const Icon(Icons.location_on,
                              color: Color(0xFF1F3354)),
                          filled: true,
                          fillColor: Colors.grey[100],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () =>
                                  _selectDate(context, isStartDate: true),
                              child: InputDecorator(
                                decoration: InputDecoration(
                                  labelText: 'Start Date',
                                  prefixIcon: const Icon(Icons.calendar_today,
                                      color: Color(0xFF1F3354)),
                                  filled: true,
                                  fillColor: Colors.grey[100],
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                                child: Text(_formatDate(_startDate)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: InkWell(
                              onTap: () =>
                                  _selectTime(context, isStartTime: true),
                              child: InputDecorator(
                                decoration: InputDecoration(
                                  labelText: 'Start Time',
                                  prefixIcon: const Icon(Icons.access_time,
                                      color: Color(0xFF1F3354)),
                                  filled: true,
                                  fillColor: Colors.grey[100],
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                                child: Text(_formatTime(_startTime)),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () =>
                                  _selectDate(context, isStartDate: false),
                              child: InputDecorator(
                                decoration: InputDecoration(
                                  labelText: 'End Date',
                                  prefixIcon: const Icon(Icons.calendar_today,
                                      color: Color(0xFF1F3354)),
                                  filled: true,
                                  fillColor: Colors.grey[100],
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                                child: Text(_formatDate(_endDate)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: InkWell(
                              onTap: () =>
                                  _selectTime(context, isStartTime: false),
                              child: InputDecorator(
                                decoration: InputDecoration(
                                  labelText: 'End Time',
                                  prefixIcon: const Icon(Icons.access_time,
                                      color: Color(0xFF1F3354)),
                                  filled: true,
                                  fillColor: Colors.grey[100],
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                                child: Text(_formatTime(_endTime)),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(_isPublic ? Icons.public : Icons.lock,
                              color: _isPublic ? Colors.green : Colors.grey),
                          const SizedBox(width: 8),
                          const Text('Visibility:'),
                          Switch(
                            value: _isPublic,
                            onChanged: (val) {
                              setState(() {
                                _isPublic = val;
                              });
                            },
                          ),
                          const SizedBox(width: 8),
                          Text(_isPublic ? 'Public' : 'Private',
                              style: TextStyle(
                                  color: _isPublic ? Colors.green : Colors
                                      .grey)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: _eventType,
                        decoration: InputDecoration(
                          labelText: 'Event Type',
                          prefixIcon: const Icon(Icons.category,
                              color: Color(0xFF1F3354)),
                          filled: true,
                          fillColor: Colors.grey[100],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        items: [
                          'general',
                          'birthday',
                          'appointment',
                          'meeting',
                          'reminder',
                          'other',
                        ].map((type) {
                          return DropdownMenuItem(
                            value: type,
                            child: Text(
                                type[0].toUpperCase() + type.substring(1)),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _eventType = value;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () =>
                                Navigator
                                    .of(context, rootNavigator: true)
                                    .pop(),
                            style: TextButton.styleFrom(
                              foregroundColor: const Color(0xFFC30606),
                              textStyle: const TextStyle(
                                  fontWeight: FontWeight.bold),
                            ),
                            child: const Text('Cancel'),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                final eventData = {
                                  'title': _titleController.text,
                                  'description': _descriptionController.text,
                                  'location': _locationController.text,
                                  'start_time': DateTime(
                                    _startDate.year,
                                    _startDate.month,
                                    _startDate.day,
                                    _startTime.hour,
                                    _startTime.minute,
                                  ).toIso8601String(),
                                  'end_time': DateTime(
                                    _endDate.year,
                                    _endDate.month,
                                    _endDate.day,
                                    _endTime.hour,
                                    _endTime.minute,
                                  ).toIso8601String(),
                                  'type': _eventType,
                                  'privacy': _isPublic ? 'public' : 'private',
                                  'participants': widget.event?.participants
                                      .map((p) => p.userId).toList() ?? [],
                                };
                                print('[DEBUG] eventData to send: $eventData');
                                final controller = Get.find<
                                    CalendarController>();
                                if (widget.event == null) {
                                  await controller.addEventFromForm(eventData);
                                } else {
                                  await controller.editEvent(
                                      widget.event!.id, eventData);
                                }
                                Navigator
                                    .of(context, rootNavigator: true)
                                    .pop();
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1F3354),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 32, vertical: 14),
                              textStyle: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            child: Text(widget.event == null ? 'Add' : 'Save'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context,
      {required bool isStartDate}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStartDate ? _startDate : _endDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _selectTime(BuildContext context,
      {required bool isStartTime}) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isStartTime ? _startTime : _endTime,
    );
    if (picked != null) {
      setState(() {
        if (isStartTime) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatTime(TimeOfDay time) {
    return '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
  }
}
