import 'package:flutter/material.dart';
import 'upgrade_screen.dart';
import '../models/booking_data.dart';
import '../models/booking.dart';

class BaggageSelectionScreen extends StatefulWidget {
  final List<Map<String, dynamic>> passengers;
  final Map<String, dynamic> flight;
  final String? baggage;
  final double basePrice;

  const BaggageSelectionScreen({
    super.key,
    required this.passengers,
    required this.flight,
    this.baggage,
    required this.basePrice,
  });

  @override
  State<BaggageSelectionScreen> createState() => _BaggageSelectionScreenState();
}

class _BaggageSelectionScreenState extends State<BaggageSelectionScreen> {
  int overheadBags = 0;
  int checkedBags10kg = 0;
  int checkedBags20kg = 0;

  double get totalPrice {
    double baggageTotal = (overheadBags * 20) + (checkedBags10kg * 35) + (checkedBags20kg * 50);
    return widget.basePrice + baggageTotal;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Selectați bagajele"),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Selectați bagajul dvs.",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Adăugarea bagajului după efectuarea rezervării este mai scumpă. "
                          "Așadar, adăugați-l acum și puneți deoparte niște bani în plus pentru distracții în călătoria dvs.",
                      style: TextStyle(color: Colors.black87),
                    ),
                    const SizedBox(height: 20),

                    Card(
                      color: Colors.green[50],
                      child: const ListTile(
                        leading: Icon(Icons.backpack, size: 36, color: Colors.green),
                        title: Text("Bagaj de mână (inclus)"),
                        subtitle: Text("Trebuie să încapă sub scaunul din fața dvs.\n10kg, 20x30x40cm"),
                        trailing: Text("Inclus"),
                      ),
                    ),

                    const SizedBox(height: 12),

                    _buildBaggageOption(
                      title: "Bagaj de mână (suplimentar)",
                      description: "23x40x55cm – depozitat în compartimentul de deasupra capului",
                      price: 20,
                      quantity: overheadBags,
                      onAdd: () => setState(() => overheadBags++),
                      onRemove: () => setState(() {
                        if (overheadBags > 0) overheadBags--;
                      }),
                    ),

                    _buildBaggageOption(
                      title: "Bagaj de cală (10kg)",
                      description: "Bagaj mic de cală – 10kg",
                      price: 35,
                      quantity: checkedBags10kg,
                      onAdd: () => setState(() => checkedBags10kg++),
                      onRemove: () => setState(() {
                        if (checkedBags10kg > 0) checkedBags10kg--;
                      }),
                    ),

                    _buildBaggageOption(
                      title: "Bagaj de cală (20kg)",
                      description: "Bagaj mare de cală – 20kg",
                      price: 50,
                      quantity: checkedBags20kg,
                      onAdd: () => setState(() => checkedBags20kg++),
                      onRemove: () => setState(() {
                        if (checkedBags20kg > 0) checkedBags20kg--;
                      }),
                    ),

                    const SizedBox(height: 20),

                    Center(
                      child: Text(
                        "Total de plată: ${totalPrice.toStringAsFixed(2)} €",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (BookingData.currentBooking != null) {
                    final hasAnyExtraBaggage = overheadBags > 0 || checkedBags10kg > 0 || checkedBags20kg > 0;
                    BookingData.currentBooking!.hasBaggage = hasAnyExtraBaggage;
                  }

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => UpgradeOptionsScreen(
                        passengers: widget.passengers,
                        baggageTotal: totalPrice,
                      ),
                    ),
                  );
                },
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

  Widget _buildBaggageOption({
    required String title,
    required String description,
    required int price,
    required int quantity,
    required VoidCallback onAdd,
    required VoidCallback onRemove,
  }) {
    return Card(
      child: ListTile(
        title: Text(title),
        subtitle: Text(description),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(onPressed: onRemove, icon: const Icon(Icons.remove)),
            Text("$quantity"),
            IconButton(onPressed: onAdd, icon: const Icon(Icons.add)),
            const SizedBox(width: 8),
            Text("+$price€ / buc"),
          ],
        ),
      ),
    );
  }
}
