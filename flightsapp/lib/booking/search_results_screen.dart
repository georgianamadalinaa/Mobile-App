import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'price_calendar.dart';
import 'filter_dialog.dart';
import '../services/flight_api_service.dart';
import 'passenger_form_screen.dart';

class SearchResultsScreen extends StatefulWidget {
  final String destination;
  final String departure;
  final String date;
  final String? returnDate;
  final int persons;
  final String? baggage;

  const SearchResultsScreen({
    super.key,
    required this.destination,
    required this.departure,
    required this.date,
    this.returnDate,
    required this.persons,
    required this.baggage,
  });

  @override
  State<SearchResultsScreen> createState() => _SearchResultsScreenState();
}

class _SearchResultsScreenState extends State<SearchResultsScreen> {
  List<Map<String, dynamic>> dusFlights = [];
  List<Map<String, dynamic>> intorsFlights = [];
  bool isLoading = true;
  double? maxPriceFilter;

  @override
  void initState() {
    super.initState();
    _fetchMatchingFlights();
  }

  String formatBaggage(String? baggage) {
    if (baggage == '1 bagaj mic') return 'Bagaj mic';
    if (baggage == '1 bagaj mare') return 'Bagaj mare';
    return 'Fără bagaj';
  }

  Future<List<Map<String, dynamic>>> _fetchFromFirebase({
    required String from,
    required String to,
    required DateTime date,
  }) async {
    final end = date.add(const Duration(days: 1));

    final snapshotMock = await FirebaseFirestore.instance
        .collection('flights_mock')
        .where('arrival_city', isEqualTo: to)
        .where('departure_city', isEqualTo: from)
        .where('departure_time', isGreaterThanOrEqualTo: Timestamp.fromDate(date))
        .where('departure_time', isLessThan: Timestamp.fromDate(end))
        .get();

    final snapshotApi = await FirebaseFirestore.instance
        .collection('flights_api')
        .where('arrival_city', isEqualTo: to)
        .where('departure_city', isEqualTo: from)
        .where('departure_time', isGreaterThanOrEqualTo: Timestamp.fromDate(date))
        .where('departure_time', isLessThan: Timestamp.fromDate(end))
        .get();

    return [
      ...snapshotMock.docs.map((doc) => doc.data() as Map<String, dynamic>),
      ...snapshotApi.docs.map((doc) => doc.data() as Map<String, dynamic>),
    ];
  }

  Future<List<Map<String, dynamic>>> _fetchFromApi({
    required String from,
    required String to,
    required DateTime date,
  }) async {
    final end = date.add(const Duration(days: 1));
    final apiService = FlightApiService();
    final all = await apiService.fetchFlights();

    return all.where((flight) {
      final arrival = flight['arrival_city']?.toLowerCase();
      final departure = flight['departure_city']?.toLowerCase();
      final timeRaw = flight['departure_time'];
      DateTime? time;
      if (timeRaw is Timestamp) time = timeRaw.toDate();
      else if (timeRaw is String) time = DateTime.tryParse(timeRaw);

      return arrival == to.toLowerCase() &&
          departure == from.toLowerCase() &&
          time != null &&
          time.isAfter(date) &&
          time.isBefore(end);
    }).toList();
  }

  Future<void> _fetchMatchingFlights() async {
    final DateTime dateGo = DateTime.parse(widget.date);
    final from = widget.departure;
    final to = widget.destination;

    final dusFirebase = await _fetchFromFirebase(from: from, to: to, date: dateGo);
    final dusApi = await _fetchFromApi(from: from, to: to, date: dateGo);
    List<Map<String, dynamic>> dusAll = [...dusFirebase, ...dusApi];

    List<Map<String, dynamic>> intorsAll = [];

    if (widget.returnDate != null && widget.returnDate!.isNotEmpty) {
      final DateTime dateReturn = DateTime.parse(widget.returnDate!);
      final intorsFirebase = await _fetchFromFirebase(from: to, to: from, date: dateReturn);
      final intorsApi = await _fetchFromApi(from: to, to: from, date: dateReturn);
      intorsAll = [...intorsFirebase, ...intorsApi];
    }

    setState(() {
      dusFlights = dusAll;
      intorsFlights = intorsAll;
      isLoading = false;
    });
  }

  List<Widget> buildFlightSection(List<Map<String, dynamic>> flights, String title) {
    final filtered = maxPriceFilter != null
        ? flights.where((f) {
      final base = (f['price'] ?? 0) as num;
      int extra = 0;
      if (widget.baggage == '1 bagaj mic') extra = 15;
      if (widget.baggage == '1 bagaj mare') extra = 40;
      return (base + extra) * widget.persons <= maxPriceFilter!;
    }).toList()
        : flights;

    if (filtered.isEmpty) return [];

    return [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
        child: Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
      ),
      ...filtered.map((flight) => buildFlightCard(flight)).toList()
    ];
  }

  Widget buildFlightCard(Map<String, dynamic> flight) {
    final depTimeRaw = flight['departure_time'];
    final depTime = depTimeRaw is Timestamp
        ? depTimeRaw.toDate()
        : DateTime.tryParse(depTimeRaw.toString()) ?? DateTime.now();
    final duration = flight['duration_minutes'] ?? 120;
    final arrTime = depTime.add(Duration(minutes: duration));

    final pricePerPerson = flight['price'] ?? 100;
    int baggageCostPerPerson = 0;
    if (widget.baggage == '1 bagaj mic') baggageCostPerPerson = 15;
    else if (widget.baggage == '1 bagaj mare') baggageCostPerPerson = 40;

    final totalPrice = (pricePerPerson + baggageCostPerPerson) * widget.persons;
    final formattedPrice = NumberFormat.currency(locale: 'ro_RO', symbol: '€', decimalDigits: 0).format(totalPrice);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${flight['departure_city'] ?? flight['departure_airport']} → ${flight['arrival_city'] ?? flight['arrival_airport']}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  formattedPrice,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.green),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text('${flight['airline'] ?? 'Companie'} • ${flight['flight_number'] ?? ''}'),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(DateFormat('HH:mm').format(depTime),
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(6)),
                  child: Text('$duration min', style: const TextStyle(fontSize: 12)),
                ),
                const Spacer(),
                Text(DateFormat('HH:mm').format(arrTime),
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Text('${flight['departure_city'] ?? flight['departure_airport']}', style: const TextStyle(color: Colors.grey)),
                const Spacer(),
                const Text('Direct'),
                const Spacer(),
                Text('${flight['arrival_city'] ?? flight['arrival_airport']}', style: const TextStyle(color: Colors.grey)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.person, size: 18),
                const SizedBox(width: 4),
                Text('${widget.persons} pers'),
                const SizedBox(width: 16),
                const Icon(Icons.work, size: 18),
                const SizedBox(width: 4),
                Text(formatBaggage(widget.baggage)),
                const Spacer(),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PassengerFormScreen(
                          flight: flight,
                          baggage: widget.baggage,
                          persons: widget.persons,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text("Rezervă"),
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dusDate = DateFormat('dd MMM yyyy').format(DateTime.parse(widget.date));
    final intorsDate = widget.returnDate != null
        ? DateFormat('dd MMM yyyy').format(DateTime.parse(widget.returnDate!))
        : null;

    final allItems = [
      ...buildFlightSection(dusFlights, '✈️ Zboruri dus – $dusDate'),
      if (intorsDate != null && intorsFlights.isNotEmpty)
        const Divider(),
      if (intorsDate != null && intorsFlights.isNotEmpty)
        ...buildFlightSection(intorsFlights, '🔁 Zboruri întors – $intorsDate'),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rezultate căutare'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    "${widget.departure} ↔ ${widget.destination}",
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    final prices = [...dusFlights, ...intorsFlights]
                        .map((f) => (f['price'] ?? 0) as num)
                        .map((p) => p.toDouble())
                        .toList();
                    if (prices.isEmpty) return;

                    final min = prices.reduce((a, b) => a < b ? a : b);
                    final max = prices.reduce((a, b) => a > b ? a : b);

                    showDialog(
                      context: context,
                      builder: (_) => FilterDialog(
                        minPrice: min,
                        maxPrice: max,
                        selectedMaxPrice: maxPriceFilter ?? max,
                        onApply: (val) => setState(() => maxPriceFilter = val),
                      ),
                    );
                  },
                  icon: const Icon(Icons.filter_alt),
                  label: const Text("Filtru Preț"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightBlueAccent,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PriceCalendarScreen(baseDate: widget.date),
                  ),
                );
              },
              child: const Text("Grafice de prețuri"),
            ),
          ),
          const Divider(),
          if (allItems.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text("Nu s-au găsit zboruri după filtrele aplicate."),
            ),
          if (allItems.isNotEmpty)
            Expanded(child: ListView(children: allItems)),
        ],
      ),
    );
  }
}
