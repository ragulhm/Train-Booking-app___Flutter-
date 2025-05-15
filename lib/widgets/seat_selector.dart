import 'package:flutter/material.dart';
import '../models/train.dart';
import '../utils/theme.dart';

class SeatSelector extends StatefulWidget {
  final List<TrainSeat> seats;
  final Function(TrainSeat) onSeatSelected;
  final TrainSeat? selectedSeat;
  
  const SeatSelector({
    super.key,
    required this.seats,
    required this.onSeatSelected,
    this.selectedSeat,
  });

  @override
  _SeatSelectorState createState() => _SeatSelectorState();
}

class _SeatSelectorState extends State<SeatSelector> {
  late TrainSeat? _selectedSeat;
  
  @override
  void initState() {
    super.initState();
    _selectedSeat = widget.selectedSeat;
  }
  
  @override
  void didUpdateWidget(SeatSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedSeat != widget.selectedSeat) {
      _selectedSeat = widget.selectedSeat;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Group seats by class
    Map<String, List<TrainSeat>> seatsByClass = {};
    
    for (var seat in widget.seats) {
      if (!seatsByClass.containsKey(seat.seatClass)) {
        seatsByClass[seat.seatClass] = [];
      }
      seatsByClass[seat.seatClass]!.add(seat);
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(
            'Select Your Seat',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: textPrimaryColor,
            ),
          ),
        ),
        
        // Legend
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            children: [
              _buildLegendItem(Colors.white, 'Available'),
              const SizedBox(width: 16),
              _buildLegendItem(primaryColor, 'Selected'),
              const SizedBox(width: 16),
              _buildLegendItem(Colors.grey.shade300, 'Unavailable'),
            ],
          ),
        ),
        
        const SizedBox(height: 8),
        
        // Seats by class
        ...seatsByClass.entries.map((entry) {
          return _buildSeatSection(entry.key, entry.value);
        }),
      ],
    );
  }
  
  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: color,
            border: Border.all(color: Colors.grey.shade400),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: textSecondaryColor,
          ),
        ),
      ],
    );
  }
  
  Widget _buildSeatSection(String seatClass, List<TrainSeat> seats) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(
            seatClass,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: primaryColor,
            ),
          ),
        ),
        
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: seats.map((seat) {
              return _buildSeatItem(seat);
            }).toList(),
          ),
        ),
        
        const SizedBox(height: 16),
      ],
    );
  }
  
  Widget _buildSeatItem(TrainSeat seat) {
    final bool isSelected = _selectedSeat?.id == seat.id;
    
    return GestureDetector(
      onTap: () {
        if (seat.isAvailable) {
          setState(() {
            _selectedSeat = seat;
          });
          widget.onSeatSelected(seat);
        }
      },
      child: Container(
        width: 60,
        height: 50,
        decoration: BoxDecoration(
          color: isSelected 
              ? primaryColor 
              : (seat.isAvailable ? Colors.white : Colors.grey.shade300),
          border: Border.all(
            color: isSelected 
                ? primaryColor 
                : Colors.grey.shade400,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              seat.seatNumber,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : textPrimaryColor,
              ),
            ),
            Text(
              '\$${seat.price.toStringAsFixed(0)}',
              style: TextStyle(
                fontSize: 12,
                color: isSelected ? Colors.white : textSecondaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
