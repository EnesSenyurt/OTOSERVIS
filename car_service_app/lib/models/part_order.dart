class PartOrder {
  final int id;
  final String partName;
  final int quantity;
  final DateTime orderDate;
  final String status;
  final String? clientName;

  PartOrder({
    required this.id,
    required this.partName,
    required this.quantity,
    required this.orderDate,
    required this.status,
    this.clientName,
  });

  factory PartOrder.fromJson(Map<String, dynamic> json,
      {bool isAdmin = false}) {
    return PartOrder(
      id: json['id'] as int,
      partName: json['part_name'] as String,
      quantity: json['quantity'] as int,
      orderDate:
          DateTime.parse((json['order_date'] as String).replaceFirst(' ', 'T')),
      status: json['status'] as String,
      clientName: isAdmin ? json['client_name'] as String : null,
    );
  }
}
