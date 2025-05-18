import 'package:flutter/material.dart';
import 'package:car_service_app/models/vehicle.dart';
import 'package:car_service_app/services/api.dart';
import 'package:car_service_app/screens/add_vehicle_page.dart';

class VehiclesPage extends StatefulWidget {
  const VehiclesPage({Key? key}) : super(key: key);

  @override
  _VehiclesPageState createState() => _VehiclesPageState();
}

class _VehiclesPageState extends State<VehiclesPage> {
  late Future<List<Vehicle>> _futureVehicles;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _futureVehicles = ApiService().getVehicles();
    setState(() {});
  }

  Future<void> _onAddPressed() async {
    final added = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const AddVehiclePage()),
    );
    if (added == true) _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Araçlarım'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Yeni Araç Ekle',
            onPressed: _onAddPressed,
          ),
        ],
      ),
      body: FutureBuilder<List<Vehicle>>(
        future: _futureVehicles,
        builder: (_, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text('Hata: ${snap.error}'));
          }
          final vehicles = snap.data ?? [];
          if (vehicles.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Henüz araç eklenmemiş.'),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text('Araç Ekle'),
                    onPressed: _onAddPressed,
                  ),
                ],
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: vehicles.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (_, i) {
              final v = vehicles[i];
              return ListTile(
                leading: const Icon(Icons.directions_car),
                title: Text('${v.make} ${v.model}'),
                subtitle: Text('${v.plateNumber} — ${v.year}'),
              );
            },
          );
        },
      ),
    );
  }
}
