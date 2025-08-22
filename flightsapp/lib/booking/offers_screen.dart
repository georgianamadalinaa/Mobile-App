import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'search_results_screen.dart';

class OffersScreen extends StatefulWidget {
  const OffersScreen({super.key});

  @override
  State<OffersScreen> createState() => _OffersScreenState();
}

class _OffersScreenState extends State<OffersScreen> {
  final String selectedDeparture = 'București'; // FIX
  DateTime? selectedDate;
  double maxPrice = 500;
  bool isRoundTrip = false;

  String _formatDate(DateTime? date) {
    return date == null ? 'Selectează data' : DateFormat('dd.MM.yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Zboruri ieftine din România'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            const Text(
              'Explorați ofertele de călătorie ieftine',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            _buildFilterChips(),
            const SizedBox(height: 24),
            _buildOfferCard("assets/images/milano.jpg", "Milano", "Italia", "34 €"),
            _buildOfferCard("assets/images/venetia.jpg", "Veneția", "Italia", "42 €"),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          const SizedBox(width: 8),
          _buildFilterChip(
            label: _formatDate(selectedDate),
            icon: Icons.date_range,
            onTap: () => _pickDate(),
          ),
          _buildFilterChip(
            label: 'Max ${maxPrice.toInt()} €',
            icon: Icons.price_check,
            onTap: () => _showPriceDialog(),
          ),
          _buildFilterChip(
            label: isRoundTrip ? 'Dus-întors' : 'Dus',
            icon: Icons.swap_horiz,
            onTap: () => _showTripTypeDialog(),
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: ActionChip(
        avatar: Icon(icon, size: 18, color: Colors.white),
        label: Text(label),
        labelStyle: const TextStyle(color: Colors.white),
        backgroundColor: Colors.lightBlueAccent,
        onPressed: onTap,
      ),
    );
  }

  Widget _buildOfferCard(String imagePath, String city, String country, String price) {
    return GestureDetector(
      onTap: () {
        if (selectedDate == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Selectează mai întâi o dată de plecare.")),
          );
          return;
        }

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => SearchResultsScreen(
              destination: city,
              departure: selectedDeparture,
              date: DateFormat('yyyy-MM-dd').format(selectedDate!),
              returnDate: isRoundTrip
                  ? DateFormat('yyyy-MM-dd').format(selectedDate!.add(const Duration(days: 3)))
                  : null,
              persons: 1,
              baggage: null,
            ),
          ),
        );
      },
      child: Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(imagePath, height: 160, width: double.infinity, fit: BoxFit.cover),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(city, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Text(country),
                    ],
                  ),
                  Text("Din $price", style: const TextStyle(color: Colors.teal, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() => selectedDate = picked);
    }
  }

  void _showPriceDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Selectează prețul maxim"),
        content: Slider(
          value: maxPrice,
          min: 100,
          max: 1000,
          divisions: 9,
          label: "${maxPrice.toInt()} €",
          onChanged: (value) => setState(() => maxPrice = value),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  void _showTripTypeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Tip zbor"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<bool>(
              title: const Text("Dus"),
              value: false,
              groupValue: isRoundTrip,
              onChanged: (val) {
                setState(() => isRoundTrip = val!);
                Navigator.pop(context);
              },
            ),
            RadioListTile<bool>(
              title: const Text("Dus-întors"),
              value: true,
              groupValue: isRoundTrip,
              onChanged: (val) {
                setState(() => isRoundTrip = val!);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
