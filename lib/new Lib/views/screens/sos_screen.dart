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
  late EmergencyController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(EmergencyController());
    controller.updateCurrentLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.red.shade900, Colors.red.shade700],
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
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
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
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: const Text(
                  'Send SOS',
                  style: TextStyle(color: Colors.white70),
                ),
                trailing: Obx(() => controller.isSendingSos.value
                    ? const CircularProgressIndicator(strokeWidth: 2)
                    : IconButton(
                        icon: const Icon(
                          Icons.notifications_active,
                          color: Colors.white,
                        ),
                        onPressed: _sendSosNotification,
                      )),
              ),
              const Divider(color: Colors.white24),
              _buildContactItem(
                'Police',
                '122',
                Icons.local_police,
                Colors.blue,
                type: EmergencyType.security,
              ),
              const Divider(color: Colors.white24),
              _buildContactItem(
                'Ambulance',
                '123',
                Icons.medical_services,
                Colors.red,
                type: EmergencyType.medical,
              ),
              const Divider(color: Colors.white24),
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
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Text(number, style: const TextStyle(color: Colors.white70)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.phone, color: Colors.white),
            onPressed: () => _launchEmergencyCall(number),
          ),
          IconButton(
            icon: const Icon(Icons.notification_important, color: Colors.white),
            onPressed: () => _sendEmergencyContactAlert(type, name),
          ),
        ],
      ),
    );
  }

  void _sendEmergencyContactAlert(EmergencyType type, String name) async {
    await controller.updateCurrentLocation();
    await controller.sendEmergencyAlert(
      type: type,
      message: "Urgent: Contacted $name (${type.name})",
    );
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
                    center: controller.selectedAlertLocation.value ??
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
              onPressed: () {
                setState(() {});
              },
              tooltip: 'Refresh Alerts',
            ),
          ],
        ),
        const SizedBox(height: 16),
        Obx(() {
          final alerts =
              controller.familyAlerts.toList()
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
            itemBuilder: (_, index) => _buildAlertItem(alerts[index]),
          );
        }),
      ],
    );
  }

  Widget _buildAlertItem(EmergencyAlert alert) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
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
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          'Lat: ${alert.latitude}, Lng: ${alert.longitude}\n${_formatDateTime(alert.timestamp)}',
          style: const TextStyle(color: Colors.white70),
        ),
        onTap: () {
          controller.centerMapOnAlert(alert.latitude, alert.longitude);
        },
        trailing: IconButton(
          icon: const Icon(Icons.check_circle, color: Colors.green),
          tooltip: 'Resolve Alert',
          onPressed: () async {
            controller.resolveAlert(alert.id);
            setState(() {});
          },
        ),
      ),
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
    await controller.updateCurrentLocation();
    await controller.sendEmergencyAlert(
      type: EmergencyType.other,
      message: "SOS Emergency!",
    );
    controller.isSendingSos.value = false;
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
        return Colors.blue;
      case EmergencyType.fire:
        return Colors.orange;
      case EmergencyType.security:
        return Colors.purple;
      case EmergencyType.other:
        return Colors.red;
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
