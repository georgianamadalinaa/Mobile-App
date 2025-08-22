// admin_statistics_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:collection';

class AdminStatisticsScreen extends StatefulWidget {
  const AdminStatisticsScreen({super.key});

  @override
  State<AdminStatisticsScreen> createState() => _AdminStatisticsScreenState();
}

class _AdminStatisticsScreenState extends State<AdminStatisticsScreen> {
  int totalBookings = 0;
  double totalRevenue = 0;
  Map<String, int> bookingsPerDestination = {};
  List<MapEntry<String, int>> topDestinations = [];
  Map<String, int> bookingsLast7Days = {};
  Map<String, double> paymentsLast6Months = {};

  @override
  void initState() {
    super.initState();
    fetchStatistics();
  }

  Future<void> fetchStatistics() async {
    final bookingsSnapshot = await FirebaseFirestore.instance.collection('bookings').get();
    final paymentsSnapshot = await FirebaseFirestore.instance.collection('payments').get();

    int bookingsCount = 0;
    double revenue = 0;
    Map<String, int> destinationMap = {};
    Map<String, int> dayMap = {};
    Map<String, double> monthMap = {};

    for (var doc in bookingsSnapshot.docs) {

      final data = doc.data();
      final status = (data['status'] ?? '').toLowerCase();
      if (status == 'anulată' || status == 'cancelled') continue;
      bookingsCount++;
      final dest = data['destination'] ?? 'necunoscut';
      final price = (data['price'] ?? 0).toDouble();
      final timestamp = (data['timestamp'] as Timestamp?)?.toDate();
      revenue += price;

      destinationMap[dest] = (destinationMap[dest] ?? 0) + 1;

      if (timestamp != null) {
        final day = timestamp.weekday.toString();
        dayMap[day] = (dayMap[day] ?? 0) + 1;
      }
    }

    for (var doc in paymentsSnapshot.docs) {
      final data = doc.data();
      final amount = (data['amount'] ?? 0).toDouble();
      final timestamp = (data['timestamp'] as Timestamp?)?.toDate();

      if (timestamp != null) {
        final month = '${timestamp.month.toString().padLeft(2, '0')}/${timestamp.year}';
        monthMap[month] = (monthMap[month] ?? 0) + amount;
      }
    }

    final top3 = destinationMap.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    setState(() {
      totalBookings = bookingsCount;
      totalRevenue = revenue;
      bookingsPerDestination = destinationMap;
      topDestinations = top3.take(3).toList();
      bookingsLast7Days = dayMap;
      paymentsLast6Months = monthMap;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Statistici platformă")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatCard("Total rezervări", "$totalBookings", Icons.book_online),
            _buildStatCard("Venit total", "€${totalRevenue.toStringAsFixed(2)}", Icons.attach_money),
            const SizedBox(height: 20),
            const Text("Rezervări per destinație", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 250, child: _buildBarChart(bookingsPerDestination)),
            const SizedBox(height: 20),
            const Text("Top 3 destinații populare", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ...topDestinations.map((e) => ListTile(
              leading: const Icon(Icons.location_on, color: Colors.redAccent),
              title: Text(e.key),
              trailing: Text("${e.value} rezervări"),
            )),
            const SizedBox(height: 30),
            const Text("Grafic rezervări pe zile", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 250, child: _buildLineChart(bookingsLast7Days)),
            const SizedBox(height: 30),
            const Text("Grafic plăți pe luni", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 250, child: _buildBarChart(paymentsLast6Months.map((k, v) => MapEntry(k, v.toInt())))),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        leading: Icon(icon, size: 36, color: Colors.blueAccent),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(value, style: const TextStyle(fontSize: 20)),
      ),
    );
  }

  Widget _buildBarChart(Map<String, int> dataMap) {
    final keys = dataMap.keys.toList();
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        barGroups: List.generate(dataMap.length, (i) {
          return BarChartGroupData(x: i, barRods: [
            BarChartRodData(toY: dataMap[keys[i]]!.toDouble(), color: Colors.blueAccent)
          ]);
        }),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: true, getTitlesWidget: (value, meta) {
              final i = value.toInt();
              if (i >= 0 && i < keys.length) {
                return Text(keys[i], style: const TextStyle(fontSize: 10));
              }
              return const Text('');
            }),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: true, reservedSize: 28),
          ),
        ),
        borderData: FlBorderData(show: false),
      ),
    );
  }

  Widget _buildLineChart(Map<String, int> dataMap) {
    final keys = dataMap.keys.toList();
    return LineChart(
      LineChartData(
        lineBarsData: [
          LineChartBarData(
            isCurved: true,
            spots: List.generate(dataMap.length, (i) {
              return FlSpot(i.toDouble(), dataMap[keys[i]]!.toDouble());
            }),
            dotData: FlDotData(show: true),
            color: Colors.green,
          ),
        ],
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: true, getTitlesWidget: (value, meta) {
              final i = value.toInt();
              if (i >= 0 && i < keys.length) {
                return Text(keys[i], style: const TextStyle(fontSize: 10));
              }
              return const Text('');
            }),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: true, reservedSize: 28),
          ),
        ),
        borderData: FlBorderData(show: false),
      ),
    );
  }
}
