class Personnel {
  final int id;
  final String name;
  final String position;
  final String contact;

  Personnel({
    required this.id,
    required this.name,
    required this.position,
    required this.contact,
  });

  factory Personnel.fromJson(Map<String, dynamic> json) {
    return Personnel(
      id: json['id'] as int,
      name: json['name'] as String,
      position: json['position'] as String,
      contact: json['contact'] as String? ?? '',
    );
  }
}
