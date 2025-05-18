import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:car_service_app/models/service_record.dart';
import 'package:car_service_app/services/api.dart';

class RecordsAdminPage extends StatefulWidget {
  const RecordsAdminPage({Key? key}) : super(key: key);

  @override
  _RecordsAdminPageState createState() => _RecordsAdminPageState();
}

class _RecordsAdminPageState extends State<RecordsAdminPage> {
  late Future<List<ServiceRecord>> _futureAllRecords;

  @override
  void initState() {
    super.initState();
    _futureAllRecords = ApiService().getAllRecords();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ServiceRecord>>(
      future: _futureAllRecords,
      builder: (_, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snap.hasError) {
          return Center(child: Text('Hata: ${snap.error}'));
        }

        final records = snap.data ?? [];
        if (records.isEmpty) {
          return const Center(child: Text('Henüz kayıt yok.'));
        }

        final df = DateFormat('dd.MM.yyyy – HH:mm');

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: records.length,
          separatorBuilder: (_, __) => const Divider(),
          itemBuilder: (_, i) {
            final r = records[i];
            return ListTile(
              leading: const Icon(Icons.build_circle),
              title: Text(r.serviceName),
              subtitle: Text(
                '${r.vehicleInfo}\n'
                'Tarih: ${df.format(r.serviceDate)}\n'
                'Personel: ${r.personnelName}\n'
                'Müşteri: ${r.clientName}',
              ),
              isThreeLine: true,
            );
          },
        );
      },
    );
  }
}
