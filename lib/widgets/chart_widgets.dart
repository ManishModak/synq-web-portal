import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:synq/theme/app_theme.dart';
import 'package:synq/models/api_models.dart';
import 'package:synq/utils/responsive_utils.dart';

class PointsProgressionChart extends StatefulWidget {
  final PointsData? pointsData;
  final bool isLoading;

  const PointsProgressionChart({
    super.key,
    this.pointsData,
    this.isLoading = false,
  });

  @override
  State<PointsProgressionChart> createState() => _PointsProgressionChartState();
}

class _PointsProgressionChartState extends State<PointsProgressionChart> {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        padding: ResponsiveUtils.getResponsivePadding(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildChartHeader(),
            const SizedBox(height: 20),
            SizedBox(
              height: ResponsiveUtils.isMobile(context) ? 200 : 250,
              child:
                  widget.isLoading ? _buildLoadingState() : _buildLineChart(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.cyanAccent.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.trending_up,
            color: AppTheme.cyanAccent,
            size: 24,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Points Progression',
                style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                'Last 7 days earning trend',
                style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppTheme.cyanAccent),
        ),
      ),
    );
  }

  Widget _buildLineChart() {
    // Generate sample data for demonstration
    final List<FlSpot> spots = _generateSampleData();

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          drawHorizontalLine: true,
          horizontalInterval: 1000,
          verticalInterval: 1,
          getDrawingHorizontalLine: (value) => FlLine(
            color: AppTheme.surfaceDark.withOpacity(0.3),
            strokeWidth: 1,
          ),
          getDrawingVerticalLine: (value) => FlLine(
            color: AppTheme.surfaceDark.withOpacity(0.3),
            strokeWidth: 1,
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: 1,
              getTitlesWidget: (double value, TitleMeta meta) {
                const style = TextStyle(
                  color: AppTheme.textSecondary,
                  fontWeight: FontWeight.w400,
                  fontSize: 12,
                );
                String text = '';
                switch (value.toInt()) {
                  case 1:
                    text = 'Mon';
                    break;
                  case 2:
                    text = 'Tue';
                    break;
                  case 3:
                    text = 'Wed';
                    break;
                  case 4:
                    text = 'Thu';
                    break;
                  case 5:
                    text = 'Fri';
                    break;
                  case 6:
                    text = 'Sat';
                    break;
                  case 7:
                    text = 'Sun';
                    break;
                  default:
                    return Container();
                }
                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  child: Text(text, style: style),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 42,
              interval: 1000,
              getTitlesWidget: (double value, TitleMeta meta) {
                const style = TextStyle(
                  color: AppTheme.textSecondary,
                  fontWeight: FontWeight.w400,
                  fontSize: 12,
                );
                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  child: Text('${(value / 1000).toStringAsFixed(0)}K',
                      style: style),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(
            color: AppTheme.surfaceDark.withOpacity(0.3),
            width: 1,
          ),
        ),
        minX: 1,
        maxX: 7,
        minY: 0,
        maxY: _getMaxY(),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            gradient: LinearGradient(
              colors: [
                AppTheme.cyanAccent.withOpacity(0.8),
                AppTheme.purplePrimary.withOpacity(0.8),
              ],
            ),
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) =>
                  FlDotCirclePainter(
                radius: 4,
                color: AppTheme.cyanAccent,
                strokeWidth: 2,
                strokeColor: AppTheme.surfaceDark,
              ),
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  AppTheme.cyanAccent.withOpacity(0.1),
                  AppTheme.purplePrimary.withOpacity(0.1),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<FlSpot> _generateSampleData() {
    // Mock data for points progression over 7 days (800-1500 range)
    return [
      FlSpot(1, 850), // Monday
      FlSpot(2, 920), // Tuesday
      FlSpot(3, 1150), // Wednesday
      FlSpot(4, 1080), // Thursday
      FlSpot(5, 1280), // Friday
      FlSpot(6, 1350), // Saturday
      FlSpot(7, 1420), // Sunday (current total)
    ];
  }

  double _getMaxY() {
    final spots = _generateSampleData();
    final maxSpot = spots.reduce((a, b) => a.y > b.y ? a : b);
    return maxSpot.y + 1000; // Add some padding
  }
}

class PointsBreakdownChart extends StatefulWidget {
  final PointsData? pointsData;
  final bool isLoading;

  const PointsBreakdownChart({
    super.key,
    this.pointsData,
    this.isLoading = false,
  });

  @override
  State<PointsBreakdownChart> createState() => _PointsBreakdownChartState();
}

class _PointsBreakdownChartState extends State<PointsBreakdownChart> {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        padding: ResponsiveUtils.getResponsivePadding(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildChartHeader(),
            const SizedBox(height: 20),
            SizedBox(
              height: ResponsiveUtils.isMobile(context) ? 200 : 250,
              child: widget.isLoading ? _buildLoadingState() : _buildBarChart(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.purplePrimary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.bar_chart,
            color: AppTheme.purplePrimary,
            size: 24,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Points Breakdown',
                style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                'Daily, Weekly, Monthly earnings',
                style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppTheme.purplePrimary),
        ),
      ),
    );
  }

  Widget _buildBarChart() {
    final dailyPoints = widget.pointsData?.points.daily ?? 245;
    final weeklyPoints = widget.pointsData?.points.weekly ?? 1680;
    final monthlyPoints = widget.pointsData?.points.monthly ?? 7250;

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: monthlyPoints.toDouble() + 1000,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          drawHorizontalLine: true,
          horizontalInterval: 2000,
          getDrawingHorizontalLine: (value) => FlLine(
            color: AppTheme.surfaceDark.withOpacity(0.3),
            strokeWidth: 1,
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (double value, TitleMeta meta) {
                const style = TextStyle(
                  color: AppTheme.textSecondary,
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                );
                String text = '';
                switch (value.toInt()) {
                  case 0:
                    text = 'Daily';
                    break;
                  case 1:
                    text = 'Weekly';
                    break;
                  case 2:
                    text = 'Monthly';
                    break;
                  default:
                    return Container();
                }
                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  child: Text(text, style: style),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 42,
              interval: 2000,
              getTitlesWidget: (double value, TitleMeta meta) {
                const style = TextStyle(
                  color: AppTheme.textSecondary,
                  fontWeight: FontWeight.w400,
                  fontSize: 12,
                );
                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  child: Text('${(value / 1000).toStringAsFixed(0)}K',
                      style: style),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(
            color: AppTheme.surfaceDark.withOpacity(0.3),
            width: 1,
          ),
        ),
        barGroups: [
          BarChartGroupData(
            x: 0,
            barRods: [
              BarChartRodData(
                toY: dailyPoints.toDouble(),
                gradient: LinearGradient(
                  colors: [
                    AppTheme.cyanAccent.withOpacity(0.8),
                    AppTheme.cyanAccent,
                  ],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
                width: 20,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(4)),
              ),
            ],
          ),
          BarChartGroupData(
            x: 1,
            barRods: [
              BarChartRodData(
                toY: weeklyPoints.toDouble(),
                gradient: LinearGradient(
                  colors: [
                    AppTheme.purplePrimary.withOpacity(0.8),
                    AppTheme.purplePrimary,
                  ],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
                width: 20,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(4)),
              ),
            ],
          ),
          BarChartGroupData(
            x: 2,
            barRods: [
              BarChartRodData(
                toY: monthlyPoints.toDouble(),
                gradient: LinearGradient(
                  colors: [
                    AppTheme.warningYellow.withOpacity(0.8),
                    AppTheme.warningYellow,
                  ],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
                width: 20,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(4)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class EarningsDonutChart extends StatefulWidget {
  final PointsData? pointsData;
  final bool isLoading;

  const EarningsDonutChart({
    super.key,
    this.pointsData,
    this.isLoading = false,
  });

  @override
  State<EarningsDonutChart> createState() => _EarningsDonutChartState();
}

class _EarningsDonutChartState extends State<EarningsDonutChart> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        padding: ResponsiveUtils.getResponsivePadding(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildChartHeader(),
            const SizedBox(height: 20),
            SizedBox(
              height: ResponsiveUtils.isMobile(context) ? 200 : 250,
              child:
                  widget.isLoading ? _buildLoadingState() : _buildDonutChart(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.successGreen.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.donut_small,
            color: AppTheme.successGreen,
            size: 24,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Earnings Distribution',
                style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                'Sync vs Wallet points',
                style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppTheme.successGreen),
        ),
      ),
    );
  }

  Widget _buildDonutChart() {
    final syncPoints = widget.pointsData?.syncLifePoints ?? 72158;
    final walletPoints = widget.pointsData?.walletLifePoints ?? 235097;
    final total = syncPoints + walletPoints;

    return Row(
      children: [
        Expanded(
          flex: 3,
          child: PieChart(
            PieChartData(
              pieTouchData: PieTouchData(
                touchCallback: (FlTouchEvent event, pieTouchResponse) {
                  setState(() {
                    if (!event.isInterestedForInteractions ||
                        pieTouchResponse == null ||
                        pieTouchResponse.touchedSection == null) {
                      touchedIndex = -1;
                      return;
                    }
                    touchedIndex =
                        pieTouchResponse.touchedSection!.touchedSectionIndex;
                  });
                },
              ),
              borderData: FlBorderData(show: false),
              sectionsSpace: 2,
              centerSpaceRadius: 40,
              sections: [
                PieChartSectionData(
                  color: AppTheme.cyanAccent,
                  value: syncPoints.toDouble(),
                  title: '${((syncPoints / total) * 100).toStringAsFixed(1)}%',
                  radius: touchedIndex == 0 ? 60 : 50,
                  titleStyle: TextStyle(
                    fontSize: touchedIndex == 0 ? 14 : 12,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                PieChartSectionData(
                  color: AppTheme.purplePrimary,
                  value: walletPoints.toDouble(),
                  title:
                      '${((walletPoints / total) * 100).toStringAsFixed(1)}%',
                  radius: touchedIndex == 1 ? 60 : 50,
                  titleStyle: TextStyle(
                    fontSize: touchedIndex == 1 ? 14 : 12,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLegendItem('Sync Points', syncPoints, AppTheme.cyanAccent),
              const SizedBox(height: 12),
              _buildLegendItem(
                  'Wallet Points', walletPoints, AppTheme.purplePrimary),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLegendItem(String label, int value, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.textSecondary,
                  fontSize: 11,
                ),
              ),
              Text(
                value.toString(),
                style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
