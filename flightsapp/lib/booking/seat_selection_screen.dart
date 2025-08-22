import 'package:flutter/material.dart';
import 'payment_screen.dart';
import '../models/booking_data.dart';

class SeatSelectionScreen extends StatefulWidget {
  final int numPassengers;
  final List<Map<String, dynamic>> passengers;
  final double upgradeTotal;

  const SeatSelectionScreen({
    super.key,
    required this.numPassengers,
    required this.passengers,
    required this.upgradeTotal,
  });

  @override
  State<SeatSelectionScreen> createState() => _SeatSelectionScreenState();
}

class _SeatSelectionScreenState extends State<SeatSelectionScreen> {
  final List<String> seatColumns = ['A', 'B', 'C', 'D', 'E', 'F'];
  final int numRows = 7;

  final Set<String> extraLegroomSeats = {'A1', 'C1', 'F1'};
  final Set<String> unavailableSeats = {'C2', 'C5', 'B5', 'E5', 'D5', 'A6'};

  late List<String?> selectedSeats;
  late List<bool> isSeatManuallySelected;
  int activePassengerIndex = 0;

  @override
  void initState() {
    super.initState();
    selectedSeats = List<String?>.filled(widget.numPassengers, null);
    isSeatManuallySelected = List<bool>.filled(widget.numPassengers, false);
  }

  double getSeatPrice(String seatId) {
    if (extraLegroomSeats.contains(seatId)) return 28;
    if (seatId.endsWith('7') || seatId.endsWith('6')) return 18;
    return 20;
  }

  double getTotalPrice() {
    double seatCost = 0;
    for (int i = 0; i < selectedSeats.length; i++) {
      if (selectedSeats[i] != null && isSeatManuallySelected[i]) {
        seatCost += getSeatPrice(selectedSeats[i]!);
      }
    }
    return widget.upgradeTotal + seatCost;
  }

  @override
  Widget build(BuildContext context) {
    final booking = BookingData.currentBooking;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Alege locul în avion"),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            const Text(
              "Selectați un loc pentru fiecare pasager",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: activePassengerIndex > 0
                      ? () => setState(() => activePassengerIndex--)
                      : null,
                  icon: const Icon(Icons.arrow_back),
                ),
                Text(
                  "Pasager ${activePassengerIndex + 1}: "
                      "${widget.passengers[activePassengerIndex]['name']} "
                      "${widget.passengers[activePassengerIndex]['surname']}",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                IconButton(
                  onPressed: activePassengerIndex < widget.numPassengers - 1
                      ? () => setState(() => activePassengerIndex++)
                      : null,
                  icon: const Icon(Icons.arrow_forward),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: List.generate(numRows, (rowIndex) {
                    final rowNum = rowIndex + 1;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: seatColumns.map((col) {
                          final seatId = "$col$rowNum";
                          final isUnavailable = unavailableSeats.contains(seatId);
                          final isSelectedByCurrent = selectedSeats[activePassengerIndex] == seatId;
                          final isSelectedByOthers = selectedSeats.contains(seatId) && !isSelectedByCurrent;
                          final isExtra = extraLegroomSeats.contains(seatId);
                          final price = getSeatPrice(seatId);

                          Color color;
                          if (isUnavailable) {
                            color = Colors.grey.shade400;
                          } else if (isSelectedByCurrent) {
                            color = Colors.blueAccent;
                          } else if (isSelectedByOthers) {
                            color = Colors.red.shade200;
                          } else if (isExtra) {
                            color = Colors.orange.shade100;
                          } else {
                            color = Colors.teal.shade50;
                          }

                          return GestureDetector(
                            onTap: isUnavailable || isSelectedByOthers
                                ? null
                                : () => setState(() {
                              if (isSelectedByCurrent) {
                                selectedSeats[activePassengerIndex] = null;
                                isSeatManuallySelected[activePassengerIndex] = false;
                              } else {
                                selectedSeats[activePassengerIndex] = seatId;
                                isSeatManuallySelected[activePassengerIndex] = true;
                              }
                            }),
                            child: Container(
                              width: 40,
                              height: 50,
                              decoration: BoxDecoration(
                                color: color,
                                border: Border.all(color: Colors.black26),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: isUnavailable
                                    ? const Icon(Icons.close, size: 20)
                                    : Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(seatId, style: const TextStyle(fontSize: 10)),
                                    Text("${price.toInt()}€", style: const TextStyle(fontSize: 12)),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    );
                  }),
                ),
              ),
            ),

            const SizedBox(height: 10),

            Wrap(
              alignment: WrapAlignment.center,
              spacing: 12,
              runSpacing: 8,
              children: [
                _buildLegendBox("Extra spațiu", Colors.orange.shade100),
                _buildLegendBox("Standard", Colors.teal.shade50),
                _buildLegendBox("Indisponibil", Colors.grey.shade400),
                _buildLegendBox("Selectat", Colors.blueAccent),
                _buildLegendBox("Alt pasager", Colors.red.shade200),
              ],
            ),

            const SizedBox(height: 16),

            Text(
              "Total de plată: ${getTotalPrice().toStringAsFixed(2)} €",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final allSeats = List.generate(numRows, (row) =>
                      seatColumns.map((col) => '$col${row + 1}')).expand((s) => s);

                  for (int i = 0; i < selectedSeats.length; i++) {
                    if (selectedSeats[i] == null) {
                      final autoSeat = allSeats.firstWhere(
                            (seat) =>
                        !unavailableSeats.contains(seat) &&
                            !extraLegroomSeats.contains(seat) &&
                            !selectedSeats.contains(seat),
                        orElse: () => 'N/A',
                      );
                      selectedSeats[i] = autoSeat;
                      isSeatManuallySelected[i] = false;
                    }
                  }

                  if (booking != null && selectedSeats.isNotEmpty) {
                    BookingData.passengerSeats = selectedSeats.whereType<String>().toList();
                    booking.seat = selectedSeats.firstWhere((s) => s != null)!;
                    booking.price = getTotalPrice();
                  }

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const FakePaymentScreen(),
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

  Widget _buildLegendBox(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            border: Border.all(),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
