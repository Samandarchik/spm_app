import 'package:flutter/material.dart';
import 'package:spm_app/main/service/storage_service.dart';
import 'package:spm_app/main/super_admin/admin_api_service.dart';

class AddQuestionScreen extends StatefulWidget {
  final String categoryId;
  final String categoryName;
  final Map<String, dynamic>? question;
  final bool isEdit;

  const AddQuestionScreen({
    super.key,
    required this.categoryId,
    required this.categoryName,
    this.question,
    this.isEdit = false,
  });

  @override
  State<AddQuestionScreen> createState() => _AddQuestionScreenState();
}

class _AddQuestionScreenState extends State<AddQuestionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _questionController = TextEditingController();
  final List<TextEditingController> _optionControllers = [
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
  ];
  int _correctAnswerIndex = 0;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.isEdit && widget.question != null) {
      _questionController.text = widget.question!['question'] ?? '';
      final options = List<String>.from(widget.question!['options'] ?? []);
      for (int i = 0; i < options.length && i < 4; i++) {
        _optionControllers[i].text = options[i];
      }
      // final correctAnswer = widget.question!['correctAnswer'];
      // _correctAnswerIndex = options.indexOf(correctAnswer);
      // if (_correctAnswerIndex < 0) _correctAnswerIndex = 0;
    }
  }

  Future<void> saveQuestion() async {
    if (!_formKey.currentState!.validate()) return;

    // Check if all options are filled
    for (var controller in _optionControllers) {
      if (controller.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Barcha variantlarni to\'ldiring')),
        );
        return;
      }
    }

    setState(() => _isLoading = true);

    try {
      final token = await StorageService.getToken();
      if (token != null) {
        final options = _optionControllers.map((c) => c.text.trim()).toList();
        final correctAnswer = options[_correctAnswerIndex];

        if (widget.isEdit) {
          await ApiServiceAdmin.updateQuestion(
            token,
            widget.question!['id'],
            widget.categoryId,
            _questionController.text.trim(),
            options,
            correctAnswer,
          );
          if (mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Savol yangilandi')));
          }
        } else {
          await ApiServiceAdmin.addSingleQuestion(
            token,
            widget.categoryId,
            _questionController.text.trim(),
            options,
            correctAnswer,
          );
          if (mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Savol qo\'shildi')));
          }
        }

        if (mounted) {
          Navigator.pop(context, true);
        }
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
        title: Text(widget.isEdit ? 'Savolni tahrirlash' : 'Yangi savol'),
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
              Text(
                'Kategoriya: ${widget.categoryName}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff130857),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _questionController,
                decoration: const InputDecoration(
                  labelText: 'Savol',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.help_outline),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Savolni kiriting';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              const Text(
                'Javob variantlari',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...List.generate(4, (index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      Radio<int>(
                        value: index,
                        groupValue: _correctAnswerIndex,
                        onChanged: (value) {
                          setState(() => _correctAnswerIndex = value!);
                        },
                        activeColor: const Color(0xff130857),
                      ),
                      Expanded(
                        child: TextFormField(
                          controller: _optionControllers[index],
                          decoration: InputDecoration(
                            labelText: 'Variant ${index + 1}',
                            border: const OutlineInputBorder(),
                            filled: _correctAnswerIndex == index,
                            fillColor: _correctAnswerIndex == index
                                ? const Color(0xff130857).withOpacity(0.1)
                                : null,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'To\'ldiring';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: Colors.blue,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'To\'g\'ri javobni belgilash uchun radio tugmasini bosing',
                        style: TextStyle(color: Colors.blue[800], fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : saveQuestion,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff130857),
                    foregroundColor: Colors.white,
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          widget.isEdit ? 'Yangilash' : 'Saqlash',
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
    _questionController.dispose();
    for (var controller in _optionControllers) {
      controller.dispose();
    }
    super.dispose();
  }
}
