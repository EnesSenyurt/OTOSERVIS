import 'package:flutter/material.dart';
import 'package:car_service_app/models/vehicle_part.dart';
import 'package:car_service_app/services/api.dart';
import 'package:car_service_app/screens/admin/add_vehicle_part_page.dart';

class VehiclePartsAdminPage extends StatefulWidget {
  const VehiclePartsAdminPage({Key? key}) : super(key: key);

  @override
  _VehiclePartsAdminPageState createState() => _VehiclePartsAdminPageState();
}

class _VehiclePartsAdminPageState extends State<VehiclePartsAdminPage> {
  late Future<List<VehiclePart>> _futureParts;

  @override
  void initState() {
    super.initState();
    _futureParts = ApiService().getVehicleParts();
  }

  Future<void> _load() async {
    setState(() {
      _futureParts = ApiService().getVehicleParts();
    });
  }

  Future<void> _onAdd() async {
    final added = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const AddVehiclePartPage()),
    );
    if (added == true) _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Araç Parçaları'),
        actions: [IconButton(icon: const Icon(Icons.add), onPressed: _onAdd)],
      ),
      body: FutureBuilder<List<VehiclePart>>(
        future: _futureParts,
        builder: (_, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text('Hata: ${snap.error}'));
          }
          final parts = snap.data ?? [];
          if (parts.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Henüz parça eklenmemiş.'),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text('Parça Ekle'),
                    onPressed: _onAdd,
                  ),
                ],
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            separatorBuilder: (_, __) => const Divider(),
            itemCount: parts.length,
            itemBuilder: (_, i) {
              final p = parts[i];
              return ListTile(
                title: Text(p.name),
                subtitle: Text(
                    'Kod: ${p.code}\nMaliyet: ${p.cost.toStringAsFixed(2)}₺    Stok: ${p.stock}'),
                isThreeLine: true,
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () async {
                    final ok = await ApiService().deleteVehiclePart(p.id);
                    if (ok) _load();
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
