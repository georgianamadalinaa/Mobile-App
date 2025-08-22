import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AdminPaymentsScreen extends StatelessWidget {
  const AdminPaymentsScreen({super.key});

  String formatTimestamp(dynamic timestamp) {
    if (timestamp == null) return "necunoscut";
    final date = timestamp is Timestamp ? timestamp.toDate() : timestamp;
    return DateFormat('dd MMM yyyy, HH:mm').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final paymentsRef = FirebaseFirestore.instance.collection('payments');

    return Scaffold(
      appBar: AppBar(title: const Text("Plăți efectuate")),
      body: StreamBuilder<QuerySnapshot>(
        stream: paymentsRef.orderBy('timestamp', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Eroare la încărcarea plăților.'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;
          if (docs.isEmpty) {
            return const Center(child: Text("Nicio plată efectuată."));
          }

          final total = docs.fold<double>(
            0,
                (sum, doc) {
              final amount = (doc['amount'] as num?)?.toDouble() ?? 0.0;
              return sum + amount;
            },
          );

          return Column(
            children: [
              Container(
                width: double.infinity,
                color: Colors.green.shade100,
                padding: const EdgeInsets.all(16),
                child: Text(
                  "Total încasat: ${total.toStringAsFixed(2)} €",
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    return ListTile(
                      leading: const Icon(Icons.payment, color: Colors.green),
                      title: Text("${data['amount']?.toStringAsFixed(2) ?? '0.00'} €"),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Metodă: ${data['method'] ?? 'necunoscut'}"),
                          Text("Email: ${data['email'] ?? 'necunoscut'}"),
                          Text("Data: ${formatTimestamp(data['timestamp'])}"),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
