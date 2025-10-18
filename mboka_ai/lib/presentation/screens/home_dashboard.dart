import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../logic/bloc/auth_bloc.dart';
import '../../logic/bloc/auth_state.dart';
import '../../data/models/user_model.dart';
import '../../theme/app_colors.dart';
import '../widgets/feature_card.dart';
import 'poster_generator_screen.dart';
import 'profile_screen.dart';

class HomeDashboard extends StatefulWidget {
  const HomeDashboard({super.key});

  @override
  State<HomeDashboard> createState() => _HomeDashboardState();
}

class _HomeDashboardState extends State<HomeDashboard> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController();

  // Screens for the Bottom Navigation Bar
  final List<Widget> _screens = [
    const DashboardContent(),
    const Center(child: Text("Post Creation Screen (Future Feature)")),
    const ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.jumpToPage(index);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthUnauthenticated) {
          Navigator.of(context).pushReplacementNamed('/login');
        }
      },
      child: Scaffold(
        body: PageView(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          children: _screens,
          onPageChanged: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
        ),

        // 🔹 Persistent Bottom Navigation Bar
        bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(
              icon: Icon(Icons.add_circle_outline),
              label: 'Add',
            ),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: AppColors.primarySkyBlue,
          unselectedItemColor: Colors.grey,
          onTap: _onItemTapped,
          backgroundColor: AppColors.textWhite,
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
//Dashboard Content (Home Tab)
// -----------------------------------------------------------------------------

class DashboardContent extends StatelessWidget {
  const DashboardContent({super.key});

  @override
  Widget build(BuildContext context) {
    final userState = context.watch<AuthBloc>().state;
    final AppUser user =
        userState is AuthAuthenticated ? userState.user : AppUser.empty;

    return Scaffold(
      backgroundColor: AppColors.backgroundLightGray,

      // ✅ 1. AppBar shows only greeting
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: AppColors.backgroundLightGray,
        elevation: 0,
        title: Text(
          'Hello, ${user.businessName} 👋',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      //2. Body now has hero image + grid
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Image Section
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                image: const DecorationImage(
                  image: AssetImage('assets/images/hero_banner.png'),
                  fit: BoxFit.cover,
                ),
              ),
              alignment: Alignment.topRight,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.black54.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'GROW YOUR \n         HUSTLE \n        WITH AI.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.w800,
                    fontFamily: "Poppins",
                    height: 1.3,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // 🔹 Feature Cards Grid
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 16.0,
              mainAxisSpacing: 16.0,
              childAspectRatio: 1.3,
              children: [
                FeatureCard(
                  title: 'Stunning Posters',
                  text: 'Turn your products into stunning posters.',
                  icon: Icons.brush_outlined,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const PosterGeneratorScreen(),
                      ),
                    );
                  },
                ),
                FeatureCard(
                  title: 'AI Consultation',
                  text: 'Book AI consultation for your business.',
                  icon: Icons.support_agent_outlined,
                  onTap: () {
                    // TODO: Navigate to Consultation Booking
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
