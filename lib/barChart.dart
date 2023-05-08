import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MonthlyIncomeExpenseChart extends StatelessWidget {
  final List<double> incomeExpense;

  MonthlyIncomeExpenseChart({required this.incomeExpense});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: incomeExpense.reduce((a, b) => a > b ? a : b),
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              tooltipBgColor: Colors.grey[800],
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                return BarTooltipItem(
                  (rod.y).toStringAsFixed(0) + ' ฿',
                  TextStyle(color: Colors.white),
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: SideTitles(
              showTitles: true,
              getTextStyles: (context, value) => TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
              margin: 16,
              getTitles: (double value) {
                return DateFormat.MMMM().format(
                  DateTime(DateTime.now().year, value.toInt() + 1),
                );
              },
            ),
            leftTitles: SideTitles(showTitles: false),
          ),
          borderData: FlBorderData(show: false),
          barGroups: incomeExpense.asMap().entries.map((entry) {
            return BarChartGroupData(
              x: entry.key,
              barRods: [
                BarChartRodData(
                  y: entry.value,
                  colors: entry.value >= 0
                      ? [Colors.green, Colors.lightGreen]
                      : [Colors.red, Colors.orange],
                  width: 14,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(6),
                    topRight: Radius.circular(6),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}
