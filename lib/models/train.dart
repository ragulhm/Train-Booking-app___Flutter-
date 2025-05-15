class Train {
  final String id;
  final String name;
  final String origin;
  final String destination;
  final DateTime departureTime;
  final DateTime arrivalTime;
  final double price;
  final String trainClass;
  final int availableSeats;

  Train({
    required this.id,
    required this.name,
    required this.origin,
    required this.destination,
    required this.departureTime,
    required this.arrivalTime,
    required this.price,
    required this.trainClass,
    required this.availableSeats,
  });

  // Create a Train from a Map (JSON) data
  factory Train.fromMap(Map<String, dynamic> data) {
    // Parse departure and arrival times from ISO strings instead of Timestamps
    DateTime parseDateTime(dynamic value) {
      if (value is String) {
        return DateTime.parse(value);
      } else if (value is DateTime) {
        return value;
      }
      // Default date if unable to parse
      return DateTime.now();
    }

    return Train(
      id: data['id'] ?? 'unknown',
      name: data['name'] ?? 'Unknown Train',
      origin: data['origin'] ?? '',
      destination: data['destination'] ?? '',
      departureTime: parseDateTime(data['departureTime']),
      arrivalTime: parseDateTime(data['arrivalTime']),
      price: (data['price'] is num) ? (data['price'] as num).toDouble() : 0.0,
      trainClass: data['class'] ?? 'Standard',
      availableSeats: (data['availableSeats'] is num) ? (data['availableSeats'] as num).toInt() : 0,
    );
  }

  // Convert Train to a Map (for JSON serialization)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'origin': origin,
      'destination': destination,
      'departureTime': departureTime.toIso8601String(),
      'arrivalTime': arrivalTime.toIso8601String(),
      'price': price,
      'class': trainClass,
      'availableSeats': availableSeats,
    };
  }
}

// Booking model
class Booking {
  final String id;
  final String userId;
  final String trainId;
  final String trainName;
  final String origin;
  final String destination;
  final DateTime departureTime;
  final DateTime arrivalTime;
  final String seatNumber;
  final String trainClass;
  final double price;
  final DateTime bookingDate;
  final String status;

  Booking({
    required this.id,
    required this.userId,
    required this.trainId,
    required this.trainName,
    required this.origin,
    required this.destination,
    required this.departureTime,
    required this.arrivalTime,
    required this.seatNumber,
    required this.trainClass,
    required this.price,
    required this.bookingDate,
    required this.status,
  });

  // Create a Booking from a Map (JSON) data
  factory Booking.fromMap(Map<String, dynamic> data) {
    // Parse dates from ISO strings instead of Timestamps
    DateTime parseDateTime(dynamic value) {
      if (value is String) {
        return DateTime.parse(value);
      } else if (value is DateTime) {
        return value;
      }
      // Default date if unable to parse
      return DateTime.now();
    }

    return Booking(
      id: data['id'] ?? 'unknown',
      userId: data['user_id'] ?? '',
      trainId: data['train_id'] ?? '',
      trainName: data['train_name'] ?? 'Unknown Train',
      origin: data['from'] ?? '',
      destination: data['to'] ?? '',
      departureTime: parseDateTime(data['departure_time']),
      arrivalTime: parseDateTime(data['arrival_time']),
      seatNumber: data['seat'] ?? '',
      trainClass: data['class'] ?? 'Standard',
      price: (data['price'] is num) ? (data['price'] as num).toDouble() : 0.0,
      bookingDate: parseDateTime(data['booking_date']),
      status: data['status'] ?? 'pending',
    );
  }

  // Convert Booking to a Map (for JSON serialization)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'train_id': trainId,
      'train_name': trainName,
      'from': origin,
      'to': destination,
      'departure_time': departureTime.toIso8601String(),
      'arrival_time': arrivalTime.toIso8601String(),
      'seat': seatNumber,
      'class': trainClass,
      'price': price,
      'booking_date': bookingDate.toIso8601String(),
      'status': status,
    };
  }
}