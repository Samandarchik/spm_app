import 'package:flutter/material.dart';
import 'package:spm_app/models/category.dart';
import 'package:spm_app/register.dart';
import 'package:spm_app/service/api_service.dart';
import 'package:spm_app/service/storage_service.dart';
import 'package:spm_app/ui/quiz_screen.dart';

// Categories Screen
class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  List<CategoryModel> _categories = [];
  bool _isLoading = true;
  String? _errorMessage;
  Map<String, dynamic>? _user;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final user = await StorageService.getUser();
    setState(() {
      _user = user;
    });
    await _loadCategories();
  }

  Future<void> _loadCategories() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final token = await StorageService.getToken();
      if (token == null) {
        _navigateToLogin();
        return;
      }

      final response = await ApiService.getCategories(token);
      final categoriesList = response['categories'] as List;

      setState(() {
        _categories = categoriesList
            .map((cat) => CategoryModel.fromJson(cat))
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Kategoriyalar yuklanmadi';
        _isLoading = false;
      });
    }
  }

  void _navigateToLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const RegisterUi()),
    );
  }

  Future<void> _logout() async {
    await StorageService.clearStorage();
    _navigateToLogin();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.yellow,
        title: Text(
          _user != null ? 'Salom, ${_user!['username']}' : 'Quiz Mobile App',
          style: const TextStyle(color: Color(0xff150856)),
        ),
        actions: [
          IconButton(
            onPressed: _logout,
            icon: const Icon(Icons.logout, color: Color(0xff150856)),
            tooltip: 'Chiqish',
          ),
        ],
      ),
      backgroundColor: Colors.yellow,
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator.adaptive(
               
                ),
              )
            : _errorMessage != null
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(_errorMessage!),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loadCategories,
                      child: const Text('Qayta urinish'),
                    ),
                  ],
                ),
              )
            : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Icon(
                      Icons.menu_book,
                      size: 60,
                      color: Color(0xff150856),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Quiz Mobile App',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Color(0xff150856),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Mavzuni tanlang va bilimingizni sinab ko\'ring',
                      style: TextStyle(fontSize: 16, color: Colors.black54),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    Expanded(
                      child: _categories.isEmpty
                          ? const Center(child: Text('Kategoriyalar topilmadi'))
                          : ListView.builder(
                              itemCount: _categories.length,
                              itemBuilder: (context, index) {
                                final category = _categories[index];
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 16.0),
                                  child: Card(
                                    elevation: 4,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: InkWell(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                QuizScreen(category: category),
                                          ),
                                        );
                                      },
                                      borderRadius: BorderRadius.circular(16),
                                      child: Padding(
                                        padding: const EdgeInsets.all(20.0),
                                        child: Row(
                                          children: [
                                            Text(
                                              category.icon,
                                              style: const TextStyle(
                                                fontSize: 48,
                                              ),
                                            ),
                                            const SizedBox(width: 20),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    category.name,
                                                    style: const TextStyle(
                                                      fontSize: 20,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    '${category.questionCount} ta savol',
                                                    style: const TextStyle(
                                                      fontSize: 14,
                                                      color: Colors.black54,
                                                    ),
                                                  ),
                                                  if (category
                                                      .description
                                                      .isNotEmpty)
                                                    Text(
                                                      category.description,
                                                      style: const TextStyle(
                                                        fontSize: 12,
                                                        color: Colors.black45,
                                                      ),
                                                    ),
                                                ],
                                              ),
                                            ),
                                            const Icon(
                                              Icons.chevron_right,
                                              color: Colors.black38,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
