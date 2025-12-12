import 'package:flutter/material.dart';
import 'package:spm_app/main/models/category.dart';
import 'package:spm_app/main/models/question.dart';
import 'package:spm_app/register.dart';
import 'package:spm_app/main/service/api_service.dart';
import 'package:spm_app/main/service/storage_service.dart';

// Quiz Screen
class QuizScreen extends StatefulWidget {
  final CategoryModel category;

  const QuizScreen({super.key, required this.category});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  List<Question> _questions = [];
  Map<String, String> _userAnswers = {}; // questionId -> answer
  int _currentQuestion = 0;
  bool _isLoading = true;
  String? _errorMessage;
  int _startTime = 0;
  bool _showResult = false;
  Map<String, dynamic>? result;
  bool isSendRezalt = false;
  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now().millisecondsSinceEpoch;
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    try {
      final token = await StorageService.getToken();
      if (token == null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const RegisterUi()),
        );
        return;
      }

      final response = await ApiService.getQuestions(token, widget.category.id);
      final questionsList = response['questions'] as List;

      setState(() {
        _questions = questionsList.map((q) => Question.fromJson(q)).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  void _handleAnswer(int index) {
    final question = _questions[_currentQuestion];
    final answer = question.options[index];

    setState(() {
      _userAnswers[question.id] = answer;
    });

    Future.delayed(const Duration(milliseconds: 400), () {
      if (_currentQuestion < _questions.length - 1) {
        setState(() {
          _currentQuestion++;
        });
      } else {
        _submitAnswers();
      }
    });
  }

  Future<void> _submitAnswers() async {
    final timeSpent =
        ((DateTime.now().millisecondsSinceEpoch - _startTime) / 1000).round();

    final answers = _userAnswers.entries.map((entry) {
      return {'questionId': entry.key, 'answer': entry.value};
    }).toList();

    try {
      final token = await StorageService.getToken();
      if (token == null) return;

      final response = await ApiService.submitAnswers(
        token,
        widget.category.id,
        answers,
        timeSpent,
      );

      setState(() {
        result = response['result'];
        _showResult = true;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Xatolik: ${e.toString()}')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: const Center(child: CircularProgressIndicator.adaptive()),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(
          iconTheme: const IconThemeData(color: Color(0xff130857)),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 80, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff130857),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Orqaga qaytish'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (_showResult && result != null) {
      return Scaffold(
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.emoji_events,
                        size: 80,
                        color: Color(0xff130857),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Test yakunlandi!',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xff130857),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.category.name,
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 32),
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: const Color(0xff130857),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            Text(
                              '${result!['correctAnswers']}/${result!['totalQuestions']}',
                              style: const TextStyle(
                                fontSize: 48,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const Text(
                              'To\'g\'ri javoblar',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${result!['percentage']}%',
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: InkWell(
                          onTap: isSendRezalt
                              ? () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text("Natija Yuborilgan"),
                                    ),
                                  );
                                }
                              : () async {
                                  final token = await StorageService.getToken();

                                  final resultFromApi = await ApiService.rezalt(
                                    token!,
                                    result!,
                                  );

                                  setState(() {
                                    isSendRezalt = resultFromApi;
                                    print(resultFromApi);
                                  });
                                },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: const Color(0xff130857),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: isSendRezalt
                                ? Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Text(
                                        "Natija Yuborildi. ✅",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  )
                                : const Text(
                                    'Natijani Yuborish',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Boshqa mavzu tanlash',
                            style: TextStyle(
                              color: Color(0xff130857),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    final question = _questions[_currentQuestion];
    final progress = (_currentQuestion + 1) / _questions.length;
    final hasAnswered = _userAnswers.containsKey(question.id);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xff130857)),
        title: Text(
          widget.category.name,
          style: const TextStyle(
            color: Color(0xff130857),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Savol ${_currentQuestion + 1}/${_questions.length}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xff130857),
                          ),
                        ),
                        Text(
                          'Javoblar: ${_userAnswers.length}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xff130857),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 8,
                        backgroundColor: Colors.grey[200],
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xff130857),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      question.question,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        height: 1.4,
                        color: Color(0xff130857),
                      ),
                    ),
                    const SizedBox(height: 32),
                    ...List.generate(question.options.length, (index) {
                      final option = question.options[index];
                      final isSelected =
                          hasAnswered && _userAnswers[question.id] == option;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: InkWell(
                          onTap: hasAnswered
                              ? null
                              : () => _handleAnswer(index),
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.blue[100]
                                  : Colors.grey[50],
                              border: Border.all(
                                color: isSelected
                                    ? Colors.blue
                                    : Colors.grey[300]!,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    option,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xff130857),
                                    ),
                                  ),
                                ),
                                if (isSelected)
                                  const Icon(
                                    Icons.check_circle,
                                    color: Colors.blue,
                                    size: 28,
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
