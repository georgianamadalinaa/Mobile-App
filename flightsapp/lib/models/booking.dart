
class Booking {
  String email;
  String destination;
  String departureDate;
  String seat;
  bool hasBaggage;
  double price;

  Booking({
    required this.email,
    required this.destination,
    required this.departureDate,
    required this.seat,
    required this.hasBaggage,
    required this.price,
  });
}
