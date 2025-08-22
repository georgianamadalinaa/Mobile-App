import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/booking_data.dart';
import 'pdf_generator.dart';

Future<bool> sendEmailWithEmailJS() async {
  final booking = BookingData.currentBooking;
  if (booking == null) {
    debugPrint('❌ BookingData.currentBooking este null.');
    return false;
  }

  const serviceId = 'service_59ob5qj';
  const templateId = 'template_xpgmp4s';
  const userId = '-3zFIEQV5XEJez5G3';

  try {
    final pdfFile = await generatePdfTicket(); // Generează PDF local
    debugPrint('✅ PDF generat la: ${pdfFile.path}');

    // NU mai trimitem PDF-ul online sau linkul lui
    final templateParams = {
      'email': booking.email,
      'ticket': ' ${booking.destination}',
      'seat': booking.seat,
      'departure': booking.departureDate, // <-- Adaugă data plecării
      'baggage': booking.hasBaggage  ? 'Da' : 'Nu', // <-- Adaugă info despre bagaj
      'method': 'Card',
      'total': booking.price.toStringAsFixed(2),

      // 'pdf_link': null, // nu mai este necesar
    };

    debugPrint('📤 Template params trimise către EmailJS: $templateParams');

    final response = await http.post(
      Uri.parse('https://api.emailjs.com/api/v1.0/email/send'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'service_id': serviceId,
        'template_id': templateId,
        'user_id': userId,
        'template_params': templateParams,
      }),
    );

    debugPrint('📬 Răspuns EmailJS: [${response.statusCode}] ${response.body}');

    if (response.statusCode == 200) {
      debugPrint('✅ Email trimis cu succes!');
      return true;
    } else {
      debugPrint('❌ Eroare EmailJS: ${response.body}');
      return false;
    }
  } catch (e) {
    debugPrint('❌ Exceptie la trimiterea emailului: $e');
    return false;
  }
}