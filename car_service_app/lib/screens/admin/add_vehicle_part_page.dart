import 'package:flutter/material.dart';
import 'package:car_service_app/services/api.dart';

class AddVehiclePartPage extends StatefulWidget {
  const AddVehiclePartPage({Key? key}) : super(key: key);

  @override
  _AddVehiclePartPageState createState() => _AddVehiclePartPageState();
}

class _AddVehiclePartPageState extends State<AddVehiclePartPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _codeCtrl = TextEditingController();
  final _costCtrl = TextEditingController();
  final _stockCtrl = TextEditingController();
  bool _isLoading = false;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final name = _nameCtrl.text.trim();
    final code = _codeCtrl.text.trim();
    final cost = double.parse(_costCtrl.text.trim());
    final stock = int.parse(_stockCtrl.text.trim());

    final ok = await ApiService().addVehiclePart(
      name,
      code,
      cost,
      stock,
    );

    setState(() => _isLoading = false);
    if (ok) {
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Parça ekleme başarısız')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Parça Ekle')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(labelText: 'Parça Adı'),
                validator: (v) => v?.trim().isEmpty == true ? 'Zorunlu' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _codeCtrl,
                decoration: const InputDecoration(labelText: 'Parça Kodu'),
                validator: (v) => v?.trim().isEmpty == true ? 'Zorunlu' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _costCtrl,
                decoration: const InputDecoration(labelText: 'Maliyet (₺)'),
                keyboardType: TextInputType.number,
                validator: (v) {
                  final t = v?.trim() ?? '';
                  if (t.isEmpty) return 'Zorunlu';
                  return double.tryParse(t) == null ? 'Sayı girin' : null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _stockCtrl,
                decoration: const InputDecoration(labelText: 'Stok Adedi'),
                keyboardType: TextInputType.number,
                validator: (v) {
                  final t = v?.trim() ?? '';
                  if (t.isEmpty) return 'Zorunlu';
                  return int.tryParse(t) == null ? 'Sayı girin' : null;
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
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
