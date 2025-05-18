import 'package:flutter/material.dart';
import 'package:car_service_app/models/service.dart';
import 'package:car_service_app/services/api.dart';

class ServicesPage extends StatefulWidget {
  const ServicesPage({Key? key}) : super(key: key);

  @override
  _ServicesPageState createState() => _ServicesPageState();
}

class _ServicesPageState extends State<ServicesPage> {
  late Future<List<Service>> _futureServices;

  @override
  void initState() {
    super.initState();
    _loadServices();
  }

  void _loadServices() {
    _futureServices = ApiService().getServices();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hizmetler'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadServices,
            tooltip: 'Yenile',
          )
        ],
      ),
      body: FutureBuilder<List<Service>>(
        future: _futureServices,
        builder: (ctx, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text('Hata: ${snap.error}'));
          }
          final services = snap.data ?? [];
          if (services.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.build_circle_outlined,
                      size: 64, color: Colors.grey),
                  SizedBox(height: 12),
                  Text('Henüz hizmet eklenmemiş.',
                      style: TextStyle(fontSize: 16)),
                ],
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: services.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (context, i) {
              final s = services[i];
              return ListTile(
                leading: const Icon(Icons.build),
                title: Text(s.name,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(
                  '${s.description.isNotEmpty ? s.description + '\n' : ''}'
                  'Ücret: ₺${s.standardPrice.toStringAsFixed(2)}\n'
                  'Personel: ${s.personnelName ?? 'Atanmamış'}',
                  style: const TextStyle(height: 1.3),
                ),
                isThreeLine: true,
              );
            },
          );
        },
      ),
    );
  }
}
