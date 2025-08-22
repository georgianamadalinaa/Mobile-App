import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../models/booking_data.dart';

Future<File> generatePdfTicket() async {
  final pdf = pw.Document();
  final booking = BookingData.currentBooking;
  if (booking == null) throw Exception("Datele de rezervare nu sunt disponibile");

  final font = pw.Font.ttf(await rootBundle.load('assets/fonts/Roboto-Regular.ttf'));
  final logoBytes = await rootBundle.load('assets/icon/app_icon.png').then((value) => value.buffer.asUint8List());
  final logo = pw.MemoryImage(logoBytes);

  final outputDir = await getTemporaryDirectory();
  final timestamp = DateTime.now().millisecondsSinceEpoch;
  final pdfFile = File('${outputDir.path}/bilet_zbor_$timestamp.pdf');

  pdf.addPage(
    pw.Page(
      theme: pw.ThemeData.withFont(base: font),
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(32),
      build: (context) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // Logo centrat
          pw.Center(child: pw.Image(logo, height: 60)),
          pw.SizedBox(height: 16),

          // Titlu
          pw.Center(
            child: pw.Text(
              "BILET DE AVION",
              style: pw.TextStyle(
                fontSize: 24,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.blueGrey800,
              ),
            ),
          ),
          pw.SizedBox(height: 16),
          pw.Divider(),

          // Detalii Zbor
          pw.Text("Detalii Zbor:", style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 8),
          pw.Text("Destinatie: ${booking.destination}"),
          pw.Text("Data plecarii: ${booking.departureDate}"),
          pw.Text("Loc rezervat: ${booking.seat}"),
          pw.Text("Bagaj aditional: ${booking.hasBaggage ? 'Da' : 'Nu'}"),

          pw.SizedBox(height: 16),
          pw.Divider(),

          // Detalii Plata
          pw.Text("Detalii Plata:", style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 8),
          pw.Text("Total achitat: ${booking.price.toStringAsFixed(2)} EURO"),
          pw.Text("Metoda plata: Card"),

          pw.SizedBox(height: 16),
          pw.Divider(),

          // Pasager
          pw.Text("Pasager:", style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 8),
          pw.Text("Email: ${booking.email}"),

          pw.Spacer(),

          // Mesaj final
          pw.Center(
            child: pw.Text(
              "Va multumim ca ati ales serviciile noastre!",
              style: pw.TextStyle(
                fontStyle: pw.FontStyle.italic,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    ),
  );

  await pdfFile.writeAsBytes(await pdf.save());
  print('✅ PDF generat la: ${pdfFile.path}');
  return pdfFile;
}