// admin_dashboard_screen.dart
import 'package:flutter/material.dart';
import 'admin_flights_screen.dart';
import 'admin_bookings_screen.dart';
import 'admin_users_screen.dart';
import 'admin_add_flights_screen.dart';
import 'admin_payment_screen.dart';
import 'admin_statistics_screen.dart'; // 👈 Asigură-te că ai acest fișier

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Admin Dashboard")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildTile(context, "Zboruri disponibile", Icons.flight_takeoff, const AdminFlightsScreen()),
          _buildTile(context, "Rezervări efectuate", Icons.book_online, const AdminBookingsScreen()),
          _buildTile(context, "Utilizatori înregistrați", Icons.people, const AdminUsersScreen()),
          _buildTile(context, "Adaugă zbor manual", Icons.add_circle, const AdminAddFlightScreen()),
          _buildTile(context, "Vezi plățile", Icons.attach_money, const AdminPaymentsScreen()),
          _buildTile(context, "Statistici", Icons.bar_chart, const AdminStatisticsScreen()), // 👈 Adăugat aici
        ],
      ),
    );
  }

  Widget _buildTile(BuildContext context, String title, IconData icon, Widget screen) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: Colors.blueAccent),
        title: Text(title),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => screen)),
      ),
    );
  }
}
