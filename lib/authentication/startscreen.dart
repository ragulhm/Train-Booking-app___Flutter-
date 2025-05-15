import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user.dart';
import '../app/home.dart';
import 'login.dart';
import '../utils/theme.dart';
import '../utils/constants.dart';
import '../widgets/custom_button.dart';

class StartScreen extends StatefulWidget {
  const StartScreen({super.key});

  @override
  _StartScreenState createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  
  final List<Map<String, String>> _onboardingData = [
    {
      'title': 'Welcome to $appName',
      'subtitle': 'The easiest way to book train tickets',
      'image': trainStationImages[0],
    },
    {
      'title': 'Find the Best Routes',
      'subtitle': 'Compare schedules, prices, and amenities',
      'image': trainStationImages[1],
    },
    {
      'title': 'Book with Confidence',
      'subtitle': 'Secure payment and instant confirmation',
      'image': paymentInterfaceImages[0],
    },
    {
      'title': 'Travel in Comfort',
      'subtitle': 'Enjoy your journey in modern trains',
      'image': trainInteriorImages[0],
    },
  ];

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      int page = _pageController.page!.round();
      if (page != _currentPage) {
        setState(() {
          _currentPage = page;
        });
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserModel?>(context);
    
    if (user != null) {
      // User is logged in, navigate to home
      return const HomeScreen();
    }
    
    return Scaffold(
      body: Stack(
        children: [
          // Onboarding pages
          PageView.builder(
            controller: _pageController,
            itemCount: _onboardingData.length,
            itemBuilder: (context, index) {
              return _buildOnboardingPage(
                _onboardingData[index]['title']!,
                _onboardingData[index]['subtitle']!,
                _onboardingData[index]['image']!,
              );
            },
          ),
          
          // Page indicator dots
          Positioned(
            bottom: 120,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _onboardingData.length,
                (index) => _buildDot(index),
              ),
            ),
          ),
          
          // Buttons
          Positioned(
            bottom: 40,
            left: 20,
            right: 20,
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: CustomButton(
                    text: 'Get Started',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const LoginScreen()),
                      );
                    },
                    type: ButtonType.primary,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Already have an account?',
                      style: TextStyle(color: textSecondaryColor),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const LoginScreen()),
                        );
                      },
                      child: const Text('Login'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildOnboardingPage(String title, String subtitle, String imageUrl) {
    return Container(
      decoration: BoxDecoration(
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
        padding: const EdgeInsets.all(40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Spacer(),
            Text(
              title,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 18,
                color: Colors.white,
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
  
  Widget _buildDot(int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(horizontal: 5),
      height: 8,
      width: _currentPage == index ? 24 : 8,
      decoration: BoxDecoration(
        color: _currentPage == index ? primaryColor : Colors.white,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
