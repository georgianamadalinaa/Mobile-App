import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/booking.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> saveFlights(List<Map<String, dynamic>> flights) async {
    final batch = _db.batch();
    final flightsRef = _db.collection('flights_api');

    for (var flight in flights) {
      final doc = flightsRef.doc();
      batch.set(doc, flight);
    }

    await batch.commit();
  }

  Future<void> saveBooking(Booking booking) async {
    final bookingRef = _db.collection('bookings').doc();
    await bookingRef.set({
      'email': booking.email,
      'destination': booking.destination,
      'departureDate': booking.departureDate,
      'seat': booking.seat,
      'hasBaggage': booking.hasBaggage,
      'price': booking.price,
      'timestamp': FieldValue.serverTimestamp(),
      'status': 'activă',
    });
  }

  Future<void> savePayment({
    required String email,
    required double amount,
    required String method,
  }) async {
    final paymentRef = _db.collection('payments').doc();
    await paymentRef.set({
      'email': email,
      'amount': amount,
      'method': method,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
  Future<void> sendNotificationToUser({
    required String email,
    required String title,
    required String message,
  }) async {
    final notificationsRef = FirebaseFirestore.instance.collection('notifications');

    await notificationsRef.add({
      'email': email,
      'title': title,
      'message': message,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

}
