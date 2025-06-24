import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../controllers/emergency_controller.dart';
import '../../models/emergency_alert.dart';

class SosScreen extends StatefulWidget {
  const SosScreen({super.key});

  @override
  State<SosScreen> createState() => _SosScreenState();
}

class _SosScreenState extends State<SosScreen> {
  final EmergencyController controller = Get.put(
    EmergencyController(),
    permanent: true,
  );

  @override
  void initState() {
    super.initState();
    controller.updateCurrentLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1F3354), Color(0xFF3E5879)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildEmergencyContacts(),
                        const SizedBox(height: 24),
                        _buildLocationMap(),
                        const SizedBox(height: 24),
                        _buildRecentAlerts(),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() => Container(
    padding: const EdgeInsets.all(16),
    child: Column(
      children: const [
        Text(
          'SOS Emergency',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Quick access to emergency services',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white70, fontSize: 16),
        ),
      ],
    ),
  );

  Widget _buildEmergencyContacts() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Emergency Contacts',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        Card(
          elevation: 8,
          shadowColor: Colors.black26,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.purple.withOpacity(0.2),
                    child: const Icon(Icons.sos, color: Colors.purple),
                  ),
                  title: const Text(
                    'Family',
                    style: TextStyle(
                      color: Color(0xFF1F3354),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: const Text(
                    'Send SOS',
                    style: TextStyle(color: Colors.black54),
                  ),
                  trailing: Obx(
                    () =>
                        controller.isSendingSos.value
                            ? const CircularProgressIndicator(strokeWidth: 2)
                            : IconButton(
                              icon: const Icon(
                                Icons.notifications_active,
                                color: Color(0xFF1F3354),
                              ),
                              onPressed: _sendSosNotification,
                            ),
                  ),
                ),
                const Divider(color: Colors.black12),
                _buildContactItem(
                  'Police',
                  '122',
                  Icons.local_police,
                  Colors.blue,
                  type: EmergencyType.security,
                ),
                const Divider(color: Colors.black12),
                _buildContactItem(
                  'Ambulance',
                  '123',
                  Icons.medical_services,
                  Colors.red,
                  type: EmergencyType.medical,
                ),
                const Divider(color: Colors.black12),
                _buildContactItem(
                  'Fire Department',
                  '180',
                  Icons.local_fire_department,
                  Colors.orange,
                  type: EmergencyType.fire,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContactItem(
    String name,
    String number,
    IconData icon,
    Color color, {
    required EmergencyType type,
  }) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: color.withOpacity(0.2),
        child: Icon(icon, color: color),
      ),
      title: Text(
        name,
        style: const TextStyle(
          color: Color(0xFF1F3354),
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Text(number, style: const TextStyle(color: Colors.black54)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.phone, color: Color(0xFF1F3354)),
            onPressed: () => _launchEmergencyCall(number),
          ),
          IconButton(
            icon: const Icon(
              Icons.notification_important,
              color: Color(0xFF1F3354),
            ),
            onPressed: () => _sendEmergencyContactAlert(type, name),
          ),
        ],
      ),
    );
  }

  void _sendEmergencyContactAlert(EmergencyType type, String name) async {
    final locationString =
        controller.currentLocation.value.isNotEmpty
            ? controller.currentLocation.value
            : 'Lat: ${controller.currentLatitude.value}, Lng: ${controller.currentLongitude.value}';
    await controller.sendEmergencyAlert(
      type: type,
      message:
          "Urgent: Contacted $name (${type.name}) Location: $locationString",
      additionalInfo: {'location': locationString},
    );
    await controller.fetchAllAlerts();
    setState(() {});
  }

  Widget _buildLocationMap() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Current Location',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        Obx(() {
          if (!controller.isLocationEnabled.value) {
            return const Text(
              'Location services are disabled',
              style: TextStyle(color: Colors.white70),
            );
          }
          return Stack(
            children: [
              SizedBox(
                height: 200,
                child: FlutterMap(
                  mapController: controller.mapController,
                  options: MapOptions(
                    center:
                        controller.selectedAlertLocation.value ??
                        LatLng(
                          controller.currentLatitude.value,
                          controller.currentLongitude.value,
                        ),
                    zoom: 13.0,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.hci_flutter',
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: LatLng(
                            controller.currentLatitude.value,
                            controller.currentLongitude.value,
                          ),
                          width: 40,
                          height: 40,
                          child: const Icon(
                            Icons.location_on,
                            color: Colors.red,
                            size: 40,
                          ),
                        ),
                        if (controller.selectedAlertLocation.value != null)
                          Marker(
                            point: controller.selectedAlertLocation.value!,
                            width: 40,
                            height: 40,
                            child: const Icon(
                              Icons.warning,
                              color: Colors.orange,
                              size: 40,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: FloatingActionButton(
                  mini: true,
                  backgroundColor: Colors.white,
                  child: const Icon(Icons.my_location, color: Colors.red),
                  onPressed: () {
                    controller.centerMapOnUser();
                  },
                  tooltip: 'Current Location',
                ),
              ),
            ],
          );
        }),
      ],
    );
  }

  Widget _buildRecentAlerts() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Recent Alerts',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white),
              onPressed: () async {
                await controller.fetchAllAlerts();
              },
              tooltip: 'Refresh Alerts',
            ),
          ],
        ),
        const SizedBox(height: 16),
        Obx(() {
          if (controller.isLoadingAlerts.value) {
            return const Center(child: CircularProgressIndicator());
          }
          if (controller.error.value.isNotEmpty) {
            return Text(
              controller.error.value,
              style: const TextStyle(color: Colors.white70),
            );
          }
          final alerts =
              controller.getActiveAlerts()
                ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
          if (alerts.isEmpty) {
            return const Text(
              'No active alerts',
              style: TextStyle(color: Colors.white70),
            );
          }
          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: alerts.length,
            itemBuilder:
                (_, index) => GestureDetector(
                  onTap: () => _showAlertDetails(alerts[index]),
                  child: _buildAlertItem(alerts[index]),
                ),
          );
        }),
      ],
    );
  }

  Widget _buildAlertItem(EmergencyAlert alert) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Card(
        elevation: 4,
        shadowColor: Colors.black12,
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: _getColorForEmergencyType(
              alert.type,
            ).withOpacity(0.2),
            child: Icon(
              _getIconForEmergencyType(alert.type),
              color: _getColorForEmergencyType(alert.type),
            ),
          ),
          title: Text(
            alert.message,
            style: const TextStyle(
              color: Color(0xFF1F3354),
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Text(
            _formatDateTime(alert.timestamp),
            style: const TextStyle(color: Colors.black54),
          ),
          trailing: IconButton(
            icon: const Icon(Icons.check_circle, color: Colors.green),
            tooltip: 'Resolve Alert',
            onPressed: () async {
              await controller.resolveAlert(alert.id);
              await controller.fetchAllAlerts();
            },
          ),
        ),
      ),
    );
  }

  void _showAlertDetails(EmergencyAlert alert) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: _getColorForEmergencyType(alert.type),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: 20,
                    horizontal: 24,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _getIconForEmergencyType(alert.type),
                        color: Colors.white,
                        size: 32,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          _getEmergencyTypeName(alert.type),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Message:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        alert.message,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Color(0xFF1F3354),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Time:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _formatDateTime(alert.timestamp),
                        style: const TextStyle(
                          fontSize: 15,
                          color: Colors.black87,
                        ),
                      ),
                      if (alert.additionalInfo['location'] != null) ...[
                        const SizedBox(height: 16),
                        Text(
                          'Location:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          alert.additionalInfo['location'],
                          style: const TextStyle(
                            fontSize: 15,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _getColorForEmergencyType(alert.type),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text(
                      'Close',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showEmergencyDialog(EmergencyType type) {
    final messageController = TextEditingController();
    Get.dialog(
      AlertDialog(
        title: Text(_getEmergencyTypeName(type)),
        content: TextField(
          controller: messageController,
          decoration: const InputDecoration(
            labelText: 'Emergency Message',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            key: const Key('emergency_button'),
            onPressed: () {
              if (messageController.text.isNotEmpty) {
                controller.sendEmergencyAlert(
                  type: type,
                  message: messageController.text,
                );
                Get.back();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _getColorForEmergencyType(type),
            ),
            child: const Text('Send Alert'),
          ),
        ],
      ),
    );
  }

  void _sendSosNotification() async {
    if (controller.isSendingSos.value) return;
    controller.isSendingSos.value = true;
    try {
      final locationString =
          controller.currentLocation.value.isNotEmpty
              ? controller.currentLocation.value
              : 'Lat: ${controller.currentLatitude.value}, Lng: ${controller.currentLongitude.value}';
      await controller.sendEmergencyAlert(
        type: EmergencyType.other,
        message: "SOS Emergency! Location: $locationString",
        additionalInfo: {'location': locationString},
      );
      await controller.fetchAllAlerts();
    } catch (e) {
      // Optionally show error
    } finally {
      controller.isSendingSos.value = false;
      setState(() {});
    }
  }

  Future<void> _launchEmergencyCall(String number) async {
    // This is a placeholder for launching a call
  }

  IconData _getIconForEmergencyType(EmergencyType type) {
    switch (type) {
      case EmergencyType.medical:
        return Icons.medical_services;
      case EmergencyType.fire:
        return Icons.local_fire_department;
      case EmergencyType.security:
        return Icons.security;
      case EmergencyType.other:
        return Icons.warning;
    }
  }

  Color _getColorForEmergencyType(EmergencyType type) {
    switch (type) {
      case EmergencyType.medical:
        return Colors.red;
      case EmergencyType.fire:
        return Colors.orange;
      case EmergencyType.security:
        return Colors.blue;
      case EmergencyType.other:
        return Colors.purple;
    }
  }

  String _getEmergencyTypeName(EmergencyType type) {
    switch (type) {
      case EmergencyType.medical:
        return 'Medical Emergency';
      case EmergencyType.fire:
        return 'Fire Emergency';
      case EmergencyType.security:
        return 'Security Alert';
      case EmergencyType.other:
        return 'Other Emergency';
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')} ${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }
}
