// price_calendar_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:math';


class PriceCalendarScreen extends StatelessWidget {
  final String baseDate; // format: yyyy-MM-dd

  const PriceCalendarScreen({super.key, required this.baseDate});

  @override
  Widget build(BuildContext context) {
    final startDate = DateTime.parse(baseDate);
    final random = Random();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar prețuri'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: ListView.builder(
        itemCount: 15,
        itemBuilder: (context, index) {
          final date = startDate.add(Duration(days: index));
          final price = 50 + random.nextInt(150);

          return ListTile(
            leading: const Icon(Icons.calendar_today),
            title: Text(DateFormat('EEEE, dd MMM yyyy', 'ro').format(date)),
            trailing: Text('€$price', style: const TextStyle(fontWeight: FontWeight.bold)),
          );
        },
      ),
    );
  }
}
