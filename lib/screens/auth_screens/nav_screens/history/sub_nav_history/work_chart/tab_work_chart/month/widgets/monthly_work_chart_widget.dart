// monthly_work_chart_widget.dart
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:daily_manage_user_app/models/work.dart';

class MonthlyWorkChartWidget extends StatelessWidget {
  final List<Work> works;
  final int year;
  final int month;

  const MonthlyWorkChartWidget({
    super.key,
    required this.works,
    required this.year,
    required this.month,
  });

  @override
  Widget build(BuildContext context) {
    final data = _buildChartData();
    final maxY = _getMaxY(data);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        width: data.length * 40 + 40,
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: maxY,
            barTouchData: BarTouchData(
              enabled: true,
              touchTooltipData: BarTouchTooltipData(
                tooltipPadding: const EdgeInsets.all(8),
                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                  final minutes = (rod.toY * 60).round();
                  final h = minutes ~/ 60;
                  final m = minutes % 60;
                  return BarTooltipItem('$h:${m.toString().padLeft(2, '0')}', const TextStyle(color: Colors.white));
                },
              ),
            ),
            titlesData: FlTitlesData(
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, _) {
                    final index = value.toInt();
                    if (index >= 0 && index < data.length) {
                      return Text('${data[index]['day']}');
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: 1,
                  getTitlesWidget: (val, _) => Text('${val.toInt()}h'),
                ),
              ),
              rightTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              topTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
            ),
            gridData: FlGridData(show: true, horizontalInterval: 1),
            borderData: FlBorderData(show: false),
            barGroups: List.generate(data.length, (index) {
              final minutes = data[index]['minutes'] as double;
              return BarChartGroupData(
                x: index,
                barRods: [
                  BarChartRodData(
                    toY: minutes / 60,
                    width: 18,
                    borderRadius: BorderRadius.circular(4),
                    color: Colors.blueAccent,
                  ),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _buildChartData() {
    final daysInMonth = DateUtils.getDaysInMonth(year, month);
    return List.generate(daysInMonth, (i) {
      final day = DateTime(year, month, i + 1);
      final totalSeconds = works.where((w) {
        final d = w.checkInTime.toLocal();
        return d.year == year && d.month == month && d.day == day.day;
      }).fold<int>(0, (sum, w) => sum + w.workTime.inSeconds);

      return {
        'day': i + 1,
        'minutes': (totalSeconds / 60).toDouble(),
      };
    });
  }

  double _getMaxY(List<Map<String, dynamic>> data) {
    final maxMinutes = data.map((e) => e['minutes'] as double).fold(0.0, (a, b) => a > b ? a : b);
    final maxHour = (maxMinutes / 60).ceil();
    return maxHour < 10 ? 10 : maxHour + 1;
  }
}
