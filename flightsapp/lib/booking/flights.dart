import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> importMockFlights() async {
  final firestore = FirebaseFirestore.instance;
  final batch = firestore.batch();
  final random = Random();

  // Functie care genereaza zboruri zilnice la mai multe ore pe zi
  List<DateTime> generateFlightsMultipleTimesPerDay({
    required int startMonth,
    required int endMonth,
    required int year,
    required List<List<int>> times, // ex: [[8, 30], [18, 45]]
  }) {
    final List<DateTime> departures = [];
    for (int month = startMonth; month <= endMonth; month++) {
      final daysInMonth = DateTime(year, month + 1, 0).day;
      for (int day = 1; day <= daysInMonth; day++) {
        for (var time in times) {
          departures.add(DateTime(year, month, day, time[0], time[1]));
        }
      }
    }
    return departures;
  }

  final List<Map<String, dynamic>> routes = [
    {
      'departure_city': 'București',
      'arrival_city': 'Paris',
      'flights': [
        {
          'airline': 'Air France',
          'flight_number': 'AF123',
          'departure_times': generateFlightsMultipleTimesPerDay(
            startMonth: 7,
            endMonth: 9,
            year: 2025,
            times: [
              [8, 30],
              [18, 45],
              [22,0],
            ],
          ),
          'duration_minutes': 180,
        },
        {
          'airline': 'Tarom',
          'flight_number': 'RO201',
          'departure_times': generateFlightsMultipleTimesPerDay(
            startMonth: 7,
            endMonth: 9,
            year: 2025,
            times: [
              [14, 0],
              [20, 15],
              [10,15],
              [12,0],
            ],
          ),
          'duration_minutes': 185,
        },
        {
          'airline': 'Wizz Air',
          'flight_number': 'W62387',
          'departure_times': generateFlightsMultipleTimesPerDay(
            startMonth: 7,
            endMonth: 9,
            year: 2025,
            times: [
              [18, 15],
              [6, 0],
              [12,35],
              [15,10],
            ],
          ),
          'duration_minutes': 180,
        },
      ],
    },
    {
      'departure_city': 'Cluj',
      'arrival_city': 'Berlin',
      'flights': [
        {
          'airline': 'Lufthansa',
          'flight_number': 'LH456',
          'departure_times': generateFlightsMultipleTimesPerDay(
            startMonth: 7,
            endMonth: 9,
            year: 2025,
            times: [
              [10, 0],
              [21, 30],
              [7,30],
            ],
          ),
          'duration_minutes': 150,
        },
        {
          'airline': 'Wizz Air',
          'flight_number': 'W62345',
          'departure_times': generateFlightsMultipleTimesPerDay(
            startMonth: 7,
            endMonth: 9,
            year: 2025,
            times: [
              [18, 15],
              [6, 0],
              [12,35],
              [15,10],
            ],
          ),
          'duration_minutes': 155,
        },
        {
          'airline': 'Tarom',
          'flight_number': 'RO290',
          'departure_times': generateFlightsMultipleTimesPerDay(
            startMonth: 7,
            endMonth: 9,
            year: 2025,
            times: [
              [14, 0],
              [20, 15],
              [10,15],
              [12,0],
            ],
          ),
          'duration_minutes': 155,
        },
      ],
    },
    {
      'departure_city': 'Milano',
      'arrival_city': 'București',
      'flights': [
        {
          'airline': 'Wizz Air',
          'flight_number': 'W63001',
          'departure_times': generateFlightsMultipleTimesPerDay(
            startMonth: 7,
            endMonth: 9,
            year: 2025,
            times: [
              [9, 20],
              [12,15],
              [15, 30],
              [20, 50],
            ],
          ),
          'duration_minutes': 160,
        },
        {
          'airline': 'Ryanair',
          'flight_number': 'FR4512',
          'departure_times': generateFlightsMultipleTimesPerDay(
            startMonth: 7,
            endMonth: 9,
            year: 2025,
            times: [
              [6, 15],
              [10,0],
              [13,30],
              [18, 0],
            ],
          ),
          'duration_minutes': 165,
        },
      ],
    },
    {
      'departure_city': 'Veneția',
      'arrival_city': 'București',
      'flights': [
        {
          'airline': 'Wizz Air',
          'flight_number': 'W63005',
          'departure_times': generateFlightsMultipleTimesPerDay(
            startMonth: 7,
            endMonth: 9,
            year: 2025,
            times: [
              [8, 45],
              [9, 0],
              [12,15],
              [16,45],
              [19, 10],
            ],
          ),
          'duration_minutes': 150,
        },
        {
          'airline': 'Blue Air',
          'flight_number': '0B212',
          'departure_times': generateFlightsMultipleTimesPerDay(
            startMonth: 7,
            endMonth: 9,
            year: 2025,
            times: [
              [7, 0],
              [10,14],
              [13,30],
              [17, 30],
            ],
          ),
          'duration_minutes': 155,
        },
      ],
    },
    {
      'departure_city': 'București',
      'arrival_city': 'Milano',
      'flights': [
        {
          'airline': 'Wizz Air',
          'flight_number': 'W63001',
          'departure_times': generateFlightsMultipleTimesPerDay(
            startMonth: 7,
            endMonth: 9,
            year: 2025,
            times: [
              [9, 20],
              [12,15],
              [15, 30],
              [20, 50],
            ],
          ),
          'duration_minutes': 160,
        },
        {
          'airline': 'Ryanair',
          'flight_number': 'FR4512',
          'departure_times': generateFlightsMultipleTimesPerDay(
            startMonth: 7,
            endMonth: 9,
            year: 2025,
            times: [
              [6, 15],
              [10,0],
              [13,30],
              [18, 0],
            ],
          ),
          'duration_minutes': 165,
        },
      ],
    },
    {
      'departure_city': 'București',
      'arrival_city': 'Veneția',
      'flights': [
        {
          'airline': 'Wizz Air',
          'flight_number': 'W63005',
          'departure_times': generateFlightsMultipleTimesPerDay(
            startMonth: 7,
            endMonth: 9,
            year: 2025,
            times: [
              [8, 45],
              [9, 0],
              [12,15],
              [16,45],
              [19, 10],
            ],
          ),
          'duration_minutes': 150,
        },
        {
          'airline': 'Blue Air',
          'flight_number': '0B212',
          'departure_times': generateFlightsMultipleTimesPerDay(
            startMonth: 7,
            endMonth: 9,
            year: 2025,
            times: [
              [7, 0],
              [10,14],
              [13,30],
              [17, 30],
            ],
          ),
          'duration_minutes': 155,
        },
      ],
    },

    {
      'departure_city': 'Iași',
      'arrival_city': 'Madrid',
      'flights': [
        {
          'airline': 'Iberia',
          'flight_number': 'IB789',
          'departure_times': generateFlightsMultipleTimesPerDay(
            startMonth: 7,
            endMonth: 9,
            year: 2025,
            times: [
              [12, 45],
              [23, 0],
              [5,15],
            ],
          ),
          'duration_minutes': 240,
        },
        {
          'airline': 'Blue Air',
          'flight_number': '0B123',
          'departure_times': generateFlightsMultipleTimesPerDay(
            startMonth: 7,
            endMonth: 9,
            year: 2025,
            times: [
              [9, 30],
              [11, 0],
              [17, 20],
            ],
          ),
          'duration_minutes': 245,
        },
        {
          'airline': 'Tarom',
          'flight_number': 'RO256',
          'departure_times': generateFlightsMultipleTimesPerDay(
            startMonth: 7,
            endMonth: 9,
            year: 2025,
            times: [
              [14, 0],
              [20, 15],
              [10,15],
              [12,0],
            ],
          ),
          'duration_minutes': 250,
        },
      ],
    },
    {
      'departure_city': 'Paris',
      'arrival_city': 'București',
      'flights': [
        {
          'airline': 'Air France',
          'flight_number': 'AF125',
          'departure_times': generateFlightsMultipleTimesPerDay(
            startMonth: 7,
            endMonth: 9,
            year: 2025,
            times: [
              [8, 0],
              [18, 30],
              [21,0],
            ],
          ),
          'duration_minutes': 180,
        },
        {
          'airline': 'Tarom',
          'flight_number': 'RO205',
          'departure_times': generateFlightsMultipleTimesPerDay(
            startMonth: 7,
            endMonth: 9,
            year: 2025,
            times: [
              [13, 0],
              [20, 45],
              [10,40],
              [20,0],
            ],
          ),
          'duration_minutes': 185,
        },
        {
          'airline': 'Wizz Air',
          'flight_number': 'W62390',
          'departure_times': generateFlightsMultipleTimesPerDay(
            startMonth: 7,
            endMonth: 9,
            year: 2025,
            times: [
              [18, 0],
              [20, 0],
              [16,30],
              [19,0],
            ],
          ),
          'duration_minutes': 180,
        },
      ],
    },
    {
      'departure_city': 'Berlin',
      'arrival_city': 'Cluj',
      'flights': [
        {
          'airline': 'Lufthansa',
          'flight_number': 'LH466',
          'departure_times': generateFlightsMultipleTimesPerDay(
            startMonth: 7,
            endMonth: 9,
            year: 2025,
            times: [
              [18, 0],
              [21, 30],
              [5,30],
            ],
          ),
          'duration_minutes': 150,
        },
        {
          'airline': 'Wizz Air',
          'flight_number': 'W62350',
          'departure_times': generateFlightsMultipleTimesPerDay(
            startMonth: 7,
            endMonth: 9,
            year: 2025,
            times: [
              [18, 15],
              [6, 0],
              [19,35],
              [20,0],
            ],
          ),
          'duration_minutes': 155,
        },
        {
          'airline': 'Tarom',
          'flight_number': 'RO298',
          'departure_times': generateFlightsMultipleTimesPerDay(
            startMonth: 7,
            endMonth: 9,
            year: 2025,
            times: [
              [14, 0],
              [20, 30],
              [10,45],
              [21,0],
            ],
          ),
          'duration_minutes': 155,
        },
      ],
    },
    {
      'departure_city': 'Madrid',
      'arrival_city': 'Iași',
      'flights': [
        {
          'airline': 'Iberia',
          'flight_number': 'IB790',
          'departure_times': generateFlightsMultipleTimesPerDay(
            startMonth: 7,
            endMonth: 9,
            year: 2025,
            times: [
              [12, 45],
              [23, 0],
              [21,30],
            ],
          ),
          'duration_minutes': 240,
        },
        {
          'airline': 'Blue Air',
          'flight_number': '0B129',
          'departure_times': generateFlightsMultipleTimesPerDay(
            startMonth: 7,
            endMonth: 9,
            year: 2025,
            times: [
              [9, 30],
              [19, 0],
              [17, 20],
            ],
          ),
          'duration_minutes': 245,
        },
        {
          'airline': 'Tarom',
          'flight_number': 'RO258',
          'departure_times': generateFlightsMultipleTimesPerDay(
            startMonth: 7,
            endMonth: 9,
            year: 2025,
            times: [
              [14, 30],
              [20, 15],
              [10,15],
              [22,0],
            ],
          ),
          'duration_minutes': 250,
        },
      ],
    },
  ];

  for (var route in routes) {
    for (var flight in route['flights']) {
      for (var departure in flight['departure_times']) {
        final arrival = departure.add(Duration(minutes: flight['duration_minutes']));
        final doc = firestore.collection('flights_mock').doc();
        final price = 80 + random.nextInt(120); // 80–200

        batch.set(doc, {
          'departure_city': route['departure_city'],
          'arrival_city': route['arrival_city'],
          'airline': flight['airline'],
          'flight_number': flight['flight_number'],
          'status': 'scheduled',
          'departure_time': Timestamp.fromDate(departure),
          'arrival_time': Timestamp.fromDate(arrival),
          'duration_minutes': flight['duration_minutes'],
          'price': price.toDouble(),
        });
      }
    }
  }

  await batch.commit();
  print("✅ Zborurile au fost importate cu succes în Firestore.");
}
