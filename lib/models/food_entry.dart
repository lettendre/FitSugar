class FoodEntry {
  final String id;
  final String foodName;
  final double sugarAmount;
  final DateTime timestamp;

  FoodEntry({
    required this.id,
    required this.foodName,
    required this.sugarAmount,
    required this.timestamp,
  });

  // Create from JSON (from Firestore)
  factory FoodEntry.fromJson(Map<String, dynamic> json) {
    return FoodEntry(
      id: json['id'],
      foodName: json['foodName'],
      sugarAmount: json['sugarAmount']?.toDouble() ?? 0.0,
      timestamp: json['timestamp'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['timestamp'])
          : DateTime.now(),
    );
  }

  // Convert to JSON (for Firestore)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'foodName': foodName,
      'sugarAmount': sugarAmount,
      'timestamp': timestamp.millisecondsSinceEpoch,
    };
  }
}