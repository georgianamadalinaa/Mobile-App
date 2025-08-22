import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AdminFlightsScreen extends StatefulWidget {
  const AdminFlightsScreen({super.key});

  @override
  State<AdminFlightsScreen> createState() => _AdminFlightsScreenState();
}

class _AdminFlightsScreenState extends State<AdminFlightsScreen> {
  final _plecareSearch = TextEditingController();
  final _destinatieSearch = TextEditingController();
  double _maxPrice = 1000;

  @override
  void dispose() {
    _plecareSearch.dispose();
    _destinatieSearch.dispose();
    super.dispose();
  }

  void _editeazaZbor(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final plecareCtrl = TextEditingController(text: data['departure_city']);
    final destinatieCtrl = TextEditingController(text: data['arrival_city']);
    final pretCtrl = TextEditingController(text: data['price']?.toString());
    final airlineCtrl = TextEditingController(text: data['airline']);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Editează zbor"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: plecareCtrl, decoration: const InputDecoration(labelText: "Plecare")),
            TextField(controller: destinatieCtrl, decoration: const InputDecoration(labelText: "Destinație")),
            TextField(controller: pretCtrl, decoration: const InputDecoration(labelText: "Preț")),
            TextField(controller: airlineCtrl, decoration: const InputDecoration(labelText: "Companie")),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Anulează"),
          ),
          ElevatedButton(
            onPressed: () async {
              await doc.reference.update({
                'departure_city': plecareCtrl.text.trim(),
                'arrival_city': destinatieCtrl.text.trim(),
                'price': int.tryParse(pretCtrl.text.trim()) ?? 0,
                'airline': airlineCtrl.text.trim(),
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Zbor actualizat.")),
              );
            },
            child: const Text("Salvează"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final flightsRef = FirebaseFirestore.instance.collection('flights_mock');
    final formatter = DateFormat.Hm();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Zboruri disponibile"),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _plecareSearch,
                        decoration: const InputDecoration(labelText: 'Caută după plecare'),
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _destinatieSearch,
                        decoration: const InputDecoration(labelText: 'Caută după destinație'),
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Text("Preț maxim: "),
                    Expanded(
                      child: Slider(
                        value: _maxPrice,
                        min: 0,
                        max: 1000,
                        divisions: 20,
                        label: _maxPrice.round().toString(),
                        onChanged: (value) => setState(() => _maxPrice = value),
                      ),
                    ),
                    Text("${_maxPrice.round()} €"),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: flightsRef.snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) return const Center(child: Text('Eroare la încărcare.'));
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

                final docs = snapshot.data!.docs;
                final filtered = docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;

                  final plecare = (data['departure_city'] ?? '').toString().toLowerCase();
                  final destinatie = (data['arrival_city'] ?? '').toString().toLowerCase();
                  final pret = data['price'] ?? 0;

                  final plecareMatch = plecare.contains(_plecareSearch.text.toLowerCase());
                  final destinatieMatch = destinatie.contains(_destinatieSearch.text.toLowerCase());
                  final priceMatch = pret <= _maxPrice;

                  return plecareMatch && destinatieMatch && priceMatch;
                }).toList()
                 // ..sort((a, b) {
                   // final pretA = (a.data() as Map<String, dynamic>)['price'] ?? 0;
                    //final pretB = (b.data() as Map<String, dynamic>)['price'] ?? 0;
                    //return pretA.compareTo(pretB);
                  //})
                ;

                if (filtered.isEmpty) return const Center(child: Text("Niciun zbor găsit."));

                return ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final doc = filtered[index];
                    final data = doc.data() as Map<String, dynamic>;

                    final departure = data['departure_city'] ?? '---';
                    final arrival = data['arrival_city'] ?? '---';
                    final price = data['price']?.toString() ?? '---';
                    final airline = data['airline'] ?? '---';

                    final departureTime = (data['departure_time'] as Timestamp?)?.toDate();
                    final arrivalTime = (data['arrival_time'] as Timestamp?)?.toDate();

                    final departureHour = departureTime != null ? formatter.format(departureTime) : '--:--';
                    final arrivalHour = arrivalTime != null ? formatter.format(arrivalTime) : '--:--';

                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        leading: const Icon(Icons.flight_takeoff, color: Colors.lightBlueAccent),
                        title: Text("$departure → $arrival"),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Ora plecare: $departureHour  •  Ora sosire: $arrivalHour"),
                            Text("Companie: $airline"),
                            Text("Preț: $price Euro"),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.orange),
                              onPressed: () => _editeazaZbor(doc),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text("Confirmare"),
                                    content: const Text("Ești sigur că vrei să ștergi acest zbor?"),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context), // închide dialogul
                                        child: const Text("Anulează"),
                                      ),
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.red,
                                          foregroundColor: Colors.white,
                                        ),
                                        onPressed: () async {
                                          await flightsRef.doc(doc.id).delete();
                                          Navigator.pop(context); // închide dialogul
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text("Zbor șters.")),
                                          );
                                        },
                                        child: const Text("Șterge"),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),

                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
