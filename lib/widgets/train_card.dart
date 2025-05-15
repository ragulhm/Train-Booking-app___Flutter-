import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/train.dart';
import '../utils/theme.dart';
import 'custom_button.dart';

class TrainCard extends StatelessWidget {
  final Train train;
  final VoidCallback onSelect;
  
  const TrainCard({
    super.key,
    required this.train,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 2,
      child: InkWell(
        onTap: onSelect,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Train name and number
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    train.name,
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
                      train.trainNumber,
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Departure',
                          style: TextStyle(
                            fontSize: 12,
                            color: textSecondaryColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          DateFormat('hh:mm a').format(train.departureTime),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          train.origin,
                          style: const TextStyle(
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          DateFormat('MMM d, yyyy').format(train.departureTime),
                          style: const TextStyle(
                            fontSize: 12,
                            color: textSecondaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Duration indicator
                  Expanded(
                    child: Column(
                      children: [
                        const SizedBox(height: 8),
                        const Icon(
                          Icons.east,
                          color: primaryColor,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          train.formattedDuration,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: textSecondaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text(
                          'Arrival',
                          style: TextStyle(
                            fontSize: 12,
                            color: textSecondaryColor,
                          ),
                          textAlign: TextAlign.right,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          DateFormat('hh:mm a').format(train.arrivalTime),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.right,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          train.destination,
                          style: const TextStyle(
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.right,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          DateFormat('MMM d, yyyy').format(train.arrivalTime),
                          style: const TextStyle(
                            fontSize: 12,
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
              
              // Class, seats and price information
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Train class
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      train.trainClass,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                  ),
                  
                  // Available seats
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: train.availableSeats > 10 
                          ? successColor.withOpacity(0.1) 
                          : errorColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${train.availableSeats} seats',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: train.availableSeats > 10 ? successColor : errorColor,
                      ),
                    ),
                  ),
                  
                  // Price
                  Text(
                    '\$${train.price.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Book now button
              SizedBox(
                width: double.infinity,
                child: CustomButton(
                  text: 'Select Train',
                  onPressed: onSelect,
                  type: ButtonType.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
