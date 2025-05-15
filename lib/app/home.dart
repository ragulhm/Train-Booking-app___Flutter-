import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/user.dart';
import '../models/train.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../utils/theme.dart';
import '../utils/constants.dart';
import 'selection.dart';
import 'booked.dart';
import '../authentication/startscreen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService _auth = AuthService();
  final DatabaseService _database = DatabaseService();
  
  String? _selectedOrigin;
  String? _selectedDestination;
  DateTime _selectedDate = DateTime.now();
  int _selectedPassengers = 1;
  
  List<String> _origins = [];
  List<String> _destinations = [];
  bool _isLoading = true;
  String _errorMessage = '';
  
  int _currentIndex = 0;
  
  @override
  void initState() {
    super.initState();
    _loadData();
  }
  
  Future<void> _loadData() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });
      
      final origins = await _database.getOrigins();
      final destinations = await _database.getDestinations();
      
      setState(() {
        _origins = origins;
        _destinations = destinations;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading data: ${e.toString()}';
        _isLoading = false;
      });
    }
  }
  
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: primaryColor,
              onPrimary: Colors.white,
              onSurface: textPrimaryColor,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }
  
  void _searchTrains() {
    if (_selectedOrigin == null || _selectedDestination == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select origin and destination'),
          backgroundColor: errorColor,
        ),
      );
      return;
    }
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SelectionScreen(
          origin: _selectedOrigin!,
          destination: _selectedDestination!,
          date: _selectedDate,
          passengers: _selectedPassengers,
        ),
      ),
    );
  }
  
  Future<void> _signOut() async {
    await _auth.signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const StartScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final UserModel? user = Provider.of<UserModel?>(context);
    
    Widget bodyContent;
    
    switch (_currentIndex) {
      case 0:
        bodyContent = _buildHomeContent();
        break;
      case 1:
        bodyContent = const BookedScreen();
        break;
      case 2:
        bodyContent = _buildProfileContent(user);
        break;
      default:
        bodyContent = _buildHomeContent();
    }
    
    return Scaffold(
      appBar: AppBar(
        title: Text(_getAppBarTitle()),
        actions: [
          if (_currentIndex == 0)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loadData,
            ),
          if (_currentIndex == 2)
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: _signOut,
            ),
        ],
      ),
      body: bodyContent,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.confirmation_number),
            label: 'My Tickets',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        selectedItemColor: primaryColor,
        unselectedItemColor: textSecondaryColor,
      ),
    );
  }
  
  String _getAppBarTitle() {
    switch (_currentIndex) {
      case 0:
        return 'Search Trains';
      case 1:
        return 'My Tickets';
      case 2:
        return 'Profile';
      default:
        return appName;
    }
  }
  
  Widget _buildHomeContent() {
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
              onPressed: _loadData,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner image
          Container(
            height: 180,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              image: DecorationImage(
                image: NetworkImage(trainStationImages[2]),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Colors.black.withOpacity(0.4),
                  BlendMode.darken,
                ),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: const [
                  Text(
                    'Book Your Train Journey',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Fast, convenient, and reliable train bookings',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Search form
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Find Trains',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Origin dropdown
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'From',
                      prefixIcon: Icon(Icons.train),
                    ),
                    value: _selectedOrigin,
                    items: _origins.map((origin) {
                      return DropdownMenuItem<String>(
                        value: origin,
                        child: Text(origin),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedOrigin = value;
                        // Reset destination if same as origin
                        if (_selectedDestination == value) {
                          _selectedDestination = null;
                        }
                      });
                    },
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Destination dropdown
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'To',
                      prefixIcon: Icon(Icons.place),
                    ),
                    value: _selectedDestination,
                    items: _destinations
                        .where((dest) => dest != _selectedOrigin)
                        .map((destination) {
                      return DropdownMenuItem<String>(
                        value: destination,
                        child: Text(destination),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedDestination = value;
                      });
                    },
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Date selector
                  InkWell(
                    onTap: () => _selectDate(context),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Date',
                        prefixIcon: Icon(Icons.calendar_today),
                      ),
                      child: Text(
                        DateFormat('EEE, MMM d, yyyy').format(_selectedDate),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Passengers selector
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Passengers',
                          style: TextStyle(
                            fontSize: 16,
                            color: textPrimaryColor,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline),
                        onPressed: _selectedPassengers > 1
                            ? () {
                                setState(() {
                                  _selectedPassengers--;
                                });
                              }
                            : null,
                      ),
                      Text(
                        '$_selectedPassengers',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline),
                        onPressed: _selectedPassengers < 5
                            ? () {
                                setState(() {
                                  _selectedPassengers++;
                                });
                              }
                            : null,
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Search button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _searchTrains,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Search Trains'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Popular destinations
          const Text(
            'Popular Destinations',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: primaryColor,
            ),
          ),
          
          const SizedBox(height: 16),
          
          SizedBox(
            height: 150,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _destinations.length > 5 ? 5 : _destinations.length,
              itemBuilder: (context, index) {
                final destination = _destinations[index];
                return _buildDestinationCard(destination, trainStationImages[index % trainStationImages.length]);
              },
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildDestinationCard(String destination, String imageUrl) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedDestination = destination;
        });
      },
      child: Container(
        width: 150,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          image: DecorationImage(
            image: NetworkImage(imageUrl),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.3),
              BlendMode.darken,
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                destination,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildProfileContent(UserModel? user) {
    if (user == null) {
      return const Center(
        child: Text('User not logged in'),
      );
    }
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User info card
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: primaryColor,
                    child: Text(
                      user.displayName != null && user.displayName!.isNotEmpty
                          ? user.displayName![0].toUpperCase()
                          : user.email[0].toUpperCase(),
                      style: const TextStyle(
                        fontSize: 24,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.displayName ?? 'User',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user.email,
                          style: const TextStyle(
                            fontSize: 14,
                            color: textSecondaryColor,
                          ),
                        ),
                        if (user.phoneNumber != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            user.phoneNumber!,
                            style: const TextStyle(
                              fontSize: 14,
                              color: textSecondaryColor,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Profile options
          const Text(
            'Account Settings',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: primaryColor,
            ),
          ),
          
          const SizedBox(height: 16),
          
          _buildSettingsItem(
            icon: Icons.person_outline,
            title: 'Edit Profile',
            onTap: () {
              // Navigate to edit profile screen
            },
          ),
          
          _buildSettingsItem(
            icon: Icons.lock_outline,
            title: 'Change Password',
            onTap: () {
              // Navigate to change password screen
            },
          ),
          
          _buildSettingsItem(
            icon: Icons.notifications_none,
            title: 'Notifications',
            onTap: () {
              // Navigate to notifications settings
            },
          ),
          
          _buildSettingsItem(
            icon: Icons.credit_card,
            title: 'Payment Methods',
            onTap: () {
              // Navigate to payment methods
            },
          ),
          
          const Divider(height: 32),
          
          _buildSettingsItem(
            icon: Icons.help_outline,
            title: 'Help & Support',
            onTap: () {
              // Navigate to help & support
            },
          ),
          
          _buildSettingsItem(
            icon: Icons.info_outline,
            title: 'About',
            onTap: () {
              // Navigate to about screen
            },
          ),
          
          _buildSettingsItem(
            icon: Icons.logout,
            title: 'Logout',
            onTap: _signOut,
          ),
        ],
      ),
    );
  }
  
  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: primaryColor),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
