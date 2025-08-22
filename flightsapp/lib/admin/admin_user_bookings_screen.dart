import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class AdminUserBookingsScreen extends StatefulWidget {
  final String userEmail;
  const AdminUserBookingsScreen({super.key, required this.userEmail});

  @override
  State<AdminUserBookingsScreen> createState() => _AdminUserBookingsScreenState();
}

class _AdminUserBookingsScreenState extends State<AdminUserBookingsScreen> {
  bool sortAscending = true;

  String formatTimestamp(dynamic timestamp) {
    if (timestamp == null) return "necunoscut";
    final date = timestamp is Timestamp ? timestamp.toDate() : timestamp;
    return DateFormat('dd MMM yyyy, HH:mm').format(date);
  }

  Future<void> exportBookingAsPdf(Map<String, dynamic> data) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text("Detalii rezervare", style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 20),
            pw.Text("Destinație: ${data['destination'] ?? 'necunoscut'}"),
            pw.Text("Data plecării: ${data['departureDate'] ?? 'necunoscut'}"),
            pw.Text("Loc: ${data['seat'] ?? 'necunoscut'}"),
            pw.Text("Bagaj: ${data['hasBaggage'] == true ? 'Da' : 'Nu'}"),
            pw.Text("Preț: ${data['price']?.toString() ?? '0'} €"),
            pw.Text("Email: ${data['email'] ?? 'necunoscut'}"),
            pw.Text("Creat la: ${formatTimestamp(data['timestamp'])}"),
          ],
        ),
      ),
    );

    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/rezervare_${DateTime.now().millisecondsSinceEpoch}.pdf');
      await file.writeAsBytes(await pdf.save());

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("PDF salvat la: ${file.path}")),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Eroare la salvarea PDF-ului: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bookingsRef = FirebaseFirestore.instance
        .collection('bookings')
        .where('email', isEqualTo: widget.userEmail);

    return Scaffold(
      appBar: AppBar(
        title: Text("Rezervări - ${widget.userEmail}"),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                sortAscending = value == 'asc';
              });
            },
            icon: const Icon(Icons.sort),
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'asc', child: Text('Sortează crescător')),
              const PopupMenuItem(value: 'desc', child: Text('Sortează descrescător')),
            ],
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: bookingsRef.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return const Center(child: Text('Eroare la încărcare.'));
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final docs = snapshot.data!.docs;

          final sortedDocs = docs.toList()
            ..sort((a, b) {
              final aDateStr = a['departureDate'] ?? '';
              final bDateStr = b['departureDate'] ?? '';
              try {
                final aDate = DateFormat("dd MMM yyyy, HH:mm").parse(aDateStr);
                final bDate = DateFormat("dd MMM yyyy, HH:mm").parse(bDateStr);
                return sortAscending ? aDate.compareTo(bDate) : bDate.compareTo(aDate);
              } catch (_) {
                return 0;
              }
            });

          if (sortedDocs.isEmpty) {
            return const Center(child: Text("Acest utilizator nu are rezervări."));
          }

          return ListView.builder(
            itemCount: sortedDocs.length,
            itemBuilder: (context, index) {
              final data = sortedDocs[index].data() as Map<String, dynamic>;

              return Card(
                margin: const EdgeInsets.all(12),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Destinație: ${data['destination'] ?? 'necunoscut'}",
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text("Data plecării: ${data['departureDate'] ?? 'necunoscut'}"),
                      Text("Loc: ${data['seat'] ?? 'necunoscut'}"),
                      Text("Bagaj: ${data['hasBaggage'] == true ? 'Da' : 'Nu'}"),
                      Text("Preț: ${data['price']?.toString() ?? '0'} €"),
                      Text("Creat la: ${formatTimestamp(data['timestamp'])}"),
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton.icon(
                          icon: const Icon(Icons.picture_as_pdf, color: Colors.red),
                          label: const Text("Exportă PDF"),
                          onPressed: () => exportBookingAsPdf(data),
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
