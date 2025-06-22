import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import '../models/emergency_alert.dart';
import 'package:latlong2/latlong.dart';

class EmergencyController extends GetxController {
  final RxList<EmergencyAlert> activeAlerts = <EmergencyAlert>[].obs;
  final RxBool isSendingAlert = false.obs;
  final RxBool isLocationEnabled = false.obs;
  final RxString currentLocation = ''.obs;
  final RxDouble currentLatitude = 0.0.obs;
  final RxDouble currentLongitude = 0.0.obs;
  var isSendingSos = false.obs;
  final mapController = MapController();
  final RxList<EmergencyAlert> familyAlerts = <EmergencyAlert>[].obs;
  final Rx<LatLng?> selectedAlertLocation = Rx<LatLng?>(null);

  @override
  void onInit() {
    super.onInit();
    _initializeLocation();
  }

  Future<void> _initializeLocation() async {
    // Simulate location permission granted and set a default location
    isLocationEnabled.value = true;
    currentLatitude.value = 37.7749;
    currentLongitude.value = -122.4194;
    currentLocation.value = 'San Francisco, CA, USA';
  }

  Future<void> updateCurrentLocation() async {
    // Simulate location update for demo
    currentLatitude.value = 37.7749;
    currentLongitude.value = -122.4194;
    currentLocation.value = 'San Francisco, CA, USA';
    isLocationEnabled.value = true;
  }

  Future<void> sendEmergencyAlert({
    required EmergencyType type,
    required String message,
    Map<String, dynamic>? additionalInfo,
  }) async {
    if (!isLocationEnabled.value) return;
    isSendingAlert.value = true;
    try {
      await updateCurrentLocation();
      final alert = EmergencyAlert(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        senderId: 'current_user_id',
        senderName: 'Current User',
        type: type,
        message: message,
        timestamp: DateTime.now(),
        latitude: currentLatitude.value,
        longitude: currentLongitude.value,
        location: currentLocation.value,
        additionalInfo: additionalInfo ?? {},
      );
      activeAlerts.add(alert);
      familyAlerts.add(alert);
    } finally {
      isSendingAlert.value = false;
    }
  }

  void acknowledgeAlert(String alertId, String userId) {
    final index = activeAlerts.indexWhere((alert) => alert.id == alertId);
    if (index != -1) {
      final alert = activeAlerts[index];
      final updatedAcknowledgedBy = List<String>.from(alert.acknowledgedBy)..add(userId);
      activeAlerts[index] = alert.copyWith(
        acknowledgedBy: updatedAcknowledgedBy,
        status: AlertStatus.acknowledged,
      );
    }
  }

  void resolveAlert(String alertId) {
    final index = activeAlerts.indexWhere((alert) => alert.id == alertId);
    if (index != -1) {
      final alert = activeAlerts[index];
      activeAlerts[index] = alert.copyWith(status: AlertStatus.resolved);
    }
  }

  List<EmergencyAlert> getActiveAlerts() {
    return activeAlerts.where((alert) => alert.status == AlertStatus.active).toList();
  }

  List<EmergencyAlert> getAcknowledgedAlerts() {
    return activeAlerts.where((alert) => alert.status == AlertStatus.acknowledged).toList();
  }

  List<EmergencyAlert> getResolvedAlerts() {
    return activeAlerts.where((alert) => alert.status == AlertStatus.resolved).toList();
  }

  void centerMapOnAlert(double lat, double lng) {
    mapController.move(LatLng(lat, lng), 15.0);
    selectedAlertLocation.value = LatLng(lat, lng);
  }

  void centerMapOnUser() {
    mapController.move(
      LatLng(currentLatitude.value, currentLongitude.value),
      13.0,
    );
    selectedAlertLocation.value = null;
  }
}
