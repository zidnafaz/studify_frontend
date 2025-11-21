import 'dart:convert';
import 'package:http/http.dart' as http;

class ClassroomService {
  static const String baseUrl = "http://localhost:8000/api"; 
  // Sesuaikan kalau backend Android pakai:
  // static const String baseUrl = "http://10.0.2.2:8000/api";

  static const String token = "DUMMY_TOKEN"; 
  // Nanti ganti setelah fitur login selesai

  // GET /classrooms
  static Future<List<dynamic>> getClassrooms() async {
    final response = await http.get(
      Uri.parse("$baseUrl/classrooms"),
      headers: {"Authorization": "Bearer $token"},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body)["data"] ?? [];
    }
    return [];
  }

  // POST /classrooms
  static Future<bool> createClass({
    required String name,
    required String description,
  }) async {
    final response = await http.post(
      Uri.parse("$baseUrl/classrooms"),
      headers: {"Authorization": "Bearer $token"},
      body: {
        "name": name,
        "description": description,
      },
    );

    return response.statusCode == 201;
  }

  // POST /classrooms/join
  static Future<bool> joinClass(String code) async {
    final response = await http.post(
      Uri.parse("$baseUrl/classrooms/join"),
      headers: {"Authorization": "Bearer $token"},
      body: {"unique_code": code},
    );

    return response.statusCode == 200;
  }

  // GET /classrooms/{id}
  static Future<Map<String, dynamic>?> getClassDetail(int id) async {
    final response = await http.get(
      Uri.parse("$baseUrl/classrooms/$id"),
      headers: {"Authorization": "Bearer $token"},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body)["data"];
    }
    return null;
  }
}
