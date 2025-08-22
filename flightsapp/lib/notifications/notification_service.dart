import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';


class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
  FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    const AndroidInitializationSettings androidSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initSettings =
    InitializationSettings(android: androidSettings);

    await _notificationsPlugin.initialize(initSettings);
  }

  /// ✅ Notificare pentru confirmarea plății
  static Future<void> showPaymentConfirmationNotification() async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'payment_channel',
      'Plăți',
      importance: Importance.high,
      priority: Priority.high,
      color: Color(0xFF42A5F5),
      icon: '@mipmap/ic_launcher',
    );

    const NotificationDetails platformDetails = NotificationDetails(android: androidDetails);

    await _notificationsPlugin.show(
      0,
      'Plată confirmată',
      'Rezervarea ta a fost înregistrată cu succes!',
      platformDetails,
    );
  }

  /// ✅ Verifică zborurile și notifică cu 24h înainte + generează poarta
  static Future<void> checkFlightsAndNotify(String userEmail) async {
    final now = DateTime.now();

    final snapshot = await FirebaseFirestore.instance
        .collection('bookings')
        .where('email', isEqualTo: userEmail)
        .get();

    for (var doc in snapshot.docs) {
      final data = doc.data();
      if (!data.containsKey('departureDate')) continue;

      try {
        final dateStr = data['departureDate'];
        final dateFormat = DateFormat('d MMM yyyy, HH:mm'); // Formatul tău
        final date = dateFormat.parse(dateStr);
        final diff = date.difference(now);

        if (diff.inHours <= 24 && diff.inHours >= 23) {
          String gate = data['gate'] ?? '';

          if (gate.isEmpty) {
            gate = _generateGate();
            await doc.reference.update({'gate': gate});
          }

          final String destination = data['destination'] ?? 'necunoscută';
          final String seat = data['seat'] ?? 'N/A';

          await _notificationsPlugin.show(
            1,
            'Zborul tău este în 24h!',
            'Destinație: $destination\nPoarta: $gate\nLoc: $seat',
            const NotificationDetails(
              android: AndroidNotificationDetails(
                'flight_channel',
                'Zboruri',
                importance: Importance.high,
                priority: Priority.high,
                icon: '@mipmap/ic_launcher',
              ),
            ),
          );
        }
      } catch (e) {
        print('Eroare la parsarea datei: $e');
      }
    }


  }

  /// 🔁 Generează o poartă de tip A1, B3, etc.
  static String _generateGate() {
    const gates = ['A', 'B', 'C', 'D'];
    final random = Random();
    return '${gates[random.nextInt(gates.length)]}${random.nextInt(10) + 1}';
  }
}
