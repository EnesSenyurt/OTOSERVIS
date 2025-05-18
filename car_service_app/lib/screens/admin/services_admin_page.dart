import 'package:flutter/material.dart';
import 'package:car_service_app/models/service.dart';
import 'package:car_service_app/models/personnel.dart';
import 'package:car_service_app/services/api.dart';

class ServicesAdminPage extends StatefulWidget {
  const ServicesAdminPage({Key? key}) : super(key: key);

  @override
  _ServicesAdminPageState createState() => _ServicesAdminPageState();
}

class _ServicesAdminPageState extends State<ServicesAdminPage> {
  final _api = ApiService();
  late Future<List<Service>> _futureServices;
  late Future<List<Personnel>> _futurePersonnel;

  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  int? _selectedPersonnelId;
  bool _isAdding = false;

  @override
  void initState() {
    super.initState();
    _refreshServices();
    _futurePersonnel = _api.getPersonnel();
  }

  void _refreshServices() {
    setState(() {
      _futureServices = _api.getServices();
    });
  }

  Future<void> _addService() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isAdding = true);
    final ok = await _api.addService(
      _nameCtrl.text.trim(),
      _descCtrl.text.trim(),
      double.parse(_priceCtrl.text.trim()),
      _selectedPersonnelId!,
    );
    setState(() => _isAdding = false);

    if (ok) {
      _nameCtrl.clear();
      _descCtrl.clear();
      _priceCtrl.clear();
      _selectedPersonnelId = null;
      _refreshServices();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Servis başarıyla eklendi')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Servis eklenemedi')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Servisler (Admin)')),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<List<Service>>(
              future: _futureServices,
              builder: (ctx, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final services = snap.data ?? [];
                if (services.isEmpty) {
                  return const Center(child: Text('Henüz servis yok'));
                }
                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: services.length,
                  separatorBuilder: (_, __) => const Divider(),
                  itemBuilder: (context, i) {
                    final s = services[i];
                    return Dismissible(
                      key: ValueKey(s.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      onDismissed: (_) async {
                        final ok = await _api.deleteService(s.id);
                        if (ok) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('${s.name} silindi')),
                          );
                          _refreshServices();
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Silme başarısız')),
                          );
                          setState(() {});
                        }
                      },
                      child: ListTile(
                        title: Text(s.name),
                        subtitle: Text(
                          '${s.description}\n₺${s.standardPrice.toStringAsFixed(2)} — ${s.personnelName ?? 'Atanmamış'}',
                        ),
                        isThreeLine: true,
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
                    decoration: const InputDecoration(labelText: 'Hizmet Adı'),
                    validator: (v) =>
                        v != null && v.isNotEmpty ? null : 'Zorunlu alan',
                  ),
                  TextFormField(
                    controller: _descCtrl,
                    decoration: const InputDecoration(labelText: 'Açıklama'),
                  ),
                  TextFormField(
                    controller: _priceCtrl,
                    decoration: const InputDecoration(labelText: 'Standart Ücret'),
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      final p = double.tryParse(v ?? '');
                      return p != null ? null : 'Geçerli sayı girin';
                    },
                  ),
                  const SizedBox(height: 12),
                  FutureBuilder<List<Personnel>>(
                    future: _futurePersonnel,
                    builder: (ctx, snap) {
                      if (snap.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      }
                      final persons = snap.data ?? [];
                      return DropdownButtonFormField<int>(
                        decoration:
                            const InputDecoration(labelText: 'Sorumlu Personel'),
                        items: persons
                            .map((p) => DropdownMenuItem(
                                  value: p.id,
                                  child: Text(p.name),
                                ))
                            .toList(),
                        onChanged: (v) =>
                            setState(() => _selectedPersonnelId = v),
                        validator: (v) =>
                            v == null ? 'Personel seçmek zorunlu' : null,
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isAdding ? null : _addService,
                      child: _isAdding
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child:
                                  CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Servis Ekle'),
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
