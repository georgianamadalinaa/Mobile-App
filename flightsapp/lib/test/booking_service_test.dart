import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flightsapp/models/booking.dart';
import 'package:flightsapp/services/firestore_service.dart';

class BookingService {
  final FirebaseFirestore _db;

  BookingService(this._db);

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
}

void main() {
  group('BookingService', () {
    test('salvează o rezervare în Firestore', () async {
      // Arrange
      final firestore = FakeFirebaseFirestore();
      final service = BookingService(firestore);

      final booking = Booking(
        email: 'test@example.com',
        destination: 'Milano',
        departureDate: '2025-07-15',
        seat: '12A',
        hasBaggage: true,
        price: 199.99,
      );

      // Act
      await service.saveBooking(booking);

      // Assert
      final snapshot = await firestore.collection('bookings').get();
      expect(snapshot.docs.length, 1);

      final data = snapshot.docs.first.data();
      expect(data['email'], 'test@example.com');
      expect(data['destination'], 'Milano');
      expect(data['departureDate'], '2025-07-15');
      expect(data['seat'], '12A');
      expect(data['hasBaggage'], true);
      expect(data['price'], 199.99);
      expect(data['status'], 'activă');
    });
  });
}
