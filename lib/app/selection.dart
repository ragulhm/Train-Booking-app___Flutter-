import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/train.dart';
import '../services/database_service.dart';
import '../utils/theme.dart';
import '../widgets/train_card.dart';
import 'confirm.dart';

class SelectionScreen extends StatefulWidget {
  final String origin;
  final String destination;
  final DateTime date;
  final int passengers;
  
  const SelectionScreen({
    super.key,
    required this.origin,
    required this.destination,
    required this.date,
    required this.passengers,
  });

  @override
  _SelectionScreenState createState() => _SelectionScreenState();
}

class _SelectionScreenState extends State<SelectionScreen> {
  final DatabaseService _database = DatabaseService();
  List<Train>? _trains;
  bool _isLoading = true;
  String _errorMessage = '';
  
  @override
  void initState() {
    super.initState();
    _loadTrains();
  }
  
  Future<void> _loadTrains() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });
      
      // In a real app, we would filter by date as well
      _database.getTrainsByRoute(widget.origin, widget.destination).listen((trains) {
        // Filter by date (only the date part, not time)
        final filteredTrains = trains.where((train) {
          final trainDate = DateTime(
            train.departureTime.year,
            train.departureTime.month,
            train.departureTime.day,
          );
          final selectedDate = DateTime(
            widget.date.year,
            widget.date.month,
            widget.date.day,
          );
          return trainDate.isAtSameMomentAs(selectedDate);
        }).toList();
        
        setState(() {
          _trains = filteredTrains;
          _isLoading = false;
        });
      }, onError: (e) {
        setState(() {
          _errorMessage = 'Error loading trains: ${e.toString()}';
          _isLoading = false;
        });
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: ${e.toString()}';
        _isLoading = false;
      });
    }
  }
  
  void _selectTrain(Train train) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ConfirmScreen(
          train: train,
          passengers: widget.passengers,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Train'),
      ),
      body: Column(
        children: [
          // Route and date info
          Container(
            padding: const EdgeInsets.all(16.0),
            color: primaryColor.withOpacity(0.1),
            child: Column(
              children: [
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
                            widget.origin,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
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
                            widget.destination,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.right,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_today,
                          size: 16,
                          color: primaryColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          DateFormat('MMM d, yyyy').format(widget.date),
                          style: const TextStyle(
                            fontSize: 14,
                            color: textPrimaryColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 16),
                    Row(
                      children: [
                        const Icon(
                          Icons.person,
                          size: 16,
                          color: primaryColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${widget.passengers} ${widget.passengers == 1 ? 'passenger' : 'passengers'}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: textPrimaryColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Trains list
          Expanded(
            child: _buildTrainsList(),
          ),
        ],
      ),
    );
  }
  
  Widget _buildTrainsList() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    
    if (_errorMessage.isNotEmpty) {
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
              _errorMessage,
              style: const TextStyle(color: errorColor),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadTrains,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }
    
    if (_trains == null || _trains!.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.train,
              color: textSecondaryColor,
              size: 48,
            ),
            const SizedBox(height: 16),
            const Text(
              'No trains available for the selected route and date.',
              style: TextStyle(color: textSecondaryColor),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Go Back'),
            ),
          ],
        ),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: _trains!.length,
      itemBuilder: (context, index) {
        final train = _trains![index];
        return TrainCard(
          train: train,
          onSelect: () => _selectTrain(train),
        );
      },
    );
  }
}
