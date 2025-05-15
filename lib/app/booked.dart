import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user.dart';
import '../models/ticket.dart';
import '../services/database_service.dart';
import '../utils/theme.dart';
import '../widgets/ticket_card.dart';
import '../widgets/custom_button.dart';

class BookedScreen extends StatefulWidget {
  const BookedScreen({super.key});

  @override
  _BookedScreenState createState() => _BookedScreenState();
}

class _BookedScreenState extends State<BookedScreen> with SingleTickerProviderStateMixin {
  final DatabaseService _database = DatabaseService();
  
  late TabController _tabController;
  final bool _isLoading = true;
  final String _errorMessage = '';
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  Future<void> _cancelTicket(Ticket ticket) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Cancel Ticket'),
          content: const Text(
            'Are you sure you want to cancel this ticket? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('No'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                try {
                  await _database.cancelTicket(ticket.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Ticket cancelled successfully'),
                      backgroundColor: successColor,
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to cancel ticket: ${e.toString()}'),
                      backgroundColor: errorColor,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: errorColor,
              ),
              child: const Text('Yes, Cancel'),
            ),
          ],
        );
      },
    );
  }
  
  void _viewTicketDetails(Ticket ticket) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return _buildTicketDetailsSheet(ticket, scrollController);
        },
      ),
    );
  }
  
  Widget _buildTicketDetailsSheet(Ticket ticket, ScrollController scrollController) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2.5),
              ),
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Title
          Row(
            children: [
              const Text(
                'Ticket Details',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: _getStatusColor(ticket.status).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _getStatusText(ticket.status),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _getStatusColor(ticket.status),
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Train info
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ticket.trainName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: accentColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        ticket.trainClass,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'Seat ${ticket.seatNumber}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Journey details
          Expanded(
            child: SingleChildScrollView(
              controller: scrollController,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Route
                  _buildDetailSection(
                    title: 'Journey',
                    content: Column(
                      children: [
                        _buildJourneyRow(
                          title: 'From',
                          location: ticket.origin,
                          time: ticket.departureTime,
                          isStart: true,
                        ),
                        const SizedBox(height: 20),
                        _buildJourneyRow(
                          title: 'To',
                          location: ticket.destination,
                          time: ticket.arrivalTime,
                          isStart: false,
                        ),
                      ],
                    ),
                  ),
                  
                  // Passenger
                  _buildDetailSection(
                    title: 'Passenger',
                    content: Column(
                      children: [
                        _buildDetailRow('Name', ticket.passengerName),
                        const SizedBox(height: 8),
                        if (ticket.passengerEmail != null)
                          _buildDetailRow('Email', ticket.passengerEmail!),
                        const SizedBox(height: 8),
                        if (ticket.passengerPhone != null)
                          _buildDetailRow('Phone', ticket.passengerPhone!),
                      ],
                    ),
                  ),
                  
                  // Payment
                  _buildDetailSection(
                    title: 'Payment',
                    content: Column(
                      children: [
                        _buildDetailRow('Ticket Price', '\$${ticket.price.toStringAsFixed(2)}'),
                        const SizedBox(height: 8),
                        _buildDetailRow('Booking Date', _formatDate(ticket.bookingTime)),
                        const SizedBox(height: 8),
                        _buildDetailRow('Payment Method', 'Credit Card'),
                      ],
                    ),
                  ),
                  
                  // QR Code
                  _buildDetailSection(
                    title: 'QR Code',
                    content: Center(
                      child: Container(
                        width: 200,
                        height: 200,
                        color: Colors.white,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.qr_code,
                              size: 150,
                              color: Colors.grey.shade800,
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Scan for boarding',
                              style: TextStyle(
                                fontSize: 14,
                                color: textSecondaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  
                  // Cancel button (if upcoming and not cancelled)
                  if (ticket.status == TicketStatus.confirmed && ticket.isUpcoming)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: SizedBox(
                        width: double.infinity,
                        child: CustomButton(
                          text: 'Cancel Ticket',
                          onPressed: () {
                            Navigator.pop(context);
                            _cancelTicket(ticket);
                          },
                          type: ButtonType.outline,
                          icon: Icons.cancel_outlined,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildDetailSection({
    required String title,
    required Widget content,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: primaryColor,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: content,
          ),
        ],
      ),
    );
  }
  
  Widget _buildDetailRow(String label, String value) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: textSecondaryColor,
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: textPrimaryColor,
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildJourneyRow({
    required String title,
    required String location,
    required DateTime time,
    required bool isStart,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: isStart ? primaryColor : successColor,
                shape: BoxShape.circle,
              ),
            ),
            if (isStart)
              Container(
                width: 2,
                height: 40,
                color: Colors.grey.shade300,
              ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  color: textSecondaryColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                location,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: textPrimaryColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _formatDateTime(time),
                style: const TextStyle(
                  fontSize: 14,
                  color: textSecondaryColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  String _formatDateTime(DateTime dateTime) {
    return '${_formatDate(dateTime)} at ${_formatTime(dateTime)}';
  }
  
  String _formatDate(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }
  
  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
  
  Color _getStatusColor(TicketStatus status) {
    switch (status) {
      case TicketStatus.confirmed:
        return successColor;
      case TicketStatus.cancelled:
        return errorColor;
      case TicketStatus.completed:
        return Colors.blue;
    }
  }
  
  String _getStatusText(TicketStatus status) {
    switch (status) {
      case TicketStatus.confirmed:
        return 'Confirmed';
      case TicketStatus.cancelled:
        return 'Cancelled';
      case TicketStatus.completed:
        return 'Completed';
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserModel?>(context);
    
    if (user == null) {
      return const Center(
        child: Text('Please log in to view your tickets'),
      );
    }
    
    return Scaffold(
      body: Column(
        children: [
          // Tab bar
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              indicatorColor: primaryColor,
              labelColor: primaryColor,
              unselectedLabelColor: textSecondaryColor,
              tabs: const [
                Tab(text: 'Upcoming'),
                Tab(text: 'Past'),
                Tab(text: 'Cancelled'),
              ],
            ),
          ),
          
          // Tab views
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Upcoming tickets
                _buildTicketsList(
                  user,
                  (ticket) => ticket.status == TicketStatus.confirmed && ticket.isUpcoming,
                ),
                
                // Past tickets
                _buildTicketsList(
                  user,
                  (ticket) => ticket.status == TicketStatus.confirmed && !ticket.isUpcoming,
                ),
                
                // Cancelled tickets
                _buildTicketsList(
                  user,
                  (ticket) => ticket.status == TicketStatus.cancelled,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildTicketsList(UserModel user, bool Function(Ticket) filter) {
    return StreamBuilder<List<Ticket>>(
      stream: _database.getUserTickets(user.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  color: errorColor,
                  size: 48,
                ),
                const SizedBox(height: 16),
                Text(
                  'Error loading tickets: ${snapshot.error}',
                  style: const TextStyle(color: errorColor),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }
        
        final tickets = snapshot.data ?? [];
        final filteredTickets = tickets.where(filter).toList();
        
        if (filteredTickets.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.confirmation_number_outlined,
                  color: textSecondaryColor,
                  size: 48,
                ),
                const SizedBox(height: 16),
                const Text(
                  'No tickets found',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Book a new train ticket to get started',
                  style: TextStyle(color: textSecondaryColor),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                CustomButton(
                  text: 'Book Now',
                  onPressed: () {
                    // Navigate to home or search screen
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  icon: Icons.search,
                ),
              ],
            ),
          );
        }
        
        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 16),
          itemCount: filteredTickets.length,
          itemBuilder: (context, index) {
            final ticket = filteredTickets[index];
            return TicketCard(
              ticket: ticket,
              onCancel: ticket.status == TicketStatus.confirmed && ticket.isUpcoming
                  ? () => _cancelTicket(ticket)
                  : null,
              onViewDetails: () => _viewTicketDetails(ticket),
            );
          },
        );
      },
    );
  }
}
