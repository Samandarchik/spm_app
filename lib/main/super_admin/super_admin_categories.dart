import 'package:flutter/material.dart';
import 'package:spm_app/main/service/api_service.dart';
import 'package:spm_app/main/service/storage_service.dart';
import 'package:spm_app/main/super_admin/add_category_screen.dart';
import 'package:spm_app/main/super_admin/admin_api_service.dart';
import 'package:spm_app/main/super_admin/questions_screen.dart';
import 'package:spm_app/main/super_admin/statistics_screen.dart';
import 'package:spm_app/main/super_admin/users_screen.dart';
import 'package:spm_app/register.dart';

class CategoriesScreenAdmin extends StatefulWidget {
  const CategoriesScreenAdmin({super.key});

  @override
  State<CategoriesScreenAdmin> createState() => _CategoriesScreenAdminState();
}

class _CategoriesScreenAdminState extends State<CategoriesScreenAdmin> {
  List<dynamic> categories = [];
  bool isLoading = true;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    loadCategories();
  }

  Future<void> loadCategories() async {
    try {
      setState(() => isLoading = true);
      final token = await StorageService.getToken();
      if (token != null) {
        final data = await ApiService.getCategories(token);
        setState(() {
          categories = data['categories'] ?? [];
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Xatolik: $e')));
      }
    }
  }

  Future<void> deleteCategory(String categoryId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('O\'chirish'),
        content: const Text('Bu kategoriyani o\'chirishni xohlaysizmi?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Yo\'q'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Ha'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final token = await StorageService.getToken();
        final response = await ApiServiceAdmin.deleteCategory(
          token!,
          categoryId,
        );
        if (response['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Kategoriya o\'chirildi')),
          );
          loadCategories();
        }
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Xatolik: $e')));
      }
    }
  }

  Future<void> logout() async {
    await StorageService.clearStorage();
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const RegisterUi()),
      );
    }
  }

  Widget _buildCategoriesTab() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator.adaptive());
    }

    if (categories.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.folder_open, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Kategoriya yo\'q',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddCategoryScreen(),
                  ),
                );
                loadCategories();
              },
              icon: const Icon(Icons.add),
              label: const Text('Kategoriya qo\'shish'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: loadCategories,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          return InkWell(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => QuestionsScreen(
                  categoryId: category['id'],
                  categoryName: category['name'],
                ),
              ),
            ),
            onDoubleTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    AddCategoryScreen(category: category, isEdit: true),
              ),
            ).then((_) => loadCategories()),

            onLongPress: () => deleteCategory(category['id']),
            child: Card(
              margin: const EdgeInsets.only(bottom: 12),
              elevation: 2,
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                leading: CircleAvatar(
                  backgroundColor: const Color(0xff130857),
                  child: Text(
                    category['icon'] ?? '📚',
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
                title: Text(
                  category['name'] ?? '',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                subtitle: category['description'].isNotEmpty
                    ? Text(category['description'])
                    : null,
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Super Admin Panel'),
        backgroundColor: const Color(0xff130857),
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.logout), onPressed: logout),
        ],
      ),
      body: _selectedIndex == 0
          ? _buildCategoriesTab()
          : _selectedIndex == 1
          ? const StatisticsScreen()
          : const UsersScreen(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        selectedItemColor: const Color(0xff130857),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.category),
            label: 'Kategoriyalar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Statistika',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Foydalanuvchilar',
          ),
        ],
      ),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton.extended(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddCategoryScreen(),
                  ),
                );
                loadCategories();
              },
              backgroundColor: const Color(0xff130857),
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text(
                'Kategoriya',
                style: TextStyle(color: Colors.white),
              ),
            )
          : null,
    );
  }
}
