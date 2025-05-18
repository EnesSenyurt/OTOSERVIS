class ServiceRecord {
  final int id;
  final String serviceName;
  final String vehicleInfo;
  final String personnelName;
  final String clientName;
  final DateTime serviceDate;

  ServiceRecord({
    required this.id,
    required this.serviceName,
    required this.vehicleInfo,
    required this.personnelName,
    required this.clientName,
    required this.serviceDate,
  });

  factory ServiceRecord.fromJson(Map<String, dynamic> json) {
    final id = json['id'] as int? ?? 0;

    final serviceName = (json['service_name'] as String?)?.trim() ?? '—';

    final vehicleInfo = (json['vehicle_info'] as String?)?.trim() ?? '—';

    final personnelName = (json['personnel_name'] as String?)?.trim() ?? '—';

    final clientName = (json['client_name'] as String?)?.trim() ?? '—';

    final rawDate = (json['service_date'] as String?) ?? '';
    DateTime dt;
    if (rawDate.isNotEmpty) {
      final iso =
          rawDate.contains('T') ? rawDate : rawDate.replaceFirst(' ', 'T');
      dt = DateTime.tryParse(iso) ?? DateTime.now();
    } else {
      dt = DateTime.now();
    }

    return ServiceRecord(
      id: id,
      serviceName: serviceName,
      vehicleInfo: vehicleInfo,
      personnelName: personnelName,
      clientName: clientName,
      serviceDate: dt,
    );
  }
}
