import 'package:get_storage/get_storage.dart';
import 'package:test_flutter/data/models/res/punch_models.dart';
import 'package:test_flutter/data/services/app_url_service.dart';

/// Keeps the latest accepted check-in per employee on this device.
/// Check-out may scan a different valid attendance QR at another permitted
/// branch. The server evaluates that scan using fresh GPS and employee policy.
class AttendanceQrService {
  AttendanceQrService({GetStorage? storage}) : _storage = storage;

  GetStorage? _storage;

  Future<GetStorage> _open() async {
    final storage = _storage ??= GetStorage('AttendanceQr');
    await storage.initStorage;
    return storage;
  }

  String _key(PunchRecord record) {
    if (record.id == null ||
        record.id! <= 0 ||
        record.employeeId == null ||
        record.employeeId! <= 0) {
      throw StateError('The server did not identify the check-in record.');
    }
    return '${AppUrlService.baseUrl}:${record.employeeId}';
  }

  Future<void> rememberCheckIn(PunchRecord record, String qrCode) async {
    if (!record.accepted || record.direction != 'in') {
      throw StateError('Only an accepted check-in can save its QR code.');
    }
    final qr = qrCode.trim();
    if (qr.isEmpty) throw StateError('Scan the office QR code first.');
    final key = _key(record);
    final storage = await _open();
    await storage.write(key, {'attendance_id': record.id, 'qr_code': qr});
  }

  Future<void> requireCheckInForCheckOut(PunchRecord checkIn) async {
    final key = _key(checkIn);
    final storage = await _open();
    final saved = storage.read<dynamic>(key);
    if (saved is! Map ||
        saved['attendance_id'] != checkIn.id ||
        saved['qr_code'] is! String ||
        (saved['qr_code'] as String).isEmpty) {
      throw StateError(
        'The check-in record is unavailable on this device. '
        'Use the device you checked in with or contact your administrator.',
      );
    }
  }
}
