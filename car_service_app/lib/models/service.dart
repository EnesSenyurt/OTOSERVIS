class Service {
  final int id;
  final String name;
  final String description;
  final double standardPrice;
  final int? personnelId;
  final String? personnelName;

  Service({
    required this.id,
    required this.name,
    required this.description,
    required this.standardPrice,
    this.personnelId,
    this.personnelName,
  });

  factory Service.fromJson(Map<String, dynamic> json) {
    final raw = json['standard_price'];
    double price =
        (raw is num) ? raw.toDouble() : double.tryParse(raw as String) ?? 0.0;
    return Service(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      standardPrice: price,
      personnelId: (json['personnel_id'] as num?)?.toInt(),
      personnelName: json['personnel_name'] as String?,
    );
  }
}
