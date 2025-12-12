import 'package:flutter/material.dart';
import 'package:spm_app/main/service/storage_service.dart';
import 'package:spm_app/main/super_admin/admin_api_service.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  List<dynamic> statistics = [];
  bool isLoading = true;
  String? selectedCategoryId;

  @override
  void initState() {
    super.initState();
    loadStatistics();
  }

  Future<void> loadStatistics() async {
    try {
      setState(() => isLoading = true);
      final token = await StorageService.getToken();
      if (token != null) {
        final data = await ApiServiceAdmin.getAllStatistics(token);
        setState(() {
          statistics = data['statistics'] ?? [];
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Xatolik: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (statistics.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bar_chart, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Statistika yo\'q',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: loadStatistics,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: statistics.length,
        itemBuilder: (context, index) {
          final categoryStat = statistics[index];
          final categoryName = categoryStat['categoryName'] ?? '';
          final icon = categoryStat['icon'] ?? '📚';
          final userStats = categoryStat['statistics'] as List? ?? [];
          final totalUsers = categoryStat['totalUsers'] ?? 0;

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ExpansionTile(
              leading: CircleAvatar(
                backgroundColor: const Color(0xff130857),
                child: Text(icon, style: const TextStyle(fontSize: 24)),
              ),
              title: Text(
                categoryName,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text('$totalUsers ta foydalanuvchi'),
              children: [
                if (userStats.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'Hali test topshirilmagan',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                else
                  Column(
                    children: [
                      Container(
                        color: Colors.grey[100],
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: Row(
                          children: const [
                            Expanded(
                              flex: 2,
                              child: Text(
                                'Foydalanuvchi',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                'Testlar',
                                style: TextStyle(fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                'O\'rtacha %',
                                style: TextStyle(fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                      ...userStats.map((user) {
                        final username = user['username'] ?? '';
                        final testCount = user['testCount'] ?? 0;
                        final avgPercentage = user['averagePercentage'] ?? 0.0;
                        final totalCorrect = user['totalCorrectAnswers'] ?? 0;
                        final totalQuestions = user['totalQuestions'] ?? 0;

                        Color percentageColor;
                        if (avgPercentage >= 80) {
                          percentageColor = Colors.green;
                        } else if (avgPercentage >= 60) {
                          percentageColor = Colors.orange;
                        } else {
                          percentageColor = Colors.red;
                        }

                        return InkWell(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Text(username),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildDetailRow(
                                      'Kategoriya',
                                      categoryName,
                                    ),
                                    const Divider(),
                                    _buildDetailRow(
                                      'Testlar soni',
                                      '$testCount',
                                    ),
                                    _buildDetailRow(
                                      'Jami savollar',
                                      '$totalQuestions',
                                    ),
                                    _buildDetailRow(
                                      'To\'g\'ri javoblar',
                                      '$totalCorrect',
                                    ),
                                    _buildDetailRow(
                                      'O\'rtacha foiz',
                                      '${avgPercentage.toStringAsFixed(1)}%',
                                      valueColor: percentageColor,
                                    ),
                                  ],
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('Yopish'),
                                  ),
                                ],
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(color: Colors.grey[300]!),
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: Text(username),
                                ),
                                Expanded(
                                  child: Text(
                                    '$testCount',
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    '${avgPercentage.toStringAsFixed(1)}%',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: percentageColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ],
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          Text(
            value,
            style: TextStyle(
              color: valueColor ?? Colors.black,
              fontWeight: valueColor != null ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}