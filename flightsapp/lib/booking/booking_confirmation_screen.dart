import 'package:flutter/material.dart';
import '../models/booking_data.dart';
import 'home_screen.dart';
import 'send_email.dart'; // pentru sendEmailWithEmailJS()
import '../services/firestore_service.dart';


class BookingConfirmationScreen extends StatefulWidget {
  const BookingConfirmationScreen({super.key});

  @override
  State<BookingConfirmationScreen> createState() => _BookingConfirmationScreenState();
}

class _BookingConfirmationScreenState extends State<BookingConfirmationScreen> {
  bool _emailSent = false;
  bool _sending = false;


  @override
  void initState() {
    super.initState();
    _saveBookingToFirebase();
    _sendEmailTicket();


  }

  Future<void> _saveBookingToFirebase() async {
    final booking = BookingData.currentBooking;
    if (booking != null) {
      await FirestoreService().saveBooking(booking);
    }
  }
  Future<void> _sendEmailTicket() async {
    setState(() {
      _sending = true;
    });
    final success = await sendEmailWithEmailJS();
    if (mounted) {
      setState(() {
        _emailSent = success;
        _sending = false;
      });
    }
  }



  @override
  Widget build(BuildContext context) {
    final booking = BookingData.currentBooking;

    if (booking == null) {
      return const Scaffold(
        body: Center(child: Text('Eroare: nu există rezervare')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rezervare Confirmată'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Icon(Icons.check_circle, color: Colors.green, size: 70),
            ),
            const SizedBox(height: 24),
            const Center(
              child: Text(
                'Rezervarea a fost confirmată!',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 32),
            Text('✈️ Destinație: ${booking.destination}'),
            Text('📅 Data plecării: ${booking.departureDate}'),
            Text('💺 Loc rezervat: ${booking.seat}'),
            Text('🧳 Bagaj: ${booking.hasBaggage ? 'Da' : 'Nu'}'),
            const SizedBox(height: 8),
            Text('📧 Email pasager: ${booking.email}'),
            Text('💳 Total plătit: ${booking.price.toStringAsFixed(2)} RON'),
            const SizedBox(height: 32),
            const Text('Un email de confirmare a fost trimis la:',
                style: TextStyle(fontWeight: FontWeight.w500)),
            Text(booking.email, style: const TextStyle(fontWeight: FontWeight.bold)),
            const Spacer(),
            if (_sending)
              const Center(child: CircularProgressIndicator())
            else
              Center(
                child: Text(
                  _emailSent
                      ? '✔️ Biletul a fost trimis cu succes pe email.'
                      : '❌ Eroare la trimiterea biletului.',
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.home),
                label: const Text('Înapoi la pagina principală'),
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const HomeScreen()),
                        (route) => false,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}