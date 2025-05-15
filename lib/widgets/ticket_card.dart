import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/ticket.dart';
import '../utils/theme.dart';
import 'custom_button.dart';

class TicketCard extends StatelessWidget {
  final Ticket ticket;
  final VoidCallback? onCancel;
  final VoidCallback? onViewDetails;
  
  const TicketCard({
    super.key,
    required this.ticket,
    this.onCancel,
    this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    final bool isUpcoming = ticket.departureTime.isAfter(DateTime.now());
    final bool isCancelled = ticket.status == TicketStatus.cancelled;
    
    Color statusColor;
    String statusText;
    
    switch (ticket.status) {
      case TicketStatus.confirmed:
        statusColor = successColor;
        statusText = 'Confirmed';
        break;
      case TicketStatus.cancelled:
        statusColor = errorColor;
        statusText = 'Cancelled';
        break;
      case TicketStatus.completed:
        statusColor = Colors.blue;
        statusText = 'Completed';
        break;
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      child: Column(
        children: [
          // Colored status bar
          Container(
            width: double.infinity,
            color: statusColor.withOpacity(0.8),
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              statusText,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          
          // Ticket content
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Train name and number
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      ticket.trainName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
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
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Origin and destination with time
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'From',
                            style: TextStyle(
                              fontSize: 12,
                              color: textSecondaryColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            ticket.origin,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            DateFormat('MMM d, hh:mm a').format(ticket.departureTime),
                            style: const TextStyle(
                              fontSize: 14,
                              color: textSecondaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const Icon(
                      Icons.east,
                      color: primaryColor,
                    ),
                    
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text(
                            'To',
                            style: TextStyle(
                              fontSize: 12,
                              color: textSecondaryColor,
                            ),
                            textAlign: TextAlign.right,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            ticket.destination,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.right,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            DateFormat('MMM d, hh:mm a').format(ticket.arrivalTime),
                            style: const TextStyle(
                              fontSize: 14,
                              color: textSecondaryColor,
                            ),
                            textAlign: TextAlign.right,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Passenger and seat information
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Passenger',
                          style: TextStyle(
                            fontSize: 12,
                            color: textSecondaryColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          ticket.passengerName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text(
                          'Seat Number',
                          style: TextStyle(
                            fontSize: 12,
                            color: textSecondaryColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: primaryColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            ticket.seatNumber,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Price and action buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Paid: \$${ticket.price.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                    
                    if (onViewDetails != null)
                      CustomButton(
                        text: 'Details',
                        onPressed: onViewDetails!,
                        type: ButtonType.outline,
                        height: 40,
                      ),
                  ],
                ),
                
                // Cancel button for upcoming and non-cancelled tickets
                if (isUpcoming && !isCancelled && onCancel != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: SizedBox(
                      width: double.infinity,
                      child: CustomButton(
                        text: 'Cancel Ticket',
                        onPressed: onCancel!,
                        type: ButtonType.outline,
                        height: 40,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
