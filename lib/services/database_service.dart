import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/train.dart';
import '../models/ticket.dart';
import '../models/user.dart';

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection references
  final CollectionReference usersCollection = FirebaseFirestore.instance.collection('users');
  final CollectionReference trainsCollection = FirebaseFirestore.instance.collection('trains');
  final CollectionReference ticketsCollection = FirebaseFirestore.instance.collection('tickets');

  // User operations
  Future<void> updateUserData(UserModel user) async {
    return await usersCollection.doc(user.uid).set(user.toMap(), SetOptions(merge: true));
  }

  Future<UserModel?> getUserData(String uid) async {
    DocumentSnapshot doc = await usersCollection.doc(uid).get();
    if (doc.exists) {
      return UserModel.fromFirestore(doc.data() as Map<String, dynamic>, doc.id);
    }
    return null;
  }

  // Train operations
  Stream<List<Train>> getTrains() {
    return trainsCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Train.fromFirestore(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  Stream<List<Train>> getTrainsByRoute(String origin, String destination) {
    return trainsCollection
        .where('origin', isEqualTo: origin)
        .where('destination', isEqualTo: destination)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Train.fromFirestore(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  Future<Train?> getTrainById(String trainId) async {
    DocumentSnapshot doc = await trainsCollection.doc(trainId).get();
    if (doc.exists) {
      return Train.fromFirestore(doc.data() as Map<String, dynamic>, doc.id);
    }
    return null;
  }

  // Seat operations
  Stream<List<TrainSeat>> getAvailableSeats(String trainId) {
    return trainsCollection
        .doc(trainId)
        .collection('seats')
        .where('isAvailable', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return TrainSeat.fromFirestore(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  Future<TrainSeat?> getSeatById(String trainId, String seatId) async {
    DocumentSnapshot doc =
        await trainsCollection.doc(trainId).collection('seats').doc(seatId).get();
    if (doc.exists) {
      return TrainSeat.fromFirestore(doc.data() as Map<String, dynamic>, doc.id);
    }
    return null;
  }

  // Ticket operations
  Future<String> bookTicket(Ticket ticket) async {
    try {
      // Create a new ticket
      DocumentReference ticketRef = await ticketsCollection.add(ticket.toMap());
      
      // Update the seat availability
      await trainsCollection
          .doc(ticket.trainId)
          .collection('seats')
          .doc(ticket.seatNumber)
          .update({'isAvailable': false});
      
      // Update available seats count
      DocumentSnapshot trainDoc = await trainsCollection.doc(ticket.trainId).get();
      if (trainDoc.exists) {
        int availableSeats = (trainDoc.data() as Map<String, dynamic>)['availableSeats'] ?? 0;
        await trainsCollection.doc(ticket.trainId).update({
          'availableSeats': availableSeats - 1,
        });
      }
      
      return ticketRef.id;
    } catch (e) {
      print('Error booking ticket: $e');
      rethrow;
    }
  }

  Stream<List<Ticket>> getUserTickets(String userId) {
    return ticketsCollection
        .where('userId', isEqualTo: userId)
        .orderBy('departureTime', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Ticket.fromFirestore(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  Future<Ticket?> getTicketById(String ticketId) async {
    DocumentSnapshot doc = await ticketsCollection.doc(ticketId).get();
    if (doc.exists) {
      return Ticket.fromFirestore(doc.data() as Map<String, dynamic>, doc.id);
    }
    return null;
  }

  Future<void> cancelTicket(String ticketId) async {
    try {
      // Get the ticket
      DocumentSnapshot ticketDoc = await ticketsCollection.doc(ticketId).get();
      if (ticketDoc.exists) {
        Ticket ticket = Ticket.fromFirestore(
          ticketDoc.data() as Map<String, dynamic>,
          ticketDoc.id,
        );
        
        // Update ticket status
        await ticketsCollection.doc(ticketId).update({
          'status': TicketStatus.cancelled.toString().split('.').last,
        });
        
        // Make the seat available again
        await trainsCollection
            .doc(ticket.trainId)
            .collection('seats')
            .doc(ticket.seatNumber)
            .update({'isAvailable': true});
        
        // Update available seats count
        DocumentSnapshot trainDoc = await trainsCollection.doc(ticket.trainId).get();
        if (trainDoc.exists) {
          int availableSeats = (trainDoc.data() as Map<String, dynamic>)['availableSeats'] ?? 0;
          await trainsCollection.doc(ticket.trainId).update({
            'availableSeats': availableSeats + 1,
          });
        }
      }
    } catch (e) {
      print('Error cancelling ticket: $e');
      rethrow;
    }
  }

  // Search operations
  Future<List<String>> getOrigins() async {
    QuerySnapshot snapshot = await trainsCollection.get();
    Set<String> origins = {};
    
    for (var doc in snapshot.docs) {
      String origin = (doc.data() as Map<String, dynamic>)['origin'] ?? '';
      if (origin.isNotEmpty) {
        origins.add(origin);
      }
    }
    
    return origins.toList()..sort();
  }

  Future<List<String>> getDestinations() async {
    QuerySnapshot snapshot = await trainsCollection.get();
    Set<String> destinations = {};
    
    for (var doc in snapshot.docs) {
      String destination = (doc.data() as Map<String, dynamic>)['destination'] ?? '';
      if (destination.isNotEmpty) {
        destinations.add(destination);
      }
    }
    
    return destinations.toList()..sort();
  }
}
