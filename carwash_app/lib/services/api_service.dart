import 'package:dio/dio.dart';

class ApiService {
  static final Dio _dio = Dio(BaseOptions(
    baseUrl: 'http://192.168.1.3:3001/api', // Your new IP
    connectTimeout: 10000,
    receiveTimeout: 10000,
    headers: {'Content-Type': 'application/json'},
  ));

  // POST Request
  static Future<Response> post(String path, dynamic data) async {
    try {
      final response = await _dio.post(path, data: data);
      return response;
    } on DioError catch (e) {
      final responseData = e.response?.data;
      // Check if the error is a Map (JSON) before trying to read it
      if (responseData is Map) {
        throw responseData['message'] ?? 'Connection failed';
      }
      throw 'Connection failed';
    }
  }

  // GET Request
  static Future<Response> get(String path) async {
    try {
      final response = await _dio.get(path);
      return response;
    } on DioError catch (e) {
      final responseData = e.response?.data;
      if (responseData is Map) {
        throw responseData['message'] ?? 'Connection failed';
      }
      throw 'Connection failed';
    }
  }

  // PUT Request
  static Future<Response> put(String path, dynamic data) async {
    try {
      final response = await _dio.put(path, data: data);
      return response;
    } on DioError catch (e) {
      final responseData = e.response?.data;
      if (responseData is Map) {
        throw responseData['message'] ?? 'Connection failed';
      }
      throw 'Connection failed';
    }
  }
}
