import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../services/firestore_service.dart';
import '../services/flight_api_service.dart';
import '../user/profile_screen.dart';
import 'offers_screen.dart';
import 'search_results_screen.dart';
import 'flights.dart';
import '../user/my_trips_screen.dart';
import '../notifications/notification_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? selectedDestination;
  String? selectedDeparture;
  String? selectedBaggage;
  int selectedPersons = 1;

  DateTime? departureDate;
  DateTime? returnDate;

  User? user;

  List<String> destinations = [];
  final List<String> departures = ['București', 'Cluj', 'Iași', 'Madrid','Berlin','Paris','Veneția','Milano'];
  final List<String> baggageOptions = ['Fără bagaj', '1 bagaj mic', '1 bagaj mare'];

  @override
  void initState() {
    super.initState();
    FirebaseAuth.instance.authStateChanges().listen((event) {
      setState(() {
        user = event;
      });
    });
    _loadDestinations();
    final userEmail = FirebaseAuth.instance.currentUser?.email;
    if (userEmail != null) {
      NotificationService.checkFlightsAndNotify(userEmail);
    }
  }
  Future<void> _loadDestinations() async {
    final uniqueAirports = <String>{};

    // 🔹 Zboruri mock (au arrival_city)
    final mockSnapshot = await FirebaseFirestore.instance.collection('flights_mock').get();
    for (var doc in mockSnapshot.docs) {
      final airport = doc['arrival_city'];
      if (airport != null && airport.toString().trim().isNotEmpty) {
        uniqueAirports.add(airport.toString().trim());
      }
    }

    // 🔹 Zboruri API (pot avea doar arrival_airport)
    final apiSnapshot = await FirebaseFirestore.instance.collection('flights_api').get();
    for (var doc in apiSnapshot.docs) {
      final airport = doc['arrival_city'] ?? doc['arrival_airport'];
      if (airport != null && airport.toString().trim().isNotEmpty) {
        uniqueAirports.add(airport.toString().trim());
      }
    }

    setState(() {
      destinations = uniqueAirports.toList()..sort();
    });
  }


  Future<void> importApiFlights() async {
    try {
      final apiService = FlightApiService();
      final firestoreService = FirestoreService();

      final flights = await apiService.fetchFlights();

      await firestoreService.saveFlights(flights);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Zboruri importate cu succes.")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Eroare la import: $e")),
      );
    }
  }


  String _getInitial(User? user) {
    if (user == null) return '?';
    if (user.displayName != null && user.displayName!.trim().isNotEmpty) {
      return user.displayName!.trim()[0].toUpperCase();
    }
    if (user.email != null && user.email!.isNotEmpty) {
      return user.email![0].toUpperCase();
    }
    return '?';
  }

  Future<void> _selectDate(bool isDeparture) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        if (isDeparture) {
          departureDate = picked;
        } else {
          returnDate = picked;
        }
      });
    }
  }

  String _formatDate(DateTime? date) {
    return date == null ? 'Selectează data' : DateFormat('dd.MM.yyyy').format(date);
  }

  void _searchFlights() {
    if (selectedDestination != null && departureDate != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => SearchResultsScreen(
            destination: selectedDestination!,
            departure: selectedDeparture!,
            date: DateFormat('yyyy-MM-dd').format(departureDate!),
            returnDate: returnDate != null
                ? DateFormat('yyyy-MM-dd').format(returnDate!)
                : null,
            persons: selectedPersons,
            baggage: selectedBaggage,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Selectează o destinație și o dată pentru căutare")),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.flight_takeoff, color: Colors.lightBlueAccent),
                      SizedBox(width: 8),
                      Text(
                        "Volaris",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.lightBlueAccent,
                        ),
                      ),
                    ],
                  ),
                  if (user == null)
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const ProfileScreen()),
                        );
                      },
                      child: const Text(
                        "Conectați-vă",
                        style: TextStyle(color: Colors.lightBlueAccent),
                      ),
                    )
                  else
                    PopupMenuButton<String>(
                      onSelected: (value) async {
                        if (value == 'logout') {
                          await FirebaseAuth.instance.signOut();
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem<String>(
                          value: 'logout',
                          child: Text('Delogare'),
                        ),
                      ],
                      child: CircleAvatar(
                        backgroundColor: Colors.lightBlueAccent,
                        child: Text(
                          _getInitial(user),
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 8),
              if (user != null)
                Row(
                  children: [
                    const SizedBox(width: 4),
                    Text(
                      "Salut, ${user!.displayName ?? user!.email}!",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),

              const SizedBox(height: 24),
              const Text(
                "Care este următoarea ta destinație?",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

             // ElevatedButton(
               // onPressed: () async {
                 // try {
                  //  await importMockFlights();    // 🔹 importă zboruri mock
                  //  await importApiFlights();     // 🔹 importă zboruri reale din API
                  //  await _loadDestinations();    // 🔁 actualizează dropdown

                   // ScaffoldMessenger.of(context).showSnackBar(
                   //   const SnackBar(content: Text("Toate zborurile au fost importate cu succes.")),
                  //  );
                 // } catch (e) {
                 //   ScaffoldMessenger.of(context).showSnackBar(
                 //     SnackBar(content: Text("Eroare la import: $e")),
                 //   );
               //   }
              //  },
                //style: ElevatedButton.styleFrom(
               //   backgroundColor: Colors.deepPurple,
               //   foregroundColor: Colors.white,
              //  ),
              //  child: const Text("Importă zboruri (mock + API)"),
             // ),


              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: "Destinație"),
                isExpanded: true, // adaugă acest flag!
                value: selectedDestination,
                items: destinations
                    .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                    .toList(),
                onChanged: (value) => setState(() => selectedDestination = value),
              ),

              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: "Plecare din"),
                value: selectedDeparture,
                items: departures
                    .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                    .toList(),
                onChanged: (value) => setState(() => selectedDeparture = value),
              ),

              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Persoane", style: TextStyle(fontWeight: FontWeight.w600)),
                        DropdownButton<int>(
                          value: selectedPersons,
                          isExpanded: true,
                          onChanged: (value) {
                            setState(() => selectedPersons = value ?? 1);
                          },
                          items: List.generate(9, (index) => index + 1)
                              .map((p) => DropdownMenuItem(value: p, child: Text("$p")))
                              .toList(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Bagaj", style: TextStyle(fontWeight: FontWeight.w600)),
                        DropdownButton<String>(
                          value: selectedBaggage,
                          isExpanded: true,
                          onChanged: (value) {
                            setState(() => selectedBaggage = value);
                          },
                          items: baggageOptions
                              .map((b) => DropdownMenuItem(value: b, child: Text(b)))
                              .toList(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _selectDate(true),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                "Dus: ${_formatDate(departureDate)}",
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _selectDate(false),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today_outlined, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                "Întors: ${_formatDate(returnDate)}",
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _searchFlights ,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightBlueAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "Caută",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),

              const SizedBox(height: 24),
              const Text(
                "Recomandări pentru tine",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _buildAdCard(
                    context,
                    title: "Booking.com",
                    description: "Găsește cele mai bune cazări!",
                    url: "https://www.booking.com",
                    icon: Icons.hotel,
                  ),
                  _buildAdCard(
                    context,
                    title: "Transport local",
                    description: "Rezervă-ți transferul ușor!",
                    url: "https://www.rome2rio.com",
                    icon: Icons.directions_bus,
                  ),
                  _buildAdCard(
                    context,
                    title: "Închirieri mașini",
                    description: "Descoperă oferte pentru mașini!",
                    url: "https://www.rentalcars.com",
                    icon: Icons.directions_car,
                  ),
                  _buildAdCard(
                    context,
                    title: "Activități și tururi",
                    description: "Explorează excursii și atracții!",
                    url: "https://www.getyourguide.com",
                    icon: Icons.explore,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color.fromRGBO(230, 245, 255, 1),
        currentIndex: 0,
        onTap: (index) {
          if (index == 1) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const OffersScreen()));
          }
          else if (index == 2) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const MyTripsScreen()));
          }else if (index == 3) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
          }
        },
        selectedItemColor: Colors.lightBlueAccent,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.search), label: "Acasă"),
          BottomNavigationBarItem(icon: Icon(Icons.local_offer), label: "Oferte"),
          BottomNavigationBarItem(icon: Icon(Icons.flight), label: "Călătoriile mele"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profil"),
        ],
      ),
    );
  }
}

Widget _buildAdCard(BuildContext context, {
  required String title,
  required String description,
  required String url,
  required IconData icon,
}) {
  return GestureDetector(
    onTap: () async {
      final uri = Uri.parse(url);
      try {
        if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
          if (!await launchUrl(uri, mode: LaunchMode.inAppWebView)) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Nu se poate deschide linkul")),
            );
          }
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Eroare: $e")),
        );
      }
    },
    child: Container(
      width: MediaQuery.of(context).size.width / 2 - 24,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 32, color: Colors.lightBlueAccent),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 4),
          Text(description, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    ),
  );
}
