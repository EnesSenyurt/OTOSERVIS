import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:car_service_app/models/service_record.dart';
import 'package:car_service_app/services/api.dart';

class MyRecordsPage extends StatefulWidget {
  const MyRecordsPage({Key? key}) : super(key: key);

  @override
  _MyRecordsPageState createState() => _MyRecordsPageState();
}

class _MyRecordsPageState extends State<MyRecordsPage> {
  late Future<List<ServiceRecord>> _futureRecords;

  @override
  void initState() {
    super.initState();
    _futureRecords = ApiService().getMyRecords();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ServiceRecord>>(
      future: _futureRecords,
      builder: (_, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snap.hasError) {
          return Center(child: Text('Hata: ${snap.error}'));
        }
        final records = snap.data ?? [];
        if (records.isEmpty) {
          return const Center(child: Text('Henüz randevunuz yok.'));
        }

        final df = DateFormat('dd.MM.yyyy – HH:mm');

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: records.length,
          separatorBuilder: (_, __) => const Divider(),
          itemBuilder: (_, i) {
            final r = records[i];
            return ListTile(
              leading: const Icon(Icons.event_available),
              title: Text(r.serviceName),
              subtitle: Text(
                '${r.vehicleInfo}\n'
                'Tarih: ${df.format(r.serviceDate)}\n'
                'Personel: ${r.personnelName}',
              ),
              isThreeLine: true,
            );
          },
        );
      },
    );
  }
}
