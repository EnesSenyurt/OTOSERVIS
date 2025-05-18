import 'package:flutter/material.dart';
import 'package:car_service_app/services/api.dart';

class AddVehiclePage extends StatefulWidget {
  const AddVehiclePage({Key? key}) : super(key: key);
  @override
  _AddVehiclePageState createState() => _AddVehiclePageState();
}

class _AddVehiclePageState extends State<AddVehiclePage> {
  final _formKey = GlobalKey<FormState>();
  final _make = TextEditingController();
  final _model = TextEditingController();
  final _plate = TextEditingController();
  final _year = TextEditingController();
  bool _isSaving = false;

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    final ok = await ApiService().addVehicle(
      _make.text.trim(),
      _model.text.trim(),
      _plate.text.trim(),
      int.parse(_year.text.trim()),
    );
    setState(() => _isSaving = false);
    if (ok)
      Navigator.pop(context, true);
    else
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Araç eklenemedi')),
      );
  }

  @override
  Widget build(BuildContext c) {
    return Scaffold(
      appBar: AppBar(title: const Text('Yeni Araç Ekle')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _make,
                decoration: const InputDecoration(labelText: 'Marka'),
                validator: (v) => v != null && v.isNotEmpty ? null : 'Zorunlu',
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _model,
                decoration: const InputDecoration(labelText: 'Model'),
                validator: (v) => v != null && v.isNotEmpty ? null : 'Zorunlu',
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _plate,
                decoration: const InputDecoration(labelText: 'Plaka'),
                validator: (v) => v != null && v.isNotEmpty ? null : 'Zorunlu',
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _year,
                decoration: const InputDecoration(labelText: 'Yıl'),
                keyboardType: TextInputType.number,
                validator: (v) {
                  final y = int.tryParse(v ?? '');
                  return (y != null && y > 1900) ? null : 'Geçerli yıl';
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _save,
                  child: _isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Kaydet'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
