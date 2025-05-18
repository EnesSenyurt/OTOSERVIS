import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:car_service_app/models/part_order.dart';
import 'package:car_service_app/services/api.dart';

class MyPartOrdersPage extends StatefulWidget {
  const MyPartOrdersPage({Key? key}) : super(key: key);

  @override
  _MyPartOrdersPageState createState() => _MyPartOrdersPageState();
}

class _MyPartOrdersPageState extends State<MyPartOrdersPage> {
  late Future<List<PartOrder>> _futureOrders;

  @override
  void initState() {
    super.initState();
    _futureOrders = ApiService().getMyPartOrders();
  }

  @override
  Widget build(BuildContext context) {
    final df = DateFormat('dd.MM.yyyy – HH:mm');
    return Scaffold(
      appBar: AppBar(title: const Text('Siparişlerim')),
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
            return const Center(child: Text('Henüz siparişiniz yok.'));
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
                  'Adet: ${o.quantity}\n'
                  'Tarih: ${df.format(o.orderDate)}\n'
                  'Durum: ${o.status}',
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
