import 'package:flutter/material.dart';
import 'seat_selection_screen.dart';

class UpgradeOptionsScreen extends StatefulWidget {
  final List<Map<String, dynamic>> passengers;
  final double baggageTotal;

  const UpgradeOptionsScreen({
    super.key,
    required this.passengers,
    required this.baggageTotal,
  });

  @override
  State<UpgradeOptionsScreen> createState() => _UpgradeOptionsScreenState();
}

class _UpgradeOptionsScreenState extends State<UpgradeOptionsScreen> {
  String? selectedOption;

  double get finalTotal {
    double upgradeCost = (selectedOption == "standard") ? 35 : 0;
    return widget.baggageTotal + upgradeCost;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Upgrade bilet"),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Alegeți opțiunea de a modifica sau anula călătoria.",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              "Faceți upgrade la biletul dvs. pentru a putea efectua o nouă rezervare sau obține o rambursare dacă decideți să vă schimbați.",
              style: TextStyle(color: Colors.black87),
            ),
            const SizedBox(height: 20),

            _buildUpgradeOption(
              title: "Saver",
              description: "Fără modificări, fără rambursare",
              price: "0€",
              icon: Icons.savings,
              value: "saver",
            ),

            const SizedBox(height: 12),

            _buildUpgradeOption(
              title: "Standard",
              description: "Modificabil cu taxă, rambursabil parțial",
              price: "35€",
              icon: Icons.upgrade,
              value: "standard",
            ),

            const Spacer(),

            // TOTAL DE PLATĂ
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Center(
                child: Text(
                  "Total de plată: ${finalTotal.toStringAsFixed(2)} €",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
            ),

            // BUTON CONTINUĂ
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: selectedOption != null
                    ? () {
                  final double upgradeTotal = (selectedOption == "standard")
                    ? 35.0 * widget.passengers.length
                    : 0.0;

                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SeatSelectionScreen(
                        numPassengers: widget.passengers.length,
                        passengers: widget.passengers,
                        upgradeTotal: finalTotal,
                      ),
                    ),
                  );
                }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
                child: const Text("Continuă"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpgradeOption({
    required String title,
    required String description,
    required String price,
    required IconData icon,
    required String value,
  }) {
    final isSelected = selectedOption == value;

    return GestureDetector(
      onTap: () => setState(() => selectedOption = value),
      child: Card(
        color: isSelected ? Colors.blue[50] : null,
        shape: RoundedRectangleBorder(
          side: BorderSide(
            color: isSelected ? Colors.blue : Colors.grey.shade300,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: ListTile(
          leading: Icon(icon, size: 36, color: Colors.blue),
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(description),
          trailing: Text(price, style: const TextStyle(fontSize: 16)),
        ),
      ),
    );
  }
}
