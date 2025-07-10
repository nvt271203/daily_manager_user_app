// monthly_navigator_widget.dart
import 'package:daily_manage_user_app/screens/auth_screens/nav_screens/history/sub_nav_history/work_chart/tab_work_chart/month/widgets/monthly_work_chart_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:daily_manage_user_app/models/work.dart';
import 'package:daily_manage_user_app/providers/work_provider.dart';
import 'package:daily_manage_user_app/widgets/loading_status_bar_widget.dart';
import 'package:daily_manage_user_app/helpers/tools_colors.dart';

class MonthlyNavigatorWidget extends ConsumerStatefulWidget {
  const MonthlyNavigatorWidget({super.key});

  @override
  ConsumerState<MonthlyNavigatorWidget> createState() => _MonthlyNavigatorWidgetState();
}

class _MonthlyNavigatorWidgetState extends ConsumerState<MonthlyNavigatorWidget> {
  late int selectedMonth;
  late int selectedYear;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    selectedMonth = now.month;
    selectedYear = now.year;
    Future.microtask(() => ref.read(workProvider.notifier).fetchWorks());
  }

  void _goToPreviousMonth() {
    setState(() {
      if (selectedMonth == 1) {
        selectedMonth = 12;
        selectedYear--;
      } else {
        selectedMonth--;
      }
    });
  }

  void _goToNextMonth() {
    setState(() {
      if (selectedMonth == 12) {
        selectedMonth = 1;
        selectedYear++;
      } else {
        selectedMonth++;
      }
    });
  }

  void _showMonthPicker() async {
    final now = DateTime.now();
    showDialog(
      context: context,
      builder: (context) {
        int tempMonth = selectedMonth;
        int tempYear = selectedYear;

        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: const Text('Chọn tháng và năm'),
          content: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              DropdownButton<int>(
                value: tempMonth,
                items: List.generate(12, (index) {
                  return DropdownMenuItem(
                    value: index + 1,
                    child: Text('Tháng ${index + 1}'),
                  );
                }),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => tempMonth = value);
                  }
                },
              ),
              const SizedBox(width: 20),
              DropdownButton<int>(
                value: tempYear,
                items: List.generate(10, (index) {
                  final year = now.year - 5 + index;
                  return DropdownMenuItem(
                    value: year,
                    child: Text('$year'),
                  );
                }),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => tempYear = value);
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  selectedMonth = tempMonth;
                  selectedYear = tempYear;
                });
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final allWorksAsync = ref.watch(workProvider);

    return allWorksAsync.when(
      data: (allWorks) {
        final filtered = allWorks.where((w) {
          final d = w.checkInTime.toLocal();
          return d.month == selectedMonth && d.year == selectedYear;
        }).toList();

        return Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildHeader(),
                const SizedBox(height: 16),
                Expanded(
                  child: MonthlyWorkChartWidget(
                    works: filtered,
                    year: selectedYear,
                    month: selectedMonth,
                  ),
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const Scaffold(body: Center(child: LoadingStatusBarWidget())),
      error: (err, stack) => Scaffold(body: Center(child: Text('Lỗi: $err'))),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: _goToPreviousMonth,
        ),
        InkWell(
          onTap: _showMonthPicker,
          child: Column(
            children: [
              const Text('Tháng', style: TextStyle(fontWeight: FontWeight.bold)),
              Text("${selectedMonth.toString().padLeft(2, '0')} / $selectedYear",
                  style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right),
          onPressed: _goToNextMonth,
        ),
      ],
    );
  }
}
