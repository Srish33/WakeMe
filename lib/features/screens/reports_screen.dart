import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/analytics_provider.dart';
import 'package:intl/intl.dart';

// Provides technical data visualization of alarm performance, mood trends, and journal engagement.
class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryAccent = theme.colorScheme.primary;
    const Color surfaceColor = Color(0xFF1E1E2A); // Card background color

    return Scaffold(
      backgroundColor: const Color(0xFF12121A),
      appBar: AppBar(
        title: const Text('REPORTS'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Consumer<AnalyticsProvider>(
        builder: (context, provider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. ALARM ANALYTICS: Wake-Up Trends & Snooze Tracking
                _buildSectionHeader('Alarm Analytics'),
                const SizedBox(height: 16),
                _buildChartContainer(
                  'Wake-Up Trend',
                  _buildWakeUpTrendChart(provider, primaryAccent, surfaceColor),
                  surfaceColor,
                ),
                const SizedBox(height: 12),
                _buildWakeUpInsights(provider, primaryAccent, surfaceColor),
                const SizedBox(height: 20),
                _buildSnoozeTrackerCard(provider, primaryAccent, surfaceColor),
                
                const SizedBox(height: 32),
                _buildMoodOfTheMonthCard(provider, primaryAccent, surfaceColor),
                const SizedBox(height: 40),

                // 2. MOOD ANALYTICS: Visual trend chart and emoji breakdown
                _buildSectionHeader('Mood Analytics'),
                const SizedBox(height: 16),
                _buildChartContainer(
                  'Mood Trend',
                  _buildMoodTrendChart(provider, primaryAccent, surfaceColor),
                  surfaceColor,
                ),
                const SizedBox(height: 20),
                _buildMoodDistribution(provider, primaryAccent, surfaceColor),

                const SizedBox(height: 40),

                // 3. JOURNAL ANALYTICS: Volume and engagement metrics
                _buildSectionHeader('Journal Analytics'),
                const SizedBox(height: 16),
                _buildJournalRow(provider, primaryAccent, surfaceColor),
                
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title.toUpperCase(),
      style: const TextStyle(
        color: Colors.white,
        fontSize: 13,
        fontWeight: FontWeight.w800,
        letterSpacing: 2,
      ),
    );
  }

  Widget _buildWakeUpInsights(AnalyticsProvider provider, Color primaryAccent, Color surfaceColor) {
    if (provider.alarmAnalytics.isEmpty) return const SizedBox.shrink();
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: surfaceColor.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome, color: primaryAccent, size: 14),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  "Your average wake-up time is ${provider.averageWakeUpTimeStr}",
                  style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            "You usually wake up between ${provider.wakeUpWindowStr}",
            style: const TextStyle(color: Colors.white54, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildSnoozeTrackerCard(AnalyticsProvider provider, Color primaryAccent, Color surfaceColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: primaryAccent.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.snooze_rounded, color: primaryAccent, size: 24),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Snooze Tracker", style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    provider.totalSnoozes.toString(), 
                    style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)
                  ),
                  const SizedBox(width: 4),
                  const Text("total", style: TextStyle(color: Colors.white38, fontSize: 12)),
                  const SizedBox(width: 12),
                  Text(
                    provider.averageSnoozes.toStringAsFixed(1), 
                    style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)
                  ),
                  const SizedBox(width: 4),
                  const Text("avg/day", style: TextStyle(color: Colors.white38, fontSize: 12)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMoodOfTheMonthCard(AnalyticsProvider provider, Color primaryAccent, Color surfaceColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Text(provider.moodOfTheMonth, style: const TextStyle(fontSize: 40)),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Mood of the Month", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              Text(
                DateFormat('MMMM yyyy').format(DateTime.now()).toUpperCase(),
                style: TextStyle(color: primaryAccent, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildJournalRow(AnalyticsProvider provider, Color primaryAccent, Color surfaceColor) {
    return Row(
      children: [
        Expanded(
          child: _buildMetricCard(
            'Total Entries', 
            provider.totalJournalEntries.toString(), 
            Icons.auto_stories_rounded,
            primaryAccent,
            surfaceColor,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildMetricCard(
            'Current Streak', 
            '${provider.currentStreak} ${provider.currentStreak == 1 ? 'day' : 'days'}', 
            Icons.local_fire_department_rounded,
            primaryAccent,
            surfaceColor,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color primaryAccent, Color surfaceColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(icon, color: primaryAccent, size: 16),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  title, 
                  style: const TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.w500),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value, 
            style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: -0.5),
          ),
        ],
      ),
    );
  }

  Widget _buildChartContainer(String title, Widget chart, Color surfaceColor) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title, 
            style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)
          ),
          const SizedBox(height: 24),
          SizedBox(height: 180, child: chart),
        ],
      ),
    );
  }

  Widget _buildWakeUpTrendChart(AnalyticsProvider provider, Color primaryAccent, Color surfaceColor) {
    final data = provider.last7DaysWakeUps;
    if (data.isEmpty) return _buildEmptyState();

    // Map time to inverted Y-axis (Mornings at the TOP)
    // We'll map minutes from start of day to a negative value or simply invert the mapping.
    // 1440 minutes in a day. 
    // If we want 06:00 (360) at top and 10:00 (600) at bottom:
    // We can use 1440 - actualMinutes as the Y value.
    
    final spots = data.asMap().entries.map((e) {
      final time = e.value.actualWakeUpTime;
      final mins = (time.hour * 60) + time.minute;
      // Invert: higher minutes (later time) will have lower Y value
      return FlSpot(e.key.toDouble(), (1440 - mins).toDouble());
    }).toList();

    final yValues = spots.map((s) => s.y).toList();
    double minY = yValues.reduce((a, b) => a < b ? a : b) - 30;
    double maxY = yValues.reduce((a, b) => a > b ? a : b) + 30;

    return LineChart(
      LineChartData(
        minY: minY, 
        maxY: maxY,
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (spot) => surfaceColor,
            getTooltipItems: (spots) {
              return spots.map((spot) {
                final date = DateFormat('MMM d').format(data[spot.spotIndex].date);
                final time = DateFormat('h:mm a').format(data[spot.spotIndex].actualWakeUpTime);
                return LineTooltipItem(
                  '$date\n$time',
                  TextStyle(color: primaryAccent, fontWeight: FontWeight.bold),
                );
              }).toList();
            },
          ),
        ),
        gridData: const FlGridData(show: false),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: (maxY - minY) / 3 > 0 ? (maxY - minY) / 3 : 30,
              getTitlesWidget: (value, meta) {
                // Convert back from inverted Y
                int actualMins = 1440 - value.toInt();
                int hour = (actualMins ~/ 60) % 24;
                int minute = actualMins % 60;
                
                String period = hour >= 12 ? "PM" : "AM";
                int h = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
                
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Text(
                    "$h:${minute.toString().padLeft(2, '0')} $period",
                    style: const TextStyle(color: Colors.white24, fontSize: 10),
                  ),
                );
              },
              reservedSize: 60,
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            curveSmoothness: 0.35,
            color: primaryAccent,
            barWidth: 4,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  primaryAccent.withValues(alpha: 0.2),
                  primaryAccent.withValues(alpha: 0.0),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoodTrendChart(AnalyticsProvider provider, Color primaryAccent, Color surfaceColor) {
    final data = provider.last7DaysMoods;
    if (data.isEmpty) return _buildEmptyState();

    return LineChart(
      LineChartData(
        minY: 1,
        maxY: 5,
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (spot) => surfaceColor,
            getTooltipItems: (spots) {
              return spots.map((spot) {
                final date = DateFormat('MMM d').format(data[spot.spotIndex].createdAt);
                return LineTooltipItem(
                  '$date\n${data[spot.spotIndex].mood}',
                  TextStyle(color: primaryAccent, fontWeight: FontWeight.bold),
                );
              }).toList();
            },
          ),
        ),
        gridData: const FlGridData(show: false),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1,
              getTitlesWidget: (value, meta) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Text(
                    provider.getMoodFromScore(value.toInt()),
                    style: const TextStyle(fontSize: 14),
                  ),
                );
              },
              reservedSize: 32,
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: data.asMap().entries.map((e) => FlSpot(e.key.toDouble(), provider.getMoodScore(e.value.mood).toDouble())).toList(),
            isCurved: true,
            curveSmoothness: 0.35,
            color: primaryAccent,
            barWidth: 4,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  primaryAccent.withValues(alpha: 0.2),
                  primaryAccent.withValues(alpha: 0.0),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoodDistribution(AnalyticsProvider provider, Color primaryAccent, Color surfaceColor) {
    final dist = provider.moodDistribution;
    if (dist.isEmpty) return const SizedBox();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Mood Distribution', 
                style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)
              ),
              Text(
                'BEST: ${provider.bestMood}', 
                style: TextStyle(color: primaryAccent, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1),
              ),
            ],
          ),
          const SizedBox(height: 24),
          ...dist.entries.map((e) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(e.key, style: const TextStyle(fontSize: 18)),
                    Text('${e.value.toStringAsFixed(0)}%', style: const TextStyle(color: Colors.white38, fontSize: 11, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child: LinearProgressIndicator(
                    value: e.value / 100,
                    backgroundColor: Colors.white.withValues(alpha: 0.03),
                    valueColor: AlwaysStoppedAnimation<Color>(primaryAccent),
                    minHeight: 6,
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Text(
        'not enough data', 
        style: TextStyle(color: Colors.white24, fontSize: 13, letterSpacing: 1)
      ),
    );
  }
}
