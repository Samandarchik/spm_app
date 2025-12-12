import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiServiceAdmin {
  static const String baseUrl = 'http://0.0.0.0:8050';

  // Kategoriyalar
  static Future<Map<String, dynamic>> createCategory(
    String token,
    String name,
    String description,
    String icon,
    List<String> allowedRoles,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/categories'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'name': name,
        'description': description,
        'icon': icon,
        'allowedRoles': allowedRoles,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(utf8.decode(response.bodyBytes));
    } else {
      throw Exception('Kategoriya yaratilmadi: ${response.body}');
    }
  }

  static Future<Map<String, dynamic>> updateCategory(
    String token,
    String categoryId,
    String name,
    String description,
    String icon,
    List<String> allowedRoles,
  ) async {
    final response = await http.put(
      Uri.parse('$baseUrl/api/categories/$categoryId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'name': name,
        'description': description,
        'icon': icon,
        'allowedRoles': allowedRoles,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(utf8.decode(response.bodyBytes));
    } else {
      throw Exception('Kategoriya yangilanmadi');
    }
  }

  static Future<Map<String, dynamic>> deleteCategory(
    String token,
    String categoryId,
  ) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/api/categories/$categoryId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(utf8.decode(response.bodyBytes));
    } else {
      throw Exception('Kategoriya o\'chirilmadi');
    }
  }

  // Rollar
  static Future<List<String>> getRoles(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/roles'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      return List<String>.from(data['roles'] ?? []);
    } else {
      throw Exception('Rollar yuklanmadi');
    }
  }

  // Savollar
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
    } else {
      throw Exception('Savollar yuklanmadi');
    }
  }

  static Future<Map<String, dynamic>> addSingleQuestion(
    String token,
    String categoryId,
    String question,
    List<String> options,
    String correctAnswer,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/questions/single'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'categoryId': categoryId,
        'question': question,
        'options': options,
        'correctAnswer': correctAnswer,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(utf8.decode(response.bodyBytes));
    } else {
      throw Exception('Savol qo\'shilmadi: ${response.body}');
    }
  }

  static Future<Map<String, dynamic>> addMultipleQuestions(
    String token,
    String categoryId,
    List<Map<String, dynamic>> questions,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/questions'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'categoryId': categoryId,
        'questions': questions,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(utf8.decode(response.bodyBytes));
    } else {
      throw Exception('Savollar qo\'shilmadi: ${response.body}');
    }
  }

  // Statistika
  static Future<Map<String, dynamic>> getAllStatistics(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/statistics'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(utf8.decode(response.bodyBytes));
    } else {
      throw Exception('Statistika yuklanmadi');
    }
  }

  static Future<Map<String, dynamic>> getCategoryStatistics(
    String token,
    String categoryId,
  ) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/statistics/$categoryId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(utf8.decode(response.bodyBytes));
    } else {
      throw Exception('Statistika yuklanmadi');
    }
  }

  // Natijalar
  static Future<Map<String, dynamic>> getResults(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/results'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(utf8.decode(response.bodyBytes));
    } else {
      throw Exception('Natijalar yuklanmadi');
    }
  }
}