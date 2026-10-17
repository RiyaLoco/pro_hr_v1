import 'package:dio/dio.dart';
import 'package:test_flutter/data/models/res/leave_request_models.dart';
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
    return (body['data'] as List)
        .map((e) => LeaveType.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<LeaveRequest>> fetchLeaveRequests() async {
    final response = await dio.get(
      AppUrlService.leaveRequests,
      queryParameters: {
        'per_page': 100,
      },
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
    String? reason,
  })async{
    final response = await dio.post(AppUrlService.leaveRequests,data:{
      'leave_type_id': leaveTypeId,
      'start_date': startDate,
      'end_date': endDate,
      if (reason != null && reason.trim().isNotEmpty) 'reason': reason.trim(),
    });
    _unwrap(response);
  }
 
  Map<String, dynamic> _unwrap(Response response) {
    final data = response.data;
    final body = data is Map<String, dynamic> ? data : <String, dynamic>{};
    final code = response.statusCode ?? 0;

    if (code >= 200 && code < 300) return body;
    final errors = <String, List<String>>{};
    final rawErrors = body['errors'];
    if (rawErrors is Map) {
      rawErrors.forEach((filed, message) {
        if (message is List) {
          errors['$filed'] = message.map((m) => '$m').toList();
        }
      });
    }
    throw ApiException(
      body['message']?.toString() ?? 'Request failed with status code $code',
      statusCode: code,
      fieldErrors: errors,
    );
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
