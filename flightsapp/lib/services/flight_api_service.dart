import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';

class FlightApiService {
  static const String _baseUrl = 'http://api.aviationstack.com/v1/flights';
  static const String _apiKey = '2bc9d1b2bf1bf4257b5aa401537d0fe2';

  Future<List<Map<String, dynamic>>> fetchFlights() async {
    final uri = Uri.parse('$_baseUrl?access_key=$_apiKey&limit=100');
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final flights = data['data'] as List;

      return flights.map((f) {
        final depTimeStr = f['departure']?['scheduled'];
        final arrTimeStr = f['arrival']?['scheduled'];
        DateTime? depTime = depTimeStr != null
            ? DateTime.tryParse(depTimeStr)
            : null;
        DateTime? arrTime = arrTimeStr != null
            ? DateTime.tryParse(arrTimeStr)
            : null;

        // Calculează durata (în minute)
        int duration = 0;
        if (depTime != null && arrTime != null) {
          duration = arrTime
              .difference(depTime)
              .inMinutes;
        }

        // Generează preț random (ex: între 100 și 300)
        final price = 100 + Random().nextInt(200);

        return {
          'departure_city': f['departure']?['airport'] ?? 'Necunoscut',
          'arrival_city': f['arrival']?['airport'] ?? 'Necunoscut',
          'airline': f['airline']?['name'] ?? 'Necunoscut',
          'flight_number': f['flight']?['iata'] ?? 'N/A',
          'status': f['flight_status'] ?? 'indisponibil',
          'departure_time': depTime != null
              ? Timestamp.fromDate(depTime)
              : null,
          'arrival_time': arrTime != null ? Timestamp.fromDate(arrTime) : null,
          'duration_minutes': duration,
          'price': price.toDouble(),
        };
      }).toList();
    } else {
      throw Exception('Eroare la descărcarea zborurilor');
    }
  }
}