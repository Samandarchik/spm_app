import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class ApiServiceAdmin {
  static const String baseUrl = 'http://139.99.61.222:8050';

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

  static Future<Map<String, dynamic>> updateQuestion(
    String token,
    String questionId,
    String categoryId,
    String question,
    List<String> options,
    String correctAnswer, {
    String? imageUrl, // ← YANGI
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl/api/questions/$questionId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'categoryId': categoryId,
        'question': question,
        'options': options,
        'correctAnswer': correctAnswer,
        if (imageUrl != null) 'imageUrl': imageUrl, // ← YANGI
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(utf8.decode(response.bodyBytes));
    } else {
      throw Exception('Savol yangilanmadi');
    }
  }

  static Future<Map<String, dynamic>> deleteQuestion(
    String token,
    String questionId,
  ) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/api/questions/$questionId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(utf8.decode(response.bodyBytes));
    } else {
      throw Exception('Savol o\'chirilmadi');
    }
  }

  static Future<Map<String, dynamic>> addSingleQuestion(
    String token,
    String categoryId,
    String question,
    List<String> options,
    String correctAnswer, {
    String? imageUrl, // ← YANGI
  }) async {
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
        if (imageUrl != null && imageUrl.isNotEmpty)
          'imageUrl': imageUrl, // ← YANGI
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
      body: jsonEncode({'categoryId': categoryId, 'questions': questions}),
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

  // Foydalanuvchilar
  static Future<Map<String, dynamic>> getUsers(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/users'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(utf8.decode(response.bodyBytes));
    } else {
      throw Exception('Foydalanuvchilar yuklanmadi');
    }
  }

  static Future<Map<String, dynamic>> createUser(
    String token,
    String username,
    String password,
    String role,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/register'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'username': username,
        'password': password,
        'role': role,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(utf8.decode(response.bodyBytes));
    } else {
      throw Exception('Foydalanuvchi yaratilmadi: ${response.body}');
    }
  }

  static Future<Map<String, dynamic>> deleteUser(
    String token,
    String userId,
  ) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/api/users/$userId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(utf8.decode(response.bodyBytes));
    } else {
      throw Exception('Foydalanuvchi o\'chirilmadi');
    }
  }

  // =====================
  // RASMLAR (IMAGES)
  // =====================

  /// Rasm yuklash
  static Future<Map<String, dynamic>> uploadImage(
    String token,
    File imageFile,
  ) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/api/images/upload'),
      );

      // Headers
      request.headers['Authorization'] = 'Bearer $token';

      // Fayl qo'shish
      String fileName = imageFile.path.split('/').last;
      String fileExtension = fileName.split('.').last.toLowerCase();

      // Content type aniqlash
      String contentType = 'image/jpeg';
      if (fileExtension == 'png') {
        contentType = 'image/png';
      } else if (fileExtension == 'gif') {
        contentType = 'image/gif';
      } else if (fileExtension == 'webp') {
        contentType = 'image/webp';
      }

      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          imageFile.path,
          contentType: MediaType.parse(contentType),
        ),
      );

      // Yuborish
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        // URL ni to'liq qilish
        if (data['url'] != null && !data['url'].startsWith('http')) {
          data['url'] = '$baseUrl${data['url']}';
        }
        return data;
      } else {
        throw Exception('Rasm yuklanmadi: ${response.body}');
      }
    } catch (e) {
      throw Exception('Rasm yuklashda xatolik: $e');
    }
  }

  /// Rasmlar ro'yxati
  static Future<List<Map<String, dynamic>>> getImages(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/images'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      final images = List<Map<String, dynamic>>.from(data['images'] ?? []);

      // URL larni to'liq qilish
      for (var image in images) {
        if (image['url'] != null && !image['url'].startsWith('http')) {
          image['url'] = '$baseUrl${image['url']}';
        }
      }

      return images;
    } else {
      throw Exception('Rasmlar yuklanmadi');
    }
  }

  /// Rasm tafsilotlari
  static Future<Map<String, dynamic>> getImageDetail(
    String token,
    String imageId,
  ) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/images/$imageId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      final image = data['image'];

      // URL ni to'liq qilish
      if (image['url'] != null && !image['url'].startsWith('http')) {
        image['url'] = '$baseUrl${image['url']}';
      }

      return image;
    } else {
      throw Exception('Rasm topilmadi');
    }
  }

  /// Rasmni o'chirish
  static Future<Map<String, dynamic>> deleteImage(
    String token,
    String imageId,
  ) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/api/images/$imageId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(utf8.decode(response.bodyBytes));
    } else {
      throw Exception('Rasm o\'chirilmadi');
    }
  }
}
