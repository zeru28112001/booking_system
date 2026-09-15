import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../error/app_exception.dart';

/// Shared HTTP client.
/// Handles: base URL, Authorization header, status-code → AppException mapping.
/// Feature-specific JSON parsing is done in *ApiService, not here.
class ApiClient {
  ApiClient({required this._baseUrl, this._apiKey});

  final String _baseUrl;
  final String? _apiKey;
  String? _authToken;

  /// Set the auth token (called from AuthRepositoryImpl after login).
  void setAuthToken(String token) => _authToken = token;

  /// Clear the auth token (called from AuthRepositoryImpl on logout).
  void clearAuthToken() => _authToken = null;

  // ── Headers ───────────────────────────────────────────────────────────────

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (_apiKey != null && _apiKey.isNotEmpty) 'x-api-key': _apiKey,
        if (_authToken != null) 'Authorization': 'Bearer $_authToken',
      };

  // ── HTTP verbs ────────────────────────────────────────────────────────────

  Future<dynamic> get(String path) async {
    return _execute(() => http.get(
          Uri.parse('$_baseUrl$path'),
          headers: _headers,
        ));
  }

  Future<dynamic> post(String path, {Map<String, dynamic>? body}) async {
    return _execute(() => http.post(
          Uri.parse('$_baseUrl$path'),
          headers: _headers,
          body: body != null ? jsonEncode(body) : null,
        ));
  }

  Future<dynamic> put(String path, {Map<String, dynamic>? body}) async {
    return _execute(() => http.put(
          Uri.parse('$_baseUrl$path'),
          headers: _headers,
          body: body != null ? jsonEncode(body) : null,
        ));
  }

  Future<dynamic> patch(String path, {Map<String, dynamic>? body}) async {
    return _execute(() => http.patch(
          Uri.parse('$_baseUrl$path'),
          headers: _headers,
          body: body != null ? jsonEncode(body) : null,
        ));
  }

  Future<dynamic> delete(String path, {Map<String, dynamic>? body}) async {
    return _execute(() => http.delete(
          Uri.parse('$_baseUrl$path'),
          headers: _headers,
          body: body != null ? jsonEncode(body) : null,
        ));
  }

  // ── Internal executor ─────────────────────────────────────────────────────

  Future<dynamic> _execute(Future<http.Response> Function() request) async {
    try {
      final response = await request();
      return _handleResponse(response);
    } on SocketException {
      throw const NetworkException();
    } on http.ClientException {
      throw const NetworkException();
    }
  }

  dynamic _handleResponse(http.Response response) {
    final body = response.body.isNotEmpty
        ? jsonDecode(response.body) as Map<String, dynamic>
        : <String, dynamic>{};

    switch (response.statusCode) {
      case >= 200 && < 300:
        return body;
      case 401:
        final message = (body['message'] as String?) ?? 'Unauthorized access. Please log in.';
        throw UnauthorizedException(message);
      case 404:
        final message = (body['message'] as String?) ?? 'The requested resource was not found.';
        throw NotFoundException(message);
      case 400:
      case 422:
        var message = (body['message'] as String?) ?? 'Validation failed.';
        if (body['details'] is List && (body['details'] as List).isNotEmpty) {
          final detailsList = (body['details'] as List)
              .map((d) => d is Map ? (d['message'] ?? d['field']) : d.toString())
              .where((s) => s != null && s.toString().isNotEmpty)
              .join(', ');
          if (detailsList.isNotEmpty) {
            message = detailsList;
          }
        }
        throw ValidationException(message);
      case >= 500:
        throw const ServerException();
      default:
        final message = (body['message'] as String?) ?? 'Unexpected error occurred.';
        throw AppException(message);
    }
  }
}
