class Vehicle {
  final int id;
  final String make;
  final String model;
  final String plateNumber;
  final int year;

  Vehicle({
    required this.id,
    required this.make,
    required this.model,
    required this.plateNumber,
    required this.year,
  });

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      id: json['id'] as int,
      make: json['make'] as String,
      model: json['model'] as String,
      plateNumber: json['plateNumber'] as String,
      year: json['year'] as int,
    );
  }
}
