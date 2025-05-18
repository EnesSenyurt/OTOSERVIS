import 'package:flutter/material.dart';
import 'package:car_service_app/models/vehicle_part.dart';
import 'package:car_service_app/services/api.dart';

class VehiclePartsPage extends StatefulWidget {
  const VehiclePartsPage({Key? key}) : super(key: key);

  @override
  _VehiclePartsPageState createState() => _VehiclePartsPageState();
}

class _VehiclePartsPageState extends State<VehiclePartsPage> {
  late Future<List<VehiclePart>> _futureParts;
  final Map<int, int> _qty = {};

  @override
  void initState() {
    super.initState();
    _futureParts = ApiService().getVehicleParts();
  }

  Future<void> _order(int partId) async {
    final quantity = _qty[partId] ?? 1;
    final ok = await ApiService().orderPart(partId, quantity);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(ok ? 'Sipariş alındı' : 'Sipariş başarısız')),
    );
    if (ok) {
      setState(() {
        _futureParts = ApiService().getVehicleParts();

        _qty.remove(partId);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Parçalar')),
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
            return const Center(child: Text('Henüz parça yok.'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: parts.length,
            itemBuilder: (_, i) {
              final p = parts[i];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(p.name,
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text(
                        'Kod: ${p.code}    Fiyat: ${p.cost.toStringAsFixed(2)}₺    Stok: ${p.stock}',
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Text('Adet:'),
                          const SizedBox(width: 8),
                          DropdownButton<int>(
                            value: _qty[p.id] ?? 1,
                            items: List.generate(
                              p.stock,
                              (j) => DropdownMenuItem(
                                value: j + 1,
                                child: Text('${j + 1}'),
                              ),
                            ),
                            onChanged: p.stock > 0
                                ? (v) => setState(() => _qty[p.id] = v!)
                                : null,
                          ),
                          const Spacer(),
                          ElevatedButton(
                            onPressed: p.stock > 0 ? () => _order(p.id) : null,
                            child: const Text('Sipariş Ver'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
