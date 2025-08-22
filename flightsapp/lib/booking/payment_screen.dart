/*import 'package:flutter/foundation.dart'; // pentru defaultTargetPlatform
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'models/booking_data.dart';
import 'booking_confirmation_screen.dart';
import 'services/firestore_service.dart';
import 'notification_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FakePaymentScreen extends StatefulWidget {
  const FakePaymentScreen({super.key});

  @override
  State<FakePaymentScreen> createState() => _FakePaymentScreenState();
}

class _FakePaymentScreenState extends State<FakePaymentScreen> {
  bool isLoading = false;
  String selectedMethod = 'Visa';

  Future<void> launchStripeCheckout() async {
    final url = Uri.parse('https://buy.stripe.com/test_4gMbIU6Kr8oJ47E3o6fEk00');

    if (await canLaunchUrl(url)) {
      final launched = await launchUrl(url, mode: LaunchMode.externalApplication);
      if (!launched) {
        throw 'Nu am putut deschide linkul de plată';
      }
    } else {
      throw 'Nu am putut deschide linkul de plată';
    }
  }


  void _handlePayment() async {
    setState(() => isLoading = true);

    try {
      // Deschide pagina de plată Stripe
      await launchStripeCheckout();

      // După ce utilizatorul revine, salvează plata (atenție: nu e confirmarea reală)
      final booking = BookingData.currentBooking;
      if (booking == null) throw Exception("Nu există date de rezervare.");

      booking.price = booking.price == 0 ? 99.99 : booking.price;

      await FirestoreService().savePayment(
        email: booking.email,
        amount: booking.price,
        method: selectedMethod,
      );

      await NotificationService.showPaymentConfirmationNotification();

      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance.collection('notifications').add({
          'email': user.email,
          'title': 'Plată confirmată',
          'message': 'Rezervarea ta a fost procesată cu succes.',
          'timestamp': FieldValue.serverTimestamp(),
        });
      }

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const BookingConfirmationScreen()),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Eroare la plată: $e")),
        );
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Plată")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              value: selectedMethod,
              items: ['Visa', 'Mastercard', 'Amex']
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (val) => setState(() => selectedMethod = val!),
              decoration: const InputDecoration(labelText: "Metodă de plată"),
            ),
            const SizedBox(height: 20),
            isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
              onPressed: _handlePayment,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              child: Text(
                "Plătește ${BookingData.currentBooking?.price.toStringAsFixed(2) ?? '0.00'} €",
              ),
            ),
          ],
        ),
      ),
    );
  }
}*/
import 'package:flutter/material.dart';
import '../models/booking_data.dart';
import 'booking_confirmation_screen.dart';
import '../services/firestore_service.dart';
import '../notifications/notification_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';

class FakePaymentScreen extends StatefulWidget {
  const FakePaymentScreen({super.key});

  @override
  State<FakePaymentScreen> createState() => _FakePaymentScreenState();
}

class _FakePaymentScreenState extends State<FakePaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  String cardNumber = '';
  String expiryDate = '';
  String cvv = '';
  String selectedMethod = 'Visa';
  bool isLoading = false;

  void _handlePayment() async {
    if (_formKey.currentState!.validate()) {
      setState(() => isLoading = true);

      try {
        final booking = BookingData.currentBooking;

        if (booking == null) {
          throw Exception("Nu există date de rezervare.");
        }

        booking.price = booking.price == 0 ? 99.99 : booking.price;

        // 🔹 Salvăm plata în Firestore
        await FirestoreService().savePayment(
          email: booking.email,
          amount: booking.price,
          method: selectedMethod,
        );
        await NotificationService.showPaymentConfirmationNotification();
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          await FirebaseFirestore.instance.collection('notifications').add({
            'email': user.email,
            'title': 'Plată confirmată',
            'message': 'Rezervarea ta a fost procesată cu succes.',
            'timestamp': FieldValue.serverTimestamp(),
          });
        }
        if (!mounted) return;

        // 🔹 Navigăm către ecranul de confirmare (emailul se trimite acolo)
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const BookingConfirmationScreen()),
        );
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Eroare la plată: $e")),
          );
        }
      } finally {
        if (mounted) {
          setState(() => isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Plată")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const Text(
                "Introduceți datele cardului (simulat):",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                value: selectedMethod,
                items: ['Visa', 'Mastercard', 'Amex']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (val) => setState(() => selectedMethod = val!),
                decoration: const InputDecoration(labelText: "Metodă de plată"),
              ),

              TextFormField(
                decoration: const InputDecoration(
                  labelText: "Număr card",
                  counterText: "", // Ascunde indicatorul de lungime
                ),
                keyboardType: TextInputType.number,
                maxLength: 16, // limita vizuală la 16 caractere
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(16),
                ],
                validator: (val) {
                  if (val == null || val.length != 16) {
                    return "Numărul cardului trebuie să aibă 16 cifre";
                  }
                  return null;
                },
              ),


              TextFormField(
                decoration: const InputDecoration(labelText: "Data expirării (MM/YY)"),
                keyboardType: TextInputType.datetime,
                validator: (val) => val != null && val.length >= 4 ? null : "Dată invalidă",
              ),

              TextFormField(
                decoration: const InputDecoration(labelText: "CVV"),
                keyboardType: TextInputType.number,
                obscureText: true,
                validator: (val) => val != null && val.length == 3 ? null : "CVV invalid",
              ),

              const SizedBox(height: 20),
              isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                onPressed: _handlePayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
                child: Text("Plătește ${BookingData.currentBooking?.price.toStringAsFixed(2) ?? '0.00'} €"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

