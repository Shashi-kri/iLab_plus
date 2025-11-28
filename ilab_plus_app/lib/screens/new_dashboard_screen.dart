import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'disease_detection_screen.dart';
import 'vision_test_screen.dart';
import 'test_suite_screen.dart';
import 'chatbot_screen.dart';
import 'my_reports_screen.dart';

class NewDashboardScreen extends StatefulWidget {
  const NewDashboardScreen({super.key});

  @override
  State<NewDashboardScreen> createState() => _NewDashboardScreenState();
}

class _NewDashboardScreenState extends State<NewDashboardScreen> with TickerProviderStateMixin {
  int _currentTipIndex = 0;
  int _selectedTab = 0;
  final PageController _pageController = PageController();
  late AnimationController _floatingController1;
  late AnimationController _floatingController2;
  late AnimationController _floatingController3;

  final List<Map<String, String>> _eyeTips = [
    {
      "text": "Follow the 20-20-20 rule",
      "image": "assets/images/clock.jpg"
    },
    {
      "text": "Maintain proper screen distance",
      "image": "assets/images/distance.jpg"
    },
    {
      "text": "Stay hydrated for healthy eyes",
      "image": "assets/images/water.jpg"
    },
    {
      "text": "Wear sunglasses outdoors",
      "image": "assets/images/beach.jpg"
    },
    {
      "text": "Get adequate sleep daily",
      "image": "assets/images/moon.jpg"
    },
  ];

  @override
  void initState() {
    super.initState();
    _floatingController1 = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _floatingController2 = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _floatingController3 = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _floatingController1.dispose();
    _floatingController2.dispose();
    _floatingController3.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: AppTheme.gradientBackground,
        child: SafeArea(
          child: _selectedTab == 0 ? _buildMainDashboard() : const MyReportsScreen(),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildMainDashboard() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with user greeting
            _buildUserHeader(context),
            const SizedBox(height: 20),

            // Daily Eye Tip Banner
            _buildDailyTipBanner(),
            const SizedBox(height: 24),

            // Feature Cards Title
            Text(
              'Features',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 16),

                // Feature Cards
                _buildFeatureCard(
                  context: context,
                  icon: Icons.center_focus_strong,
                  iconColor: AppTheme.iconBgTeal,
                  title: 'AI Eye Scan',
                  description: 'Scan your eyes for signs of common conditions',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const DiseaseDetectionScreen()),
                  ),
                ),
                const SizedBox(height: 16),

