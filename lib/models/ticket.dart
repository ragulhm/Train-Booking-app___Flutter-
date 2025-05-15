import 'package:cloud_firestore/cloud_firestore.dart';

enum TicketStatus { confirmed, cancelled, completed }

class Ticket {
  final String id;
  final String userId;
  final String trainId;
  final String trainName;
  final String origin;
  final String destination;
  final DateTime departureTime;
  final DateTime arrivalTime;
  final String seatNumber;
  final double price;
  final TicketStatus status;
  final DateTime bookingTime;
  final String passengerName;
  final String? passengerEmail;
  final String? passengerPhone;
  final String? qrCode;
  final String trainClass;
  
  Ticket({
    required this.id,
    required this.userId,
    required this.trainId,
    required this.trainName,
    required this.origin,
    required this.destination,
    required this.departureTime,
    required this.arrivalTime,
    required this.seatNumber,
    required this.price,
    required this.status,
    required this.bookingTime,
    required this.passengerName,
    this.passengerEmail,
    this.passengerPhone,
    this.qrCode,
    required this.trainClass,
  });

  factory Ticket.fromFirestore(Map<String, dynamic> data, String id) {
    return Ticket(
      id: id,
      userId: data['userId'] ?? '',
      trainId: data['trainId'] ?? '',
      trainName: data['trainName'] ?? '',
      origin: data['origin'] ?? '',
      destination: data['destination'] ?? '',
      departureTime: (data['departureTime'] as Timestamp).toDate(),
      arrivalTime: (data['arrivalTime'] as Timestamp).toDate(),
      seatNumber: data['seatNumber'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      status: TicketStatus.values.firstWhere(
        (e) => e.toString() == 'TicketStatus.${data['status'] ?? 'confirmed'}',
        orElse: () => TicketStatus.confirmed,
      ),
      bookingTime: (data['bookingTime'] as Timestamp).toDate(),
      passengerName: data['passengerName'] ?? '',
      passengerEmail: data['passengerEmail'],
      passengerPhone: data['passengerPhone'],
      qrCode: data['qrCode'],
      trainClass: data['trainClass'] ?? 'Economy',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'trainId': trainId,
      'trainName': trainName,
      'origin': origin,
      'destination': destination,
      'departureTime': departureTime,
      'arrivalTime': arrivalTime,
      'seatNumber': seatNumber,
      'price': price,
      'status': status.toString().split('.').last,
      'bookingTime': bookingTime,
      'passengerName': passengerName,
      'passengerEmail': passengerEmail,
      'passengerPhone': passengerPhone,
      'qrCode': qrCode,
      'trainClass': trainClass,
    };
  }

  // Helper method to check if the ticket is for an upcoming journey
  bool get isUpcoming => departureTime.isAfter(DateTime.now());

  // Calculate duration of journey
  Duration get duration => arrivalTime.difference(departureTime);

  // Format duration as string
  String get formattedDuration {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    return '${hours}h ${minutes}m';
  }

  // Copy with method for creating a modified copy
  Ticket copyWith({
    String? id,
    String? userId,
    String? trainId,
    String? trainName,
    String? origin,
    String? destination,
    DateTime? departureTime,
    DateTime? arrivalTime,
    String? seatNumber,
    double? price,
    TicketStatus? status,
    DateTime? bookingTime,
    String? passengerName,
    String? passengerEmail,
    String? passengerPhone,
    String? qrCode,
    String? trainClass,
  }) {
    return Ticket(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      trainId: trainId ?? this.trainId,
      trainName: trainName ?? this.trainName,
      origin: origin ?? this.origin,
      destination: destination ?? this.destination,
      departureTime: departureTime ?? this.departureTime,
      arrivalTime: arrivalTime ?? this.arrivalTime,
      seatNumber: seatNumber ?? this.seatNumber,
      price: price ?? this.price,
      status: status ?? this.status,
      bookingTime: bookingTime ?? this.bookingTime,
      passengerName: passengerName ?? this.passengerName,
      passengerEmail: passengerEmail ?? this.passengerEmail,
      passengerPhone: passengerPhone ?? this.passengerPhone,
      qrCode: qrCode ?? this.qrCode,
      trainClass: trainClass ?? this.trainClass,
    );
  }
}
