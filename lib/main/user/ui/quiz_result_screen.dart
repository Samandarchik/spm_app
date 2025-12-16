import 'package:flutter/material.dart';
import 'package:spm_app/main/models/category.dart';
import 'package:spm_app/main/service/api_service.dart';
import 'package:spm_app/main/service/storage_service.dart';
import 'package:spm_app/main/user/ui/quiz_screen.dart';

// Quiz Result Screen
class QuizResultScreen extends StatefulWidget {
  final Map<String, dynamic> result;
  final CategoryModel category;

  const QuizResultScreen({
    super.key,
    required this.result,
    required this.category,
  });

  @override
  State<QuizResultScreen> createState() => _QuizResultScreenState();
}

class _QuizResultScreenState extends State<QuizResultScreen> {
  bool isSendRezalt = false;

  Future<void> _sendResult() async {
    try {
      final token = await StorageService.getToken();
      if (token == null) return;

      final resultFromApi = await ApiService.rezalt(token, widget.result);

      setState(() {
        isSendRezalt = resultFromApi;
      });

      if (mounted && resultFromApi) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Natija muvaffaqiyatli yuborildi")),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Xatolik: ${e.toString()}")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
                            '${widget.result['correctAnswers']}/${widget.result['totalQuestions']}',
                            style: const TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const Text(
                            'To\'g\'ri javoblar',
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${widget.result['percentage']}%',
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: InkWell(
                        onTap: isSendRezalt
                            ? () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      "Natija allaqachon yuborilgan",
                                    ),
                                  ),
                                );
                              }
                            : _sendResult,
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: const Color(0xff130857),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            isSendRezalt
                                ? "Natija Yuborildi ✅"
                                : "Natijani Yuborish",
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
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
                          side: const BorderSide(
                            color: Color(0xff130857),
                            width: 2,
                          ),
                        ),
                        child: const Text(
                          'Boshqa mavzu tanlash',
                          style: TextStyle(
                            color: Color(0xff130857),
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: InkWell(
                        onTap: () => Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                QuizScreen(category: widget.category),
                          ),
                        ),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: const Color(0xff130857),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            "Qayta ishlash",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
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
}
