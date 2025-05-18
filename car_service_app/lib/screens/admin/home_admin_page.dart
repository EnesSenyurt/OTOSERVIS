import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:car_service_app/screens/login_page.dart';
import 'package:car_service_app/screens/admin/services_admin_page.dart';
import 'package:car_service_app/screens/admin/personnel_admin_page.dart';
import 'package:car_service_app/screens/admin/records_admin_page.dart';
import 'package:car_service_app/screens/admin/vehicle_parts_admin_page.dart';
import 'package:car_service_app/screens/admin/part_orders_admin_page.dart';

class HomeAdminPage extends StatefulWidget {
  const HomeAdminPage({Key? key}) : super(key: key);

  @override
  _HomeAdminPageState createState() => _HomeAdminPageState();
}

class _HomeAdminPageState extends State<HomeAdminPage> {
  final _storage = const FlutterSecureStorage();
  int _selectedIndex = 0;

  static const _tabs = [
    ServicesAdminPage(),
    PersonnelAdminPage(),
    RecordsAdminPage(),
  ];
  static const _titles = [
    'Servisler',
    'Personeller',
    'Tüm Kayıtlar',
  ];

  Future<void> _logout() async {
    await _storage.delete(key: 'jwt');
    await _storage.delete(key: 'role');
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_selectedIndex]),
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
              child: Text('Admin Menüsü',
                  style: TextStyle(color: Colors.white, fontSize: 24)),
            ),
            ListTile(
              leading: const Icon(Icons.build),
              title: const Text('Parça Yönetimi'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const VehiclePartsAdminPage(),
                    ));
              },
            ),
            ListTile(
              leading: const Icon(Icons.list),
              title: const Text('Parça Siparişleri'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const PartOrdersAdminPage(),
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
      body: _tabs[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.build), label: 'Servisler'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Personel'),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Kayıtlar'),
        ],
        onTap: _onItemTapped,
      ),
    );
  }
}
