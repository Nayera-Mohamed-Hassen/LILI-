class ExpenseGoal {
  final String id;
  final String userId;
  final String category;
  final double targetAmount;
  final double currentAmount;
  final String period; // monthly, weekly, yearly
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;

  ExpenseGoal({
    required this.id,
    required this.userId,
    required this.category,
    required this.targetAmount,
    this.currentAmount = 0.0,
    required this.period,
    required this.startDate,
    required this.endDate,
    this.isActive = true,
  });

  factory ExpenseGoal.fromJson(Map<String, dynamic> json) {
    return ExpenseGoal(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      category: json['category'] ?? '',
      targetAmount: (json['target_amount'] ?? 0.0).toDouble(),
      currentAmount: (json['current_amount'] ?? 0.0).toDouble(),
      period: json['period'] ?? 'monthly',
      startDate: DateTime.parse(json['start_date'] ?? DateTime.now().toIso8601String()),
      endDate: DateTime.parse(json['end_date'] ?? DateTime.now().toIso8601String()),
      isActive: json['is_active'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'category': category,
      'target_amount': targetAmount,
      'current_amount': currentAmount,
      'period': period,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'is_active': isActive,
    };
  }

  double get progressPercentage {
    if (targetAmount == 0) return 0.0;
    return (currentAmount / targetAmount * 100).clamp(0.0, 100.0);
  }

  bool get isOverBudget => currentAmount > targetAmount;

  String get remainingAmount {
    final remaining = targetAmount - currentAmount;
    return remaining >= 0 ? remaining.toStringAsFixed(2) : '0.00';
  }

  String get overBudgetAmount {
    final over = currentAmount - targetAmount;
    return over > 0 ? over.toStringAsFixed(2) : '0.00';
  }

  ExpenseGoal copyWith({
    String? id,
    String? userId,
    String? category,
    double? targetAmount,
    double? currentAmount,
    String? period,
    DateTime? startDate,
    DateTime? endDate,
    bool? isActive,
  }) {
    return ExpenseGoal(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      category: category ?? this.category,
      targetAmount: targetAmount ?? this.targetAmount,
      currentAmount: currentAmount ?? this.currentAmount,
      period: period ?? this.period,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isActive: isActive ?? this.isActive,
    );
  }
} 