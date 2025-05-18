import 'package:flutter/material.dart';
import 'package:car_service_app/models/service.dart';
import 'package:car_service_app/models/vehicle.dart';
import 'package:car_service_app/services/api.dart';
import 'package:car_service_app/screens/home_page.dart';

class CreateRecordPage extends StatefulWidget {
  const CreateRecordPage({Key? key}) : super(key: key);

  @override
  _CreateRecordPageState createState() => _CreateRecordPageState();
}

class _CreateRecordPageState extends State<CreateRecordPage> {
  final _formKey = GlobalKey<FormState>();
  final _notesCtrl = TextEditingController();

  late Future<List<Vehicle>> _futureVehicles;
  late Future<List<Service>> _futureServices;
  int? _vehicleId;
  int? _serviceId;
  DateTime? _scheduledDate;
  TimeOfDay? _scheduledTime;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _futureVehicles = ApiService().getVehicles();
    _futureServices = ApiService().getServices();
  }

  @override
  void dispose() {
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final d = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (d != null) setState(() => _scheduledDate = d);
  }

  Future<void> _pickTime() async {
    final t = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: 9, minute: 0),
    );
    if (t != null) setState(() => _scheduledTime = t);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final date = _scheduledDate!;
    final time = _scheduledTime!;
    final scheduledAt =
        DateTime(date.year, date.month, date.day, time.hour, time.minute);

    setState(() => _isLoading = true);
    final ok = await ApiService().createRecord(
      vehicleId: _vehicleId!,
      serviceId: _serviceId!,
      scheduledAt: scheduledAt,
      notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
    );
    setState(() => _isLoading = false);

    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Randevu başarıyla oluşturuldu')),
      );
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const HomePage(initialIndex: 2)),
        (route) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Randevu oluşturma başarısız')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Servis Kaydı Oluştur')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: FutureBuilder<List<Vehicle>>(
          future: _futureVehicles,
          builder: (ctxV, snapV) {
            if (snapV.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            final vehicles = snapV.data ?? [];
            return FutureBuilder<List<Service>>(
              future: _futureServices,
              builder: (ctxS, snapS) {
                if (snapS.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }
                final services = snapS.data ?? [];
                return Form(
                  key: _formKey,
                  child: ListView(
                    children: [
                      DropdownButtonFormField<int>(
                        decoration:
                            const InputDecoration(labelText: 'Araç Seçin'),
                        items: vehicles.map((v) {
                          return DropdownMenuItem(
                            value: v.id,
                            child:
                                Text('${v.make} ${v.model} — ${v.plateNumber}'),
                          );
                        }).toList(),
                        onChanged: (v) => setState(() => _vehicleId = v),
                        validator: (v) => v == null ? 'Araç seçin' : null,
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<int>(
                        decoration:
                            const InputDecoration(labelText: 'Hizmet Seçin'),
                        items: services.map((s) {
                          return DropdownMenuItem(
                            value: s.id,
                            child:
                                Text('${s.name} (${s.personnelName ?? '—'})'),
                          );
                        }).toList(),
                        onChanged: (v) => setState(() => _serviceId = v),
                        validator: (v) => v == null ? 'Hizmet seçin' : null,
                      ),
                      const SizedBox(height: 12),
                      ListTile(
                        title: Text(
                          _scheduledDate == null
                              ? 'Tarih Seçin'
                              : '${_scheduledDate!.day}.${_scheduledDate!.month}.${_scheduledDate!.year}',
                        ),
                        trailing: const Icon(Icons.calendar_today),
                        onTap: _pickDate,
                      ),
                      ListTile(
                        title: Text(
                          _scheduledTime == null
                              ? 'Saat Seçin'
                              : _scheduledTime!.format(context),
                        ),
                        trailing: const Icon(Icons.access_time),
                        onTap: _pickTime,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _notesCtrl,
                        decoration: const InputDecoration(
                            labelText: 'Notlar (opsiyonel)'),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: (_isLoading ||
                                  _vehicleId == null ||
                                  _serviceId == null ||
                                  _scheduledDate == null ||
                                  _scheduledTime == null)
                              ? null
                              : _submit,
                          child: _isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Text('Kaydet'),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
