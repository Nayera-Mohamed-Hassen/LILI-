import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import '../models/emergency_alert.dart';
import 'package:latlong2/latlong.dart';
import '../../services/emergency_service.dart';
import '../../user_session.dart';

class EmergencyController extends GetxController {
  static EmergencyController get to => Get.find<EmergencyController>();

  final EmergencyService _emergencyService = EmergencyService();
  final RxList<EmergencyAlert> activeAlerts = <EmergencyAlert>[].obs;
  final RxBool isSendingAlert = false.obs;
  final RxBool isLoadingAlerts = false.obs;
  final RxString error = ''.obs;
  final RxBool isLocationEnabled = false.obs;
  final RxString currentLocation = ''.obs;
  final RxDouble currentLatitude = 0.0.obs;
  final RxDouble currentLongitude = 0.0.obs;
  var isSendingSos = false.obs;
  final mapController = MapController();
  final Rx<LatLng?> selectedAlertLocation = Rx<LatLng?>(null);

  @override
  void onInit() {
    super.onInit();
    _initializeLocation();
    fetchAllAlerts();
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

  Future<void> fetchAllAlerts() async {
    isLoadingAlerts.value = true;
    error.value = '';
    try {
      final houseId = UserSession().getHouseId() ?? '';
      final alerts = await _emergencyService.getHouseAlerts(houseId);
      final parsed = alerts.map((a) => EmergencyAlert.fromJson(a)).toList();
      activeAlerts.assignAll(parsed);
    } catch (e) {
      error.value = 'Failed to load alerts';
    } finally {
      isLoadingAlerts.value = false;
    }
  }

  Future<void> sendEmergencyAlert({
    required EmergencyType type,
    required String message,
    Map<String, dynamic>? additionalInfo,
  }) async {
    isSendingAlert.value = true;
    error.value = '';
    try {
      final senderId = UserSession().getUserId() ?? '';
      final senderName = UserSession().getName() ?? '';
      final houseId = UserSession().getHouseId() ?? '';
      final alert = EmergencyAlert(
        id: '',
        senderId: senderId,
        senderName: senderName,
        houseId: houseId,
        type: type,
        message: message,
        timestamp: DateTime.now(),
        additionalInfo: additionalInfo ?? {},
      );
      final alertMap = alert.toJson();
      alertMap.remove('id');
      await _emergencyService.sendEmergencyAlert(alertMap);
      await fetchAllAlerts();
    } catch (e) {
      error.value = 'Failed to send alert';
    } finally {
      isSendingAlert.value = false;
    }
  }

  Future<void> acknowledgeAlert(String alertId, String userId) async {
    await _emergencyService.acknowledgeAlert(alertId, userId);
    fetchAllAlerts();
  }

  Future<void> resolveAlert(String alertId) async {
    try {
    await _emergencyService.resolveAlert(alertId);
      await fetchAllAlerts();
    } catch (e) {
      error.value = 'Failed to resolve alert';
    }
  }

  List<EmergencyAlert> getActiveAlerts() {
    return activeAlerts.where((alert) => alert.status == AlertStatus.active).toList();
  }

  List<EmergencyAlert> getAcknowledgedAlerts() {
    return activeAlerts
        .where((alert) => alert.status == AlertStatus.acknowledged)
        .toList();
  }

  List<EmergencyAlert> getResolvedAlerts() {
    return activeAlerts
        .where((alert) => alert.status == AlertStatus.resolved)
        .toList();
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

  void _sendSosNotification() async {
    if (isSendingSos.value) return;
    isSendingSos.value = true;
    try {
      await sendEmergencyAlert(
        type: EmergencyType.other,
        message: "SOS Emergency!",
      );
      await fetchAllAlerts();
    } catch (e) {
      // Optionally show error
    } finally {
      isSendingSos.value = false;
    }
  }
}
