import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'services_page.dart';
import 'create_record_page.dart';
import 'my_records_page.dart';
import 'vehicles_page.dart';
import 'login_page.dart';
import 'vehicle_parts_page.dart';
import 'my_part_orders_page.dart';

class HomePage extends StatefulWidget {
  final int initialIndex;
  const HomePage({Key? key, this.initialIndex = 0}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late int _currentIndex;
  final _storage = const FlutterSecureStorage();

  static const _pages = [
    ServicesPage(),
    CreateRecordPage(),
    MyRecordsPage(),
    VehiclesPage(),
  ];
  static const _titles = [
    'Hizmetler',
    'Yeni Randevu',
    'Randevularım',
    'Araçlarım',
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  Future<void> _logout() async {
    await _storage.delete(key: 'jwt');
    await _storage.delete(key: 'role');
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  void _onTap(int idx) => setState(() => _currentIndex = idx);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_currentIndex]),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Çıkış Yap',
            onPressed: _logout,
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text('Menü',
                  style: TextStyle(color: Colors.white, fontSize: 24)),
            ),
            ListTile(
              leading: const Icon(Icons.build),
              title: const Text('Parçalar'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const VehiclePartsPage(),
                    ));
              },
            ),
            ListTile(
              leading: const Icon(Icons.shopping_cart),
              title: const Text('Siparişlerim'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const MyPartOrdersPage(),
                    ));
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Ana Sayfa'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Çıkış'),
              onTap: _logout,
            ),
          ],
        ),
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTap,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.build), label: 'Hizmetler'),
          BottomNavigationBarItem(icon: Icon(Icons.add), label: 'Randevu'),
          BottomNavigationBarItem(
              icon: Icon(Icons.list), label: 'Randevularım'),
          BottomNavigationBarItem(
              icon: Icon(Icons.directions_car), label: 'Araçlarım'),
        ],
      ),
    );
  }
}
