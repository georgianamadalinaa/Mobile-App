import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MyTripsScreen extends StatelessWidget {
  const MyTripsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Călătoriile mele")),
        body: const Center(
          child: Text(
            "Trebuie să fii logat pentru a vizualiza călătoriile tale.",
            style: TextStyle(fontSize: 16, color: Colors.black54),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Călătoriile mele")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('bookings')
            .where('email', isEqualTo: user.email)
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text("Eroare la încărcarea rezervărilor."));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final bookings = snapshot.data!.docs;

          if (bookings.isEmpty) {
            return const Center(
              child: Text("Nu ai nicio rezervare momentan."),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              final booking = bookings[index];
              final isCanceled = booking['status'] == 'anulată';

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              "Destinație: ${booking['destination']}",
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          if (isCanceled)
                            const Chip(
                              label: Text("Anulată", style: TextStyle(color: Colors.white)),
                              backgroundColor: Colors.redAccent,
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text("Data plecării: ${booking['departureDate']}"),
                      Text("Loc: ${booking['seat']}"),
                      Text("Preț: ${booking['price']} €"),
                      const SizedBox(height: 8),
                      if (!isCanceled)
                        Align(
                          alignment: Alignment.centerRight,
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text("Confirmare"),
                                  content: const Text("Ești sigur că vrei să anulezi această rezervare?"),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, false),
                                      child: const Text("Nu"),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, true),
                                      child: const Text("Da"),
                                    ),
                                  ],
                                ),
                              );

                              if (confirm == true) {
                                await FirebaseFirestore.instance
                                    .collection('bookings')
                                    .doc(booking.id)
                                    .update({'status': 'anulată'});

                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("Rezervarea a fost marcată ca anulată.")),
                                );
                              }
                            },
                            icon: const Icon(Icons.cancel),
                            label: const Text("Anulează"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.redAccent,
                              foregroundColor: Colors.white,
                            ),
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
    );
  }
}
