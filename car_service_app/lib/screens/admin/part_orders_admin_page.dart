import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:car_service_app/models/part_order.dart';
import 'package:car_service_app/services/api.dart';

class PartOrdersAdminPage extends StatefulWidget {
  const PartOrdersAdminPage({Key? key}) : super(key: key);

  @override
  _PartOrdersAdminPageState createState() => _PartOrdersAdminPageState();
}

class _PartOrdersAdminPageState extends State<PartOrdersAdminPage> {
  late Future<List<PartOrder>> _futureOrders;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  void _loadOrders() {
    _futureOrders = ApiService().getAllPartOrders();
  }

  String _displayStatus(String raw) {
    switch (raw) {
      case 'approved':
        return 'Onaylandı';
      case 'rejected':
        return 'İptal';
      default:
        return 'Beklemede';
    }
  }

  Future<void> _updateStatus(int id, String newStatus) async {
    final ok = await ApiService().updatePartOrderStatus(id, newStatus);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok
            ? (_displayStatus(newStatus) + ' olarak güncellendi.')
            : 'Güncelleme başarısız oldu.'),
      ),
    );
    if (ok) {
      setState(_loadOrders);
    }
  }

  @override
  Widget build(BuildContext context) {
    final df = DateFormat('dd.MM.yyyy – HH:mm');
    return Scaffold(
      appBar: AppBar(title: const Text('Parça Siparişleri')),
      body: FutureBuilder<List<PartOrder>>(
        future: _futureOrders,
        builder: (_, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text('Hata: ${snap.error}'));
          }
          final orders = snap.data ?? [];
          if (orders.isEmpty) {
            return const Center(child: Text('Henüz sipariş yok.'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            separatorBuilder: (_, __) => const Divider(),
            itemCount: orders.length,
            itemBuilder: (_, i) {
              final o = orders[i];
              return ListTile(
                title: Text(o.partName),
                subtitle: Text(
                  'Müşteri: ${o.clientName}\n'
                  'Adet: ${o.quantity}\n'
                  'Tarih: ${df.format(o.orderDate)}\n'
                  'Durum: ${_displayStatus(o.status)}',
                ),
                isThreeLine: true,
                trailing: PopupMenuButton<String>(
                  onSelected: (s) => _updateStatus(o.id, s),
                  itemBuilder: (_) => [
                    if (o.status != 'approved')
                      const PopupMenuItem(
                        value: 'approved',
                        child: Text('Onayla'),
                      ),
                    if (o.status != 'rejected')
                      const PopupMenuItem(
                        value: 'rejected',
                        child: Text('Reddet'),
                      ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
