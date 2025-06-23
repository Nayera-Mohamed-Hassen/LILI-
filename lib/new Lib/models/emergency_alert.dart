import 'package:flutter/material.dart';

enum EmergencyType { medical, fire, security, other }

enum AlertStatus { active, acknowledged, resolved }

class EmergencyAlert {
  final String id;
  final String senderId;
  final String senderName;
  final String houseId;
  final EmergencyType type;
  final String message;
  final DateTime timestamp;
  final AlertStatus status;
  final List<String> acknowledgedBy;
  final Map<String, dynamic> additionalInfo;

  EmergencyAlert({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.houseId,
    required this.type,
    required this.message,
    required this.timestamp,
    this.status = AlertStatus.active,
    this.acknowledgedBy = const [],
    this.additionalInfo = const {},
  });

  EmergencyAlert copyWith({
    String? id,
    String? senderId,
    String? senderName,
    String? houseId,
    EmergencyType? type,
    String? message,
    DateTime? timestamp,
    AlertStatus? status,
    List<String>? acknowledgedBy,
    Map<String, dynamic>? additionalInfo,
  }) {
    return EmergencyAlert(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      houseId: houseId ?? this.houseId,
      type: type ?? this.type,
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
      status: status ?? this.status,
      acknowledgedBy: acknowledgedBy ?? this.acknowledgedBy,
      additionalInfo: additionalInfo ?? this.additionalInfo,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'senderId': senderId,
      'senderName': senderName,
      'houseId': houseId,
      'type': type.toString(),
      'message': message,
      'timestamp': timestamp.toIso8601String(),
      'status': status.toString(),
      'acknowledgedBy': acknowledgedBy,
      'additionalInfo': additionalInfo,
    };
  }

  static AlertStatus _parseStatus(dynamic status) {
    if (status is AlertStatus) return status;
    if (status is String) {
      final normalized = status.contains('.') ? status.split('.').last : status;
      return AlertStatus.values.firstWhere(
        (e) => e.name.toLowerCase() == normalized.toLowerCase(),
        orElse: () => AlertStatus.active,
      );
    }
    return AlertStatus.active;
  }

  factory EmergencyAlert.fromJson(Map<String, dynamic> json) {
    return EmergencyAlert(
      id: json['id'] ?? json['_id'] ?? '',
      senderId: json['senderId'] ?? '',
      senderName: json['senderName'] ?? '',
      houseId: json['houseId'] ?? '',
      type: EmergencyType.values.firstWhere(
        (e) => e.toString() == json['type'] || e.name == json['type'],
        orElse: () => EmergencyType.other,
      ),
      message: json['message'] ?? '',
      timestamp: DateTime.parse(json['timestamp']),
      status: _parseStatus(json['status']),
      acknowledgedBy: List<String>.from(json['acknowledgedBy'] ?? []),
      additionalInfo: json['additionalInfo'] ?? {},
    );
  }
}
