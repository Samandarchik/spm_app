// API Service
import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://0.0.0.0:8050';

  static Future<Map<String, dynamic>> login(
    String username,
    String password,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );
    print(response.body);
    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Login xatosi: ${response.body}');
    }
  }

  static Future<Map<String, dynamic>> register(
    String username,
    String password,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'password': password,
        "role": "register",
      }),
    );
    print(response.body);
    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Login xatosi: ${response.body}');
    }
  }

  static Future<Map<String, dynamic>> getCategories(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/categories'),
      headers: {'Authorization': 'Bearer $token'},
    );
    print(response.body);
    if (response.statusCode == 200) {
      return jsonDecode(utf8.decode(response.bodyBytes));
    } else {
      throw Exception('Kategoriyalar yuklanmadi');
    }
  }

  static Future<Map<String, dynamic>> getQuestions(
    String token,
    String categoryId,
  ) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/categories/$categoryId/questions'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(utf8.decode(response.bodyBytes));
    } else if (response.statusCode == 403) {
      throw Exception('Bu kategoriyaga ruxsatingiz yo\'q');
    } else {
      throw Exception('Savollar yuklanmadi');
    }
  }

  static Future<Map<String, dynamic>> submitAnswers(
    String token,
    String categoryId,
    List<Map<String, dynamic>> answers,
    int timeSpent,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/check'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'categoryId': categoryId,
        'answers': answers,
        'timeSpent': timeSpent,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(utf8.decode(response.bodyBytes));
    } else {
      throw Exception('Javoblar tekshirilmadi: ${response.body}');
    }
  }
}
