import 'package:dio/dio.dart';
import 'package:test_flutter/data/models/res/leave_request_models.dart';
import 'package:test_flutter/data/models/res/punch_models.dart';
import 'package:test_flutter/data/models/res/recruitment_models.dart';
import 'package:test_flutter/data/models/res/schedule_models.dart';
import 'package:test_flutter/data/models/res/user_models.dart';
import 'package:test_flutter/data/services/app_url_service.dart';

class ApiController {
  static String? _token;
  static void setToken(String? token) => _token = token;
  final Dio dio =
      Dio(
          BaseOptions(
            baseUrl: AppUrlService.baseUrl,
            contentType: Headers.jsonContentType,
            responseType: ResponseType.json,
            connectTimeout: const Duration(seconds: 15),
            receiveTimeout: const Duration(seconds: 15),
            validateStatus: (status) {
              return status! < 500;
            },
          ),
        )
        ..interceptors.add(
          InterceptorsWrapper(
            onRequest: (options, handler) {
              options.headers['Accept'] = 'application/json';
              final token = _token;
              if (token != null && token.isNotEmpty) {
                options.headers['Authorization'] = 'Bearer $token';
              }
              handler.next(options);
            },
          ),
        );

  Future<UserModels> login(String email, String password) async {
    try {
      final response = await dio.post(
        AppUrlService.login,
        data: {"email": email, "password": password},
      );

      final data = response.data;
      if (data is Map<String, dynamic>) {
        return UserModels.fromJson(data, statusCode: response.statusCode);
      }

      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        message: 'Unexpected response from server.',
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<List<LeaveType>> fetchLeaveTypes() async {
    final response = await dio.get(AppUrlService.leaveTypes);
    final body = _unwrap(response);
    final data = body['data'];
    if (data is! List || data.any((item) => item is! Map<String, dynamic>)) {
      throw const FormatException('Expected leave types in a data list.');
    }
    return data
        .map((e) => LeaveType.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<LeaveRequest>> fetchLeaveRequests({LeaveStatus? status}) async {
    final List<String?> statuses = status == null ? [null] : status.apiValues;
    final pages = await Future.wait(statuses.map((_fetchLeavePage)));
    return pages.expand((page) => page).toList()
      ..sort((a, b) => b.startDate.compareTo(a.startDate));
  }

  Future<List<LeaveRequest>> _fetchLeavePage(String? status) async {
    final response = await dio.get(
      AppUrlService.leaveRequests,
      queryParameters: {'status': ?status, 'per_page': 100},
    );
    final body = _unwrap(response);
    return (body['data'] as List)
        .map((e) => LeaveRequest.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> submitLeaveRequest({
    required int leaveTypeId,
    required String startDate,
    required String endDate,
    required double days,
    required String reason,
    required String attachmentPath,
    required String attachmentName,
  }) async {
    final form = FormData.fromMap({
      'leave_type_id': leaveTypeId,
      'start_date': startDate,
      'end_date': endDate,
      'days': days,
      'reason': reason,
      'attachment': await MultipartFile.fromFile(
        attachmentPath,
        filename: attachmentName,
      ),
    });

    final response = await dio.post(
      AppUrlService.leaveRequests,
      data: form,
      options: Options(receiveTimeout: const Duration(seconds: 60)),
    );
    _unwrap(response);
  }

  Future<List<Recruitment>> fetchRecruitments({
    int page = 1,
    int perPage = 10,
    String? search,
  }) async {
    final response = await dio.get(
      AppUrlService.recruitments,
      queryParameters: {
        'page': page,
        'per_page': perPage,
        if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
      },
    );
    final body = _unwrap(response);
    return (body['data'] as List)
        .map((e) => Recruitment.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// validateStatus lets 4xx through instead of throwing, so check it here.
  Map<String, dynamic> _unwrap(Response response) {
    final data = response.data;
    final body = data is Map<String, dynamic> ? data : <String, dynamic>{};
    final code = response.statusCode ?? 0;

    // if (code >= 200 && code < 300) return body;
    final httpOk = code >= 200 && code < 300;
    final apiOk = body['success'] != false;
    if (httpOk && apiOk) return body;

    final errors = <String, List<String>>{};
    final rawErrors = body['errors'];
    if (rawErrors is Map) {
      rawErrors.forEach((field, messages) {
        if (messages is List) {
          errors['$field'] = messages.map((m) => '$m').toList();
        }
      });
    }
    throw ApiException(
      body['message']?.toString() ?? 'Request failed ($code)',
      statusCode: code,
      fieldErrors: errors,
    );
  }

  Future<List<PunchType>> fetchAttendanceTypes() async {
    final response = await dio.get(AppUrlService.attendanceTypes);
    final body = _unwrap(response);
    final data = body['data'];
    final rows = data is Map ? data['data'] : data;
    if (rows is! List) {
      throw ApiException('The server did not return an attendance type list.');
    }
    final types = <PunchType>[];
    for (final row in rows) {
      if (row is! Map<String, dynamic>) continue;
      try {
        types.add(PunchType.fromJson(row));
      } on FormatException {
        // Never send a fabricated ID (such as 0) for a malformed API row.
      }
    }
    if (types.isEmpty) {
      throw ApiException(
        'No valid attendance types were returned. Please contact your administrator.',
      );
    }
    return types;
  }

  Future<TodayAttendance> fetchTodayAttendance() async {
    final response = await dio.get(AppUrlService.attendanceToday);
    return TodayAttendance.fromJson(_unwrap(response));
  }

  /// Sends the phone's GPS position; the server compares it with the
  /// employee's branch location and radius.
  ///
  /// Being outside the radius is a normal answer (HTTP 422 with
  /// isCheckinRange:false), so it comes back as a [PunchResult] with
  /// success == false. Anything else that goes wrong throws an ApiException
  /// (already checked in, not linked to an employee, ...).
  Future<PunchResult> recordAttendance({
    required bool isCheckIn,
    required int attendanceTypeId,
    required double latitude,
    required double longitude,
    String? qrCode,
  }) async {
    final response = await dio.post(
      isCheckIn
          ? AppUrlService.attendanceCheckIn
          : AppUrlService.attendanceCheckOut,
      data: {
        'attendance_type_id': attendanceTypeId,
        'latitude': latitude,
        'longitude': longitude,
        // The API does not read this yet; sent so the server can validate it later.
        'qr_code': ?qrCode,
      },
    );

    final data = response.data;
    final body = data is Map<String, dynamic> ? data : <String, dynamic>{};

    if (response.statusCode == 422 && body['isCheckinRange'] == false) {
      return PunchResult.fromJson(body);
    }
    return PunchResult.fromJson(_unwrap(response));
  }

  Future<List<WorkSchedule>> fetchSchedules({
    required String from,
    required String to,
  }) async {
    final items = <WorkSchedule>[];
    var page = 1;
    var lastPage = 1;

    do {
      final response = await dio.get(
        AppUrlService.schedules,
        queryParameters: {
          'from': from,
          'to': to,
          'per_page': 100,
          'page': page,
        },
      );
      final body = _unwrap(response);

      items.addAll(
        (body['data'] as List).map(
          (e) => WorkSchedule.fromJson(e as Map<String, dynamic>),
        ),
      );
      lastPage = int.tryParse('${(body['meta'] as Map?)?['last_page']}') ?? 1;
      page++;
    } while (page <= lastPage && page <= 5);

    return items;
  }

  Future<List<ShiftOption>> fetchShiftOptions() async {
    final response = await dio.get(AppUrlService.shiftOptions);
    final body = _unwrap(response);
    return (body['data'] as List)
        .map((e) => ShiftOption.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// The employee's own shift requests, newest first.
  Future<List<ShiftRequestItem>> fetchShiftRequests() async {
    final response = await dio.get(
      AppUrlService.shiftRequests,
      queryParameters: {'per_page': 100},
    );
    final body = _unwrap(response);
    return (body['data'] as List)
        .map((e) => ShiftRequestItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> submitShiftRequest({
    required int scheduleDetailId,
    required int newShiftId,
    required String reason,
  }) async {
    final response = await dio.post(
      AppUrlService.shiftRequests,
      data: {
        'schedule_detail': scheduleDetailId,
        'new_shift': newShiftId,
        'reason': reason.trim(),
      },
    );
    _unwrap(response);
  }

  Future<void> cancelShiftRequest(int id) async {
    final response = await dio.delete('${AppUrlService.shiftRequests}/$id');
    _unwrap(response);
  }
}

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final Map<String, List<String>> fieldErrors;

  ApiException(this.message, {this.statusCode, this.fieldErrors = const {}});

  /// The most specific message to show the user.
  String get displayMessage {
    final all = fieldErrors.values.expand((e) => e);
    return all.isNotEmpty ? all.first : message;
  }

  @override
  String toString() => message;
}
