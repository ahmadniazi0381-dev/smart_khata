import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/money.dart';
import '../../domain/models/report_models.dart';

class SalesTrendChart extends StatelessWidget {
  final List<DailySalesPoint> points;
  final double height;

  const SalesTrendChart({
    required this.points,
    this.height = 180,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) {
      return SizedBox(
        height: height,
        child: const Center(child: Text('No data')),
      );
    }

    final maxValPaisa = points.fold<int>(
      0,
      (max, p) => p.totalPaisa > max ? p.totalPaisa : max,
    );

    final maxY = maxValPaisa > 0 ? (maxValPaisa / 100) * 1.2 : 1000.0;

    return SizedBox(
      height: height,
      child: BarChart(
        BarChartData(
          maxY: maxY,
          alignment: BarChartAlignment.spaceAround,
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 || index >= points.length) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      points[index].dateLabel,
                      style: TextStyle(
                        fontSize: 10,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                final point = points[groupIndex];
                return BarTooltipItem(
                  '${point.dateLabel}\n${Money.format(point.totalPaisa)}',
                  const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                );
              },
            ),
          ),
          barGroups: List.generate(points.length, (i) {
            final p = points[i];
            final amountRupees = p.totalPaisa / 100;
            return BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: amountRupees,
                  color:
                      p.totalPaisa > 0 ? AppColors.primary : AppColors.divider,
                  width: points.length > 10 ? 8 : 14,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(4),
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}
