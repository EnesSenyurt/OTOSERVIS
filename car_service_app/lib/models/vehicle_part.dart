class VehiclePart {
  final int id;
  final String name;
  final String code;
  final double cost;
  final int stock;

  VehiclePart({
    required this.id,
    required this.name,
    required this.code,
    required this.cost,
    required this.stock,
  });

  factory VehiclePart.fromJson(Map<String, dynamic> json) {
    final costValue = json['cost'];
    final double cost = costValue is num
        ? costValue.toDouble()
        : double.tryParse(costValue.toString()) ?? 0.0;

    final stockValue = json['stock'];
    final int stock = stockValue is num
        ? stockValue.toInt()
        : int.tryParse(stockValue.toString()) ?? 0;

    return VehiclePart(
      id: json['id'] as int,
      name: json['part_name'] as String,
      code: json['part_code'] as String,
      cost: cost,
      stock: stock,
    );
  }
}
