import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminAddFlightScreen extends StatefulWidget {
  const AdminAddFlightScreen({super.key});

  @override
  State<AdminAddFlightScreen> createState() => _AdminAddFlightScreenState();
}

class _AdminAddFlightScreenState extends State<AdminAddFlightScreen> {
  final _formKey = GlobalKey<FormState>();
  final _plecareController = TextEditingController();
  final _destinatieController = TextEditingController();
  final _pretController = TextEditingController();

  DateTime? _selectedDateTime;

  @override
  void dispose() {
    _plecareController.dispose();
    _destinatieController.dispose();
    _pretController.dispose();
    super.dispose();
  }

  Future<void> _selectDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );

    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 9, minute: 0),
    );

    if (time == null) return;

    setState(() {
      _selectedDateTime = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  Future<void> _adaugaZbor() async {
    if (!_formKey.currentState!.validate() || _selectedDateTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Completează toate câmpurile și selectează data/ora")),
      );
      return;
    }

    final plecare = _plecareController.text.trim();
    final destinatie = _destinatieController.text.trim();
    final pret = int.tryParse(_pretController.text.trim()) ?? 0;
    final durata = 90; // default, poți face calcul în funcție de ora sosire

    final zbor = {
      'airline': 'Manual Flight',
      'departure_city': plecare,
      'arrival_city': destinatie,
      'departure_time': _selectedDateTime,
      'arrival_time': _selectedDateTime!.add(Duration(minutes: durata)),
      'duration_minutes': durata,
      'flight_number': 'MAN${DateTime.now().millisecondsSinceEpoch % 10000}',
      'price': pret,
      'status': 'scheduled',
    };

    await FirebaseFirestore.instance.collection('flights_mock').add(zbor);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Zbor adăugat cu succes")),
    );

    _plecareController.clear();
    _destinatieController.clear();
    _pretController.clear();
    setState(() => _selectedDateTime = null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Adaugă zbor manual")),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _plecareController,
                decoration: const InputDecoration(labelText: "Loc plecare"),
                validator: (v) => v == null || v.isEmpty ? "Completează plecarea" : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _destinatieController,
                decoration: const InputDecoration(labelText: "Destinație"),
                validator: (v) => v == null || v.isEmpty ? "Completează destinația" : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _pretController,
                decoration: const InputDecoration(labelText: "Preț (Euro)"),
                keyboardType: TextInputType.number,
                validator: (v) => v == null || v.isEmpty ? "Introdu un preț" : null,
              ),
              const SizedBox(height: 16),
              ListTile(
                title: Text(
                  _selectedDateTime == null
                      ? "Selectează data și ora plecării"
                      : "Plecare: ${_selectedDateTime!.toLocal()}",
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: _selectDateTime,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _adaugaZbor,
                child: const Text("Adaugă zbor"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
