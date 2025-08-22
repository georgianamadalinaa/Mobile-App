import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AdminBookingsScreen extends StatefulWidget {
  const AdminBookingsScreen({super.key});

  @override
  State<AdminBookingsScreen> createState() => _AdminBookingsScreenState();
}

class _AdminBookingsScreenState extends State<AdminBookingsScreen> {
  bool _sortDescending = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String formatTimestamp(dynamic timestamp) {
    if (timestamp == null) return "necunoscut";
    final date = timestamp is Timestamp ? timestamp.toDate() : timestamp;
    return DateFormat('dd MMM yyyy, HH:mm').format(date);
  }

  void _confirmDelete(BuildContext context, String docId) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Confirmă ștergerea"),
        content: const Text("Ești sigur că vrei să ștergi această rezervare?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Anulează"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await FirebaseFirestore.instance.collection('bookings').doc(docId).delete();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Rezervarea a fost ștearsă.")),
              );
            },
            child: const Text("Șterge", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bookingsRef = FirebaseFirestore.instance.collection('bookings');

    return Scaffold(
      appBar: AppBar(
        title: const Text("Rezervări efectuate"),
        actions: [
          IconButton(
            icon: Icon(_sortDescending ? Icons.arrow_downward : Icons.arrow_upward),
            tooltip: _sortDescending ? "Cele mai noi primele" : "Cele mai vechi primele",
            onPressed: () {
              setState(() {
                _sortDescending = !_sortDescending;
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Filtrează după destinație',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: bookingsRef.orderBy('timestamp', descending: _sortDescending).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text('Eroare la încărcare.'));
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final searchQuery = _searchController.text.toLowerCase();
                final docs = snapshot.data!.docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final destination = (data['destination'] ?? '').toString().toLowerCase();
                  return destination.contains(searchQuery);
                }).toList();

                if (docs.isEmpty) {
                  return const Center(child: Text("Nicio rezervare găsită."));
                }

                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    final data = doc.data() as Map<String, dynamic>;

                    return Card(
                      margin: const EdgeInsets.all(12),
                      elevation: 4,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Stack(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Destinație: ${data['destination'] ?? 'necunoscut'}",
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                                Text("Data plecării: ${data['departureDate'] ?? 'necunoscut'}"),
                                Text("Loc rezervat: ${data['seat'] ?? 'necunoscut'}"),
                                Text("Bagaj: ${data['hasBaggage'] == true ? 'Da' : 'Nu'}"),
                                Text("Preț: ${data['price']?.toStringAsFixed(2) ?? '0.00'} €"),
                                const SizedBox(height: 10),
                                const Text("Pasager:", style: TextStyle(fontWeight: FontWeight.bold)),
                                Text("${data['email'] ?? 'necunoscut'}"),
                                Text("Creat la: ${formatTimestamp(data['timestamp'])}"),
                              ],
                            ),
                            Positioned(
                              top: 0,
                              right: 0,
                              child: IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                tooltip: "Șterge rezervarea",
                                onPressed: () => _confirmDelete(context, doc.id),
                              ),
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
