import 'package:flutter/material.dart';
import 'package:car_service_app/services/api.dart';
import 'package:car_service_app/models/personnel.dart';

class PersonnelAdminPage extends StatefulWidget {
  const PersonnelAdminPage({Key? key}) : super(key: key);

  @override
  _PersonnelAdminPageState createState() => _PersonnelAdminPageState();
}

class _PersonnelAdminPageState extends State<PersonnelAdminPage> {
  final ApiService _api = ApiService();
  late Future<List<Personnel>> _futureList;

  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _positionCtrl = TextEditingController();
  final _contactCtrl = TextEditingController();
  bool _isAdding = false;

  @override
  void initState() {
    super.initState();
    _refreshList();
  }

  void _refreshList() {
    setState(() {
      _futureList = _api.getPersonnel();
    });
  }

  Future<void> _addPersonnel() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isAdding = true);

    final ok = await _api.addPersonnel(
      _nameCtrl.text.trim(),
      _positionCtrl.text.trim(),
      _contactCtrl.text.trim(),
    );

    setState(() => _isAdding = false);

    if (ok) {
      _nameCtrl.clear();
      _positionCtrl.clear();
      _contactCtrl.clear();
      _refreshList();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Personel eklendi')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Eklenemedi')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Personeller (Admin)')),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<List<Personnel>>(
              future: _futureList,
              builder: (ctx, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snap.hasError) {
                  return Center(child: Text('Hata: ${snap.error}'));
                }
                final list = snap.data ?? [];
                if (list.isEmpty) {
                  return const Center(child: Text('Henüz personel yok'));
                }
                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: list.length,
                  separatorBuilder: (_, __) => const Divider(),
                  itemBuilder: (context, i) {
                    final p = list[i];
                    return Dismissible(
                      key: ValueKey(p.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      onDismissed: (_) async {
                        final ok = await _api.deletePersonnel(p.id);
                        if (ok) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('${p.name} silindi')),
                          );
                          _refreshList();
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Silme başarısız')),
                          );
                          setState(() {});
                        }
                      },
                      child: ListTile(
                        title: Text(p.name),
                        subtitle: Text('${p.position} • ${p.contact}'),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _nameCtrl,
                    decoration: const InputDecoration(labelText: 'Ad Soyad'),
                    validator: (v) =>
                        (v != null && v.isNotEmpty) ? null : 'Gerekli alan',
                  ),
                  TextFormField(
                    controller: _positionCtrl,
                    decoration: const InputDecoration(labelText: 'Pozisyon'),
                    validator: (v) =>
                        (v != null && v.isNotEmpty) ? null : 'Gerekli alan',
                  ),
                  TextFormField(
                    controller: _contactCtrl,
                    decoration: const InputDecoration(
                        labelText: 'İletişim (opsiyonel)'),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isAdding ? null : _addPersonnel,
                      child: _isAdding
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Personel Ekle'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
