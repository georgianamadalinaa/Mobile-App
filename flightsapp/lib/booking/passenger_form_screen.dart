import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../user/profile_screen.dart';
import 'baggage_selection_screen.dart';
import '../models/booking_data.dart';
import '../models/booking.dart';

class PassengerFormScreen extends StatefulWidget {
  final Map<String, dynamic> flight;
  final String? baggage;
  final int persons;

  const PassengerFormScreen({
    super.key,
    required this.flight,
    required this.baggage,
    required this.persons,
  });

  @override
  State<PassengerFormScreen> createState() => _PassengerFormScreenState();
}

class _PassengerFormScreenState extends State<PassengerFormScreen> {
  final List<GlobalKey<FormState>> _formKeys = [];
  final List<Map<String, dynamic>> _controllersList = [];

  User? user;

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser;
    for (int i = 0; i < widget.persons; i++) {
      _addNewPassengerForm();
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (user == null) _showLoginPrompt();
    });
  }

  void _showLoginPrompt() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.login, size: 48, color: Colors.blueAccent),
              const SizedBox(height: 16),
              const Text(
                "Doriți să vă conectați mai întâi?",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              const Text(
                "Veți putea să rezervați mai rapid, să configurați alerte de prețuri și să vă vedeți toate călătoriile într-un singur loc.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.black54),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Continuați ca vizitator"),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const ProfileScreen()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text("Conectați-vă"),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _addNewPassengerForm() {
    final Map<String, dynamic> newControllers = {
      'name': TextEditingController(),
      'surname': TextEditingController(),
      'email': TextEditingController(),
      'phone': TextEditingController(),
      'birthDate': null,
      'nationality': null,
      'gender': null,
      'insurance': null,
    };
    _formKeys.add(GlobalKey<FormState>());
    _controllersList.add(newControllers);
    setState(() {});
  }

  Future<void> _selectDate(int index) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _controllersList[index]['birthDate'] = picked);
    }
  }

  String _formatDateTime(dynamic timestamp) {
    final dateTime = _parseDateTime(timestamp);
    if (dateTime == null) return "necunoscut";
    return DateFormat('dd MMM yyyy, HH:mm').format(dateTime);
  }

  DateTime? _parseDateTime(dynamic timestamp) {
    if (timestamp is Timestamp) return timestamp.toDate();
    if (timestamp is DateTime) return timestamp;
    return null;
  }

  // MODIFICARE: Funcție pentru calcularea prețului total
  double getTicketPrice() {
    double basePrice = (widget.flight['price'] ?? 0) * _controllersList.length;

    // Cost total pentru asigurări
    double insuranceTotal = 0;
    for (var c in _controllersList) {
      if (c['insurance'] == "Travel Basic") {
        insuranceTotal += 1.5;
      }
    }

    // Cost total pentru bagaje
    int baggageCostPerPerson = 0;
    if (widget.baggage == '1 bagaj mic') {
      baggageCostPerPerson = 15;
    } else if (widget.baggage == '1 bagaj mare') {
      baggageCostPerPerson = 40;
    }
    double baggageTotal = baggageCostPerPerson.toDouble() * _controllersList.length;


    return basePrice + insuranceTotal + baggageTotal;
  }


  void _finalizeReservation() {
    List<Map<String, dynamic>> passengers = [];

    for (int i = 0; i < _formKeys.length; i++) {
      if (!(_formKeys[i].currentState?.validate() ?? false)) return;

      final c = _controllersList[i];
      if (c['birthDate'] == null || c['nationality'] == null || c['gender'] == null || c['insurance'] == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Toate câmpurile trebuie completate.")),
        );
        return;
      }

      // MODIFICARE: Email doar pentru pasager principal, pentru ceilalți '' (sau îl poți exclude complet)
      passengers.add({
        'name': c['name'].text,
        'surname': c['surname'].text,
        'email': i == 0 ? c['email'].text : '', // email doar la primul
        'phone': c['phone'].text,
        'birthDate': c['birthDate'].toIso8601String(),
        'nationality': c['nationality'],
        'gender': c['gender'],
        'insurance': c['insurance'],
      });
    }

    print("REZERVARE FINALIZATĂ:");
    for (var p in passengers) {
      print(p);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Rezervare trimisă cu succes!")),
    );
  }

  @override
  Widget build(BuildContext context) {
    final flight = widget.flight;
    final depTime = _parseDateTime(flight['departure_time']);
    final arrTime = _parseDateTime(flight['arrival_time']);
    final durationMinutes = depTime != null && arrTime != null
        ? arrTime.difference(depTime).inMinutes
        : null;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightBlueAccent,
        elevation: 1,
        centerTitle: true,
        title: Text(
          "${flight['departure_city']} → ${flight['arrival_city']}",
          style: const TextStyle(color: Colors.black87),
        ),
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            "Informații generale despre călătorie",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blueGrey[100],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blueGrey),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  const Icon(Icons.flight_takeoff, color: Colors.purple),
                  const SizedBox(width: 8),
                  Text("${flight['departure_city']} • ${_formatDateTime(flight['departure_time'])}"),
                ]),
                const SizedBox(height: 6),
                Row(children: [
                  const Icon(Icons.flight_land, color: Colors.green),
                  const SizedBox(width: 8),
                  Text("${flight['arrival_city']} • ${_formatDateTime(flight['arrival_time'])}"),
                ]),
                if (durationMinutes != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Row(children: [
                      const Icon(Icons.schedule, color: Colors.blueGrey),
                      const SizedBox(width: 8),
                      Text("Durată: $durationMinutes min",
                          style: const TextStyle(fontStyle: FontStyle.italic)),
                    ]),
                  ),
                const SizedBox(height: 8),
                Text("Companie: ${flight['airline'] ?? 'N/A'}"),
                Text("Bagaj: ${widget.baggage ?? 'Fără'}"),
              ],
            ),
          ),

          const SizedBox(height: 20),

          ...List.generate(_controllersList.length, (index) {
            final c = _controllersList[index];
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Form(
                key: _formKeys[index],
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      index == 0 ? "Pasager principal" : "Pasager ${index + 1}",
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    TextFormField(
                      controller: c['name'],
                      decoration: const InputDecoration(labelText: 'Prenume'),
                      validator: (value) => value!.isEmpty ? 'Introduceți prenumele' : null,
                    ),
                    TextFormField(
                      controller: c['surname'],
                      decoration: const InputDecoration(labelText: 'Nume'),
                      validator: (value) => value!.isEmpty ? 'Introduceți numele' : null,
                    ),
                    // MODIFICARE: Email doar pentru pasagerul principal
                    if (index == 0)
                      TextFormField(
                        controller: c['email'],
                        decoration: const InputDecoration(labelText: 'Email'),
                        validator: (value) => value!.isEmpty ? 'Introduceți emailul' : null,
                      ),
                    TextFormField(
                      controller: c['phone'],
                      decoration: const InputDecoration(labelText: 'Telefon'),
                      validator: (value) => value!.isEmpty ? 'Introduceți telefonul' : null,
                    ),
                    const SizedBox(height: 12),
                    Row(children: [
                      const Text("Data nașterii: "),
                      Text(c['birthDate'] == null
                          ? "Selectați"
                          : DateFormat('dd.MM.yyyy').format(c['birthDate'])),
                      const Spacer(),
                      IconButton(
                        onPressed: () => _selectDate(index),
                        icon: const Icon(Icons.calendar_today),
                      ),
                    ]),
                    DropdownButtonFormField<String>(
                      value: c['nationality'],
                      hint: const Text("Naționalitate"),
                      items: ['Română', 'Maghiară', 'Engleză', 'Altă']
                          .map((n) => DropdownMenuItem(value: n, child: Text(n)))
                          .toList(),
                      onChanged: (value) => setState(() => c['nationality'] = value),
                    ),
                    DropdownButtonFormField<String>(
                      value: c['gender'],
                      hint: const Text("Sex"),
                      items: ['Masculin', 'Feminin', 'Altul']
                          .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                          .toList(),
                      onChanged: (value) => setState(() => c['gender'] = value),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Icon(Icons.health_and_safety, color: Colors.redAccent),
                        const SizedBox(width: 8),
                        const Text(
                          "Asigurare de călătorie",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    RadioListTile<String>(
                      title: const Text("Travel Basic (1.50€/zi) - 6000€ medical + rambursare"),
                      value: "Travel Basic",
                      groupValue: c['insurance'],
                      onChanged: (value) => setState(() => c['insurance'] = value),
                    ),
                    RadioListTile<String>(
                      title: const Text("Fără asigurare"),
                      value: "Fără asigurare",
                      groupValue: c['insurance'],
                      onChanged: (value) => setState(() => c['insurance'] = value),
                    ),
                  ],
                ),
              ),
            );
          }),

          const SizedBox(height: 16),
          // MODIFICARE: Afișează preț total
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(
              "Total: ${getTicketPrice().toStringAsFixed(2)} €",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          const Text(
            "Rezervați pentru mai mulți pasageri?",
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: _addNewPassengerForm,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              foregroundColor: Colors.white, // culoarea textului
            ),
            child: const Text("Adaugă pasager"),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              List<Map<String, dynamic>> passengers = [];

              for (int i = 0; i < _formKeys.length; i++) {
                if (!(_formKeys[i].currentState?.validate() ?? false)) return;

                final c = _controllersList[i];
                if (c['birthDate'] == null || c['nationality'] == null || c['gender'] == null || c['insurance'] == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Toate câmpurile trebuie completate.")),
                  );
                  return;
                }

                passengers.add({
                  'name': c['name'].text,
                  'surname': c['surname'].text,
                  'email': i == 0 ? c['email'].text : '', // MODIFICARE: email doar la primul
                  'phone': c['phone'].text,
                  'birthDate': c['birthDate'].toIso8601String(),
                  'nationality': c['nationality'],
                  'gender': c['gender'],
                  'insurance': c['insurance'],
                });
              }

              // Preluăm datele zborului
              final flight = widget.flight;
              final email = _controllersList[0]['email'].text; // emailul pasagerului principal
              final destination = flight['arrival_city'];
              final departureDate = _formatDateTime(flight['departure_time']);

              // MODIFICARE: Salvăm suma corectă
              BookingData.currentBooking = Booking(
                email: email,
                destination: destination,
                departureDate: departureDate,
                seat: '',           // se va adăuga mai târziu
                hasBaggage: false,  // se setează ulterior
                price: getTicketPrice(), // MODIFICARE: preț total
              );

              // Navigăm mai departe (poți transmite și lista de pasageri dacă vrei la seat selection)
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>  BaggageSelectionScreen(
                    passengers: passengers,
                    flight: widget.flight,
                    baggage: widget.baggage,
                    basePrice: getTicketPrice(),),

                ),
              );
            },

            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white, // culoarea textului
            ),
            child: const Text("Finalizează rezervarea"),
          ),

        ],
      ),
    );
  }
}
