import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../constants/app_constants.dart';
import 'storage_service.dart';

/// HTTP Service
/// Mengelola semua HTTP request ke REST API
class HttpService {
  // Get Headers
  static Future<Map<String, String>> _getHeaders({bool includeAuth = true}) async {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    
    if (includeAuth) {
      final token = StorageService.getString(AppConstants.tokenKey);
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    
    return headers;
  }
  
  // GET Request
  static Future<Map<String, dynamic>> get(
    String endpoint, {
    Map<String, String>? queryParams,
    bool includeAuth = true,
  }) async {
    try {
      var uri = Uri.parse('${AppConfig.baseUrl}$endpoint');
      
      if (queryParams != null && queryParams.isNotEmpty) {
        uri = uri.replace(queryParameters: queryParams);
      }
      
      final headers = await _getHeaders(includeAuth: includeAuth);
      
      final response = await http.get(uri, headers: headers).timeout(
        Duration(seconds: AppConfig.requestTimeout),
      );
      
      return _handleResponse(response);
    } on SocketException {
      throw Exception('Tidak ada koneksi internet');
    } on HttpException {
      throw Exception('Tidak dapat terhubung ke server');
    } on FormatException {
      throw Exception('Format response tidak valid');
    } catch (e) {
      throw Exception('Terjadi kesalahan: ${e.toString()}');
    }
  }
  
  // POST Request
  static Future<Map<String, dynamic>> post(
    String endpoint, {
    Map<String, dynamic>? body,
    bool includeAuth = true,
  }) async {
    try {
      final uri = Uri.parse('${AppConfig.baseUrl}$endpoint');
      final headers = await _getHeaders(includeAuth: includeAuth);
      
      final response = await http.post(
        uri,
        headers: headers,
        body: body != null ? json.encode(body) : null,
      ).timeout(
        Duration(seconds: AppConfig.requestTimeout),
      );
      
      return _handleResponse(response);
    } on SocketException {
      throw Exception('Tidak ada koneksi internet');
    } on HttpException {
      throw Exception('Tidak dapat terhubung ke server');
    } on FormatException {
      throw Exception('Format response tidak valid');
    } catch (e) {
      throw Exception('Terjadi kesalahan: ${e.toString()}');
    }
  }
  
  // PUT Request
  static Future<Map<String, dynamic>> put(
    String endpoint, {
    Map<String, dynamic>? body,
    bool includeAuth = true,
  }) async {
    try {
      final uri = Uri.parse('${AppConfig.baseUrl}$endpoint');
      final headers = await _getHeaders(includeAuth: includeAuth);
      
      final response = await http.put(
        uri,
        headers: headers,
        body: body != null ? json.encode(body) : null,
      ).timeout(
        Duration(seconds: AppConfig.requestTimeout),
      );
      
      return _handleResponse(response);
    } on SocketException {
      throw Exception('Tidak ada koneksi internet');
    } on HttpException {
      throw Exception('Tidak dapat terhubung ke server');
    } on FormatException {
      throw Exception('Format response tidak valid');
    } catch (e) {
      throw Exception('Terjadi kesalahan: ${e.toString()}');
    }
  }
  
  // DELETE Request
  static Future<Map<String, dynamic>> delete(
    String endpoint, {
    bool includeAuth = true,
  }) async {
    try {
      final uri = Uri.parse('${AppConfig.baseUrl}$endpoint');
      final headers = await _getHeaders(includeAuth: includeAuth);
      
      final response = await http.delete(uri, headers: headers).timeout(
        Duration(seconds: AppConfig.requestTimeout),
      );
      
      return _handleResponse(response);
    } on SocketException {
      throw Exception('Tidak ada koneksi internet');
    } on HttpException {
      throw Exception('Tidak dapat terhubung ke server');
    } on FormatException {
      throw Exception('Format response tidak valid');
    } catch (e) {
      throw Exception('Terjadi kesalahan: ${e.toString()}');
    }
  }
  
  // Multipart Request (for file upload)
  static Future<Map<String, dynamic>> multipart(
    String endpoint,
    String method, {
    Map<String, String>? fields,
    Map<String, String>? files,
    bool includeAuth = true,
  }) async {
    try {
      final uri = Uri.parse('${AppConfig.baseUrl}$endpoint');
      final request = http.MultipartRequest(method, uri);
      
      // Add headers
      final headers = await _getHeaders(includeAuth: includeAuth);
      request.headers.addAll(headers);
      
      // Add fields
      if (fields != null) {
        request.fields.addAll(fields);
      }
      
      // Add files
      if (files != null) {
        for (var entry in files.entries) {
          request.files.add(await http.MultipartFile.fromPath(
            entry.key,
            entry.value,
          ));
        }
      }
      
      final streamedResponse = await request.send().timeout(
        Duration(seconds: AppConfig.requestTimeout),
      );
      
      final response = await http.Response.fromStream(streamedResponse);
      
      return _handleResponse(response);
    } on SocketException {
      throw Exception('Tidak ada koneksi internet');
    } on HttpException {
      throw Exception('Tidak dapat terhubung ke server');
    } on FormatException {
      throw Exception('Format response tidak valid');
    } catch (e) {
      throw Exception('Terjadi kesalahan: ${e.toString()}');
    }
  }
  
  // Handle Response
  static Map<String, dynamic> _handleResponse(http.Response response) {
    final statusCode = response.statusCode;
    
    if (statusCode >= 200 && statusCode < 300) {
      // Success
      if (response.body.isEmpty) {
        return {'success': true};
      }
      return json.decode(response.body);
    } else if (statusCode == 401) {
      // Unauthorized
      throw Exception('Sesi Anda telah berakhir. Silakan login kembali.');
    } else if (statusCode == 403) {
      // Forbidden
      throw Exception('Anda tidak memiliki akses untuk melakukan aksi ini.');
    } else if (statusCode == 404) {
      // Not Found
      throw Exception('Data tidak ditemukan.');
    } else if (statusCode >= 500) {
      // Server Error
      throw Exception('Terjadi kesalahan pada server. Silakan coba lagi nanti.');
    } else {
      // Other errors
      try {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Terjadi kesalahan.');
      } catch (e) {
        throw Exception('Terjadi kesalahan: ${response.reasonPhrase}');
      }
    }
  }
}