                _buildFeatureCard(
                  context: context,
                  icon: Icons.remove_red_eye_outlined,
                  iconColor: AppTheme.iconBgBlue,
                  title: 'Vision Test',
                  description: 'Hands-free voice-controlled vision assessment',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const VisionTestScreen()),
                  ),
                ),
                const SizedBox(height: 16),

                _buildFeatureCard(
                  context: context,
                  icon: Icons.science_outlined,
                  iconColor: AppTheme.iconBgCyan,
                  title: 'Test Suite',
                  description: 'Comprehensive at-home eye health tests',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const TestSuiteScreen()),
                  ),
                ),
                const SizedBox(height: 16),

                _buildFeatureCard(
                  context: context,
                  icon: Icons.chat_bubble_outline,
                  iconColor: AppTheme.iconBgGreen,
                  title: 'AI Assistant',
                  description: 'Get instant help with symptoms and questions',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ChatbotScreen()),
                  ),
                ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                icon: Icons.home_rounded,
                label: 'Home',
                index: 0,
              ),
              _buildNavItem(
                icon: Icons.assessment_rounded,
                label: 'My Reports',
                index: 1,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final isSelected = _selectedTab == index;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedTab = index;
        });
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.peachColor.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? AppTheme.peachColor : AppTheme.greyColor,
              size: 24,
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: AppTheme.peachColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildUserHeader(BuildContext context) {
    return Row(
      children: [
        // User Avatar with gradient
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppTheme.peachColor, AppTheme.blueColor],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppTheme.peachColor.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(
            Icons.person,
            color: Colors.white,
            size: 30,
          ),
        ),
        const SizedBox(width: 16),

        // Greeting
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hello, User',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Take care of your eyes today',
                style: TextStyle(
                  fontSize: 15,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),

        // Medical Kit Button
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.red.shade400,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.red.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: IconButton(
            onPressed: () {
              // Emergency action
            },
            icon: const Icon(
              Icons.medical_services_rounded,
              color: Colors.white,
              size: 26,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDailyTipBanner() {
    return Container(
      height: 220,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF9AB6FF),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF9AB6FF).withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // Animated background images
            _buildAnimatedBackground(),

            // Content overlay
            Column(
              children: [
                const SizedBox(height: 20),

                // Top Label
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.remove_red_eye, color: Colors.white70, size: 16),
                    SizedBox(width: 8),
                    Text(
                      "Daily Eye Tip",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // Carousel Content
                SizedBox(
                  height: 130,
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: _eyeTips.length,
                    onPageChanged: (index) {
                      setState(() {
                        _currentTipIndex = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          image: DecorationImage(
                            image: AssetImage(_eyeTips[index]['image']!),
                            fit: BoxFit.cover,
                            colorFilter: ColorFilter.mode(
                              Colors.black.withOpacity(0.4),
                              BlendMode.darken,
                            ),
                          ),
                        ),
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Text(
                              _eyeTips[index]['text']!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 10),

                // Pagination Dots
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _eyeTips.length,
                    (index) => _buildDot(index),
                  ),
                ),
                const SizedBox(height: 15),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconForTip(int index) {
    switch (index) {
      case 0:
        return Icons.timer_outlined;
      case 1:
        return Icons.laptop_mac;
      case 2:
        return Icons.water_drop_outlined;
      case 3:
        return Icons.wb_sunny_outlined;
      case 4:
        return Icons.nightlight_round;
      default:
        return Icons.remove_red_eye;
    }
  }

  Widget _buildDot(int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(right: 8),
      height: 8,
      width: 8,
      decoration: BoxDecoration(
        color: _currentTipIndex == index
            ? Colors.white
            : Colors.white.withOpacity(0.4),
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildAnimatedBackground() {
    return Stack(
      children: [
        // Floating eye icon 1
        AnimatedBuilder(
          animation: _floatingController1,
          builder: (context, child) {
            return Positioned(
              top: 20 + (_floatingController1.value * 30),
              left: 30,
              child: Opacity(
                opacity: 0.15,
                child: Icon(
                  Icons.remove_red_eye_outlined,
                  size: 50,
                  color: Colors.white,
                ),
              ),
            );
          },
        ),

        // Floating glasses icon
        AnimatedBuilder(
          animation: _floatingController2,
          builder: (context, child) {
            return Positioned(
              top: 60 + (_floatingController2.value * 40),
              right: 40,
              child: Opacity(
                opacity: 0.12,
                child: Icon(
                  Icons.visibility_outlined,
                  size: 60,
                  color: Colors.white,
                ),
              ),
            );
          },
        ),

        // Floating sparkle icon 1
        AnimatedBuilder(
          animation: _floatingController3,
          builder: (context, child) {
            return Positioned(
              bottom: 20 + (_floatingController3.value * 25),
              left: 60,
              child: Opacity(
                opacity: 0.1,
                child: Icon(
                  Icons.auto_awesome,
                  size: 35,
                  color: Colors.white,
                ),
              ),
            );
          },
        ),

        // Floating eye icon 2
        AnimatedBuilder(
          animation: _floatingController1,
          builder: (context, child) {
            return Positioned(
              bottom: 40 + (_floatingController1.value * -20),
              right: 80,
              child: Opacity(
                opacity: 0.08,
                child: Icon(
                  Icons.remove_red_eye,
                  size: 40,
                  color: Colors.white,
                ),
              ),
            );
          },
        ),

        // Floating health icon
        AnimatedBuilder(
          animation: _floatingController2,
          builder: (context, child) {
            return Positioned(
              top: 100 + (_floatingController2.value * -30),
              left: MediaQuery.of(context).size.width * 0.7,
              child: Opacity(
                opacity: 0.1,
                child: Icon(
                  Icons.health_and_safety_outlined,
                  size: 45,
                  color: Colors.white,
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildFeatureCard({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon
            Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [iconColor, iconColor.withOpacity(0.7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: iconColor.withOpacity(0.4),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Icon(icon, color: Colors.white, size: 34),
            ),
            const SizedBox(width: 18),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.textSecondary,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Get Started Button
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [iconColor.withOpacity(0.2), iconColor.withOpacity(0.1)],
                      ),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Get Started',
                          style: TextStyle(
                            color: iconColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Icon(
                          Icons.arrow_forward_rounded,
                          color: iconColor,
                          size: 18,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
