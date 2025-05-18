import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:car_service_app/models/login_response.dart';
import 'package:car_service_app/models/service.dart';
import 'package:car_service_app/models/service_record.dart';
import 'package:car_service_app/models/personnel.dart';
import 'package:car_service_app/models/vehicle.dart';
import 'package:car_service_app/models/vehicle_part.dart';
import 'package:car_service_app/models/part_order.dart';

class ApiService {
  static const String _baseUrl = 'http://10.0.2.2:3000/api';
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<Map<String, String>> _headers() async {
    final token = await _storage.read(key: 'jwt');
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<http.Response> _get(String path) async =>
      http.get(Uri.parse('$_baseUrl$path'), headers: await _headers());

  Future<http.Response> _post(String path, Map body) async => http.post(
        Uri.parse('$_baseUrl$path'),
        headers: await _headers(),
        body: jsonEncode(body),
      );

  Future<http.Response> _put(String path, Map body) async => http.put(
        Uri.parse('$_baseUrl$path'),
        headers: await _headers(),
        body: jsonEncode(body),
      );

  Future<http.Response> _delete(String path) async =>
      http.delete(Uri.parse('$_baseUrl$path'), headers: await _headers());

  Future<bool> register(String name, String email, String password) async {
    try {
      final res = await http.post(
        Uri.parse('$_baseUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'name': name, 'email': email, 'password': password}),
      );
      return res.statusCode == 201;
    } catch (_) {
      return false;
    }
  }

  Future<LoginResponse?> login(String email, String password) async {
    try {
      final res = await http.post(
        Uri.parse('$_baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body) as Map<String, dynamic>;
        final resp = LoginResponse.fromJson(body);
        await _storage.write(key: 'jwt', value: resp.token);
        await _storage.write(key: 'role', value: resp.role);
        return resp;
      }
    } catch (_) {}
    return null;
  }

  Future<void> logout() async {
    await _storage.delete(key: 'jwt');
    await _storage.delete(key: 'role');
  }

  Future<List<Vehicle>> getVehicles() async {
    final res = await _get('/vehicles');
    if (res.statusCode == 200) {
      final list = jsonDecode(res.body) as List;
      return list.map((e) => Vehicle.fromJson(e)).toList();
    }
    throw Exception('Araçlar yüklenemedi (${res.statusCode})');
  }

  Future<bool> addVehicle(
      String make, String model, String plateNumber, int year) async {
    final res = await _post('/vehicles', {
      'make': make,
      'model': model,
      'plateNumber': plateNumber,
      'year': year,
    });
    return res.statusCode == 201;
  }

  Future<List<Service>> getServices() async {
    final res = await _get('/services');
    if (res.statusCode == 200) {
      final list = jsonDecode(res.body) as List;
      return list.map((e) => Service.fromJson(e)).toList();
    }
    throw Exception('Hizmetler yüklenemedi (${res.statusCode})');
  }

  Future<bool> addService(
      String name, String description, double price, int personnelId) async {
    final res = await _post('/services', {
      'name': name,
      'description': description,
      'standard_price': price,
      'personnel_id': personnelId,
    });
    return res.statusCode == 201;
  }

  Future<bool> deleteService(int id) async {
    final res = await _delete('/services/$id');
    return res.statusCode == 204;
  }

  Future<List<Personnel>> getPersonnel() async {
    final res = await _get('/personnel');
    if (res.statusCode == 200) {
      final list = jsonDecode(res.body) as List;
      return list.map((e) => Personnel.fromJson(e)).toList();
    }
    throw Exception('Personel yüklenemedi (${res.statusCode})');
  }

  Future<bool> addPersonnel(
      String name, String position, String contact) async {
    final res = await _post('/personnel', {
      'name': name,
      'position': position,
      'contact': contact,
    });
    return res.statusCode == 201;
  }

  Future<bool> deletePersonnel(int id) async {
    final res = await _delete('/personnel/$id');
    return res.statusCode == 204;
  }

  Future<bool> createRecord({
    required int vehicleId,
    required int serviceId,
    required DateTime scheduledAt,
    String? notes,
  }) async {
    final res = await _post('/create-record', {
      'vehicleId': vehicleId,
      'serviceId': serviceId,
      'scheduledAt': scheduledAt.toIso8601String(),
      'notes': notes,
    });
    return res.statusCode == 201;
  }

  Future<List<ServiceRecord>> getMyRecords() async {
    final res = await _get('/my-records');
    if (res.statusCode == 200) {
      final list = jsonDecode(res.body) as List;
      return list.map((e) => ServiceRecord.fromJson(e)).toList();
    }
    throw Exception('Randevular yüklenemedi (${res.statusCode})');
  }

  Future<List<ServiceRecord>> getAllRecords() async {
    final res = await _get('/records');
    if (res.statusCode == 200) {
      final list = jsonDecode(res.body) as List;
      return list.map((e) => ServiceRecord.fromJson(e)).toList();
    }
    throw Exception('Tüm randevular yüklenemedi (${res.statusCode})');
  }

  Future<List<VehiclePart>> getVehicleParts() async {
    final res = await _get('/vehicle-parts');
    if (res.statusCode == 200) {
      final list = jsonDecode(res.body) as List;
      return list.map((e) => VehiclePart.fromJson(e)).toList();
    }
    throw Exception('Parçalar yüklenemedi (${res.statusCode})');
  }

  Future<bool> addVehiclePart(
      String name, String code, double cost, int stock) async {
    final res = await _post('/vehicle-parts', {
      'part_name': name,
      'part_code': code,
      'cost': cost,
      'stock': stock,
    });
    return res.statusCode == 201;
  }

  Future<bool> deleteVehiclePart(int id) async {
    final res = await _delete('/vehicle-parts/$id');
    return res.statusCode == 204;
  }

  Future<List<PartOrder>> getMyPartOrders() async {
    final res = await _get('/part-orders');
    if (res.statusCode == 200) {
      final list = jsonDecode(res.body) as List;

      return list.map((e) => PartOrder.fromJson(e)).toList();
    }
    throw Exception('Siparişler yüklenemedi (${res.statusCode})');
  }

  Future<List<PartOrder>> getAllPartOrders() async {
    final res = await _get('/part-orders');
    if (res.statusCode == 200) {
      final list = jsonDecode(res.body) as List;

      return list.map((e) => PartOrder.fromJson(e, isAdmin: true)).toList();
    }
    throw Exception('Siparişler yüklenemedi (${res.statusCode})');
  }

  Future<bool> orderPart(int partId, int quantity) async {
    final res = await _post('/part-orders', {
      'partId': partId,
      'quantity': quantity,
    });
    return res.statusCode == 201;
  }

  Future<bool> updatePartOrderStatus(int orderId, String status) async {
    final res = await _put('/part-orders/$orderId', {'status': status});
    return res.statusCode == 200;
  }
}
