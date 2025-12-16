import 'package:flutter/material.dart';
import 'package:spm_app/main/service/storage_service.dart';
import 'package:spm_app/main/super_admin/admin_api_service.dart';

class AddCategoryScreen extends StatefulWidget {
  final Map<String, dynamic>? category;
  final bool isEdit;

  const AddCategoryScreen({super.key, this.category, this.isEdit = false});

  @override
  State<AddCategoryScreen> createState() => _AddCategoryScreenState();
}

class _AddCategoryScreenState extends State<AddCategoryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _iconController = TextEditingController();
  String _selectedIcon = '📚';
  bool _useTextField = false;
  List<String> _availableRoles = [];
  List<String> _selectedRoles = [];
  bool _isLoading = false;

  final List<String> _icons = [
    '📚',
    '📖',
    '✏️',
    '🎓',
    '🧮',
    '🔬',
    '🌍',
    '💻',
    '🎨',
    '🎵',
    '⚽',
    '🏃',
    '🍕',
    '🚗',
    '✈️',
    '🏠',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.isEdit && widget.category != null) {
      _nameController.text = widget.category!['name'] ?? '';
      _descriptionController.text = widget.category!['description'] ?? '';
      _selectedIcon = widget.category!['icon'] ?? '📚';
      _iconController.text = _selectedIcon;
      _selectedRoles = List<String>.from(
        widget.category!['allowedRoles'] ?? [],
      );
    }
    loadRoles();
  }

  Future<void> loadRoles() async {
    try {
      final token = await StorageService.getToken();
      if (token != null) {
        final roles = await ApiServiceAdmin.getRoles(token);
        setState(() {
          _availableRoles = roles;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Rollar yuklanmadi: $e')));
      }
    }
  }

  Future<void> saveCategory() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedRoles.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Kamida bitta rol tanlang')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final token = await StorageService.getToken();
      if (token != null) {
        final iconToUse = _useTextField ? _iconController.text : _selectedIcon;

        if (widget.isEdit) {
          await ApiServiceAdmin.updateCategory(
            token,
            widget.category!['id'],
            _nameController.text,
            _descriptionController.text,
            iconToUse,
            _selectedRoles,
          );
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Kategoriya yangilandi')),
            );
          }
        } else {
          await ApiServiceAdmin.createCategory(
            token,
            _nameController.text,
            _descriptionController.text,
            iconToUse,
            _selectedRoles,
          );
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Kategoriya yaratildi')),
            );
          }
        }
        if (mounted) Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Xatolik: $e')));
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isEdit ? 'Kategoriyani tahrirlash' : 'Yangi kategoriya',
        ),
        backgroundColor: const Color(0xff130857),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Kategoriya nomi',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.title),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nomini kiriting';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Ta\'rif (ixtiyoriy)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              const Text(
                'Icon tanlang',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          _useTextField = false;
                          _iconController.clear();
                        });
                      },
                      icon: const Icon(Icons.grid_view),
                      label: const Text('Ro\'yxatdan'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: !_useTextField
                            ? const Color(0xff130857)
                            : Colors.grey[300],
                        foregroundColor: !_useTextField
                            ? Colors.white
                            : Colors.black87,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          _useTextField = true;
                          _iconController.text = _selectedIcon;
                        });
                      },
                      icon: const Icon(Icons.edit),
                      label: const Text('Qo\'lda kiritish'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _useTextField
                            ? const Color(0xff130857)
                            : Colors.grey[300],
                        foregroundColor: _useTextField
                            ? Colors.white
                            : Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (!_useTextField)
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _icons.map((icon) {
                    final isSelected = icon == _selectedIcon;
                    return InkWell(
                      onTap: () => setState(() => _selectedIcon = icon),
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xff130857)
                              : Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xff130857)
                                : Colors.grey[300]!,
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            icon,
                            style: const TextStyle(fontSize: 24),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                )
              else
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _iconController,
                        decoration: const InputDecoration(
                          labelText: 'Icon (emoji)',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.emoji_emotions),
                          hintText: 'Masalan: 🎯, 📱, 💡',
                        ),
                        style: const TextStyle(fontSize: 24),
                        maxLength: 2,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Icon kiriting';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[400]!, width: 2),
                      ),
                      child: Center(
                        child: Text(
                          _iconController.text.isEmpty
                              ? '?'
                              : _iconController.text,
                          style: const TextStyle(fontSize: 28),
                        ),
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 24),
              const Text(
                'Ruxsat berilgan rollar',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              if (_availableRoles.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator()),
                )
              else
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _availableRoles.map((role) {
                    final isSelected = _selectedRoles.contains(role);
                    return FilterChip(
                      label: Text(role),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _selectedRoles.add(role);
                          } else {
                            _selectedRoles.remove(role);
                          }
                        });
                      },
                      selectedColor: const Color(0xff130857).withOpacity(0.2),
                      checkmarkColor: const Color(0xff130857),
                    );
                  }).toList(),
                ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : saveCategory,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff130857),
                    foregroundColor: Colors.white,
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          widget.isEdit ? 'Yangilash' : 'Yaratish',
                          style: const TextStyle(fontSize: 16),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _iconController.dispose();
    super.dispose();
  }
}
