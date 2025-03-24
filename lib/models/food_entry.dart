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

  //create from json from database
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

  //convert to json to save into database
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'foodName': foodName,
      'sugarAmount': sugarAmount,
      'timestamp': timestamp.millisecondsSinceEpoch,
    };
  }
}