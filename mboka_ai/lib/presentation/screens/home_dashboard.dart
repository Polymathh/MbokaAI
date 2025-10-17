// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import '../../logic/bloc/auth_bloc.dart';
// import '../../logic/bloc/auth_event.dart';
// import '../../logic/bloc/auth_state.dart';
// import '../../theme/app_colors.dart';

// class HomeDashboard extends StatelessWidget {
//   const HomeDashboard({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return BlocListener<AuthBloc, AuthState>(
//       listener: (context, state) {
//         if (state is AuthUnauthenticated) {
//           // If the user logs out or session expires, navigate back to login
//           Navigator.of(context).pushReplacementNamed('/login');
//         }
//       },
//       child: Scaffold(
//         appBar: AppBar(
//           title: const Text('MbokaAI Dashboard'),
//           backgroundColor: AppColors.primarySkyBlue,
//           foregroundColor: AppColors.textWhite,
//         ),
//         body: Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: <Widget>[
//               Text(
//                 'Karibu! Your Hustle Just Got Smarter.',
//                 style: Theme.of(context).textTheme.headlineMedium?.copyWith(
//                   color: Colors.black87,
//                 ),
//               ),
//               const SizedBox(height: 20),
//               Text(
//                 'This is your main area. We will build the AI tools here in the next steps.',
//                 style: Theme.of(context).textTheme.bodyLarge,
//               ),
//               const SizedBox(height: 40),
//               // Logout Button
//               ElevatedButton.icon(
//                 icon: const Icon(Icons.logout),
//                 label: const Text('Logout'),
//                 onPressed: () {
//                   // Dispatch the logout event
//                   BlocProvider.of<AuthBloc>(context).add(AuthLogoutRequested());
//                 },
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.redAccent,
//                   foregroundColor: AppColors.textWhite,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../logic/bloc/auth_bloc.dart';
import '../../logic/bloc/auth_state.dart';
import '../../data/models/user_model.dart'; 
import '../../theme/app_colors.dart';
import '../widgets/feature_card.dart'; // Will create this next
import 'profile_screen.dart'; // Will create this next

class HomeDashboard extends StatefulWidget {
  const HomeDashboard({super.key});

  @override
  State<HomeDashboard> createState() => _HomeDashboardState();
}

class _HomeDashboardState extends State<HomeDashboard> {
  int _selectedIndex = 0;
  // A controller to switch between the screens linked to the bottom bar
  final PageController _pageController = PageController(); 

  // List of screens for the Bottom Navigation Bar
  final List<Widget> _screens = [
    const DashboardContent(), // Home/Dashboard View
    const Center(child: Text("Post Creation Screen (Future Feature)")), // Add/Plus
    const ProfileScreen(), // Profile Screen
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    // Jump to the selected page without animation for simplicity
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
          // Navigate back to login if session expires or user logs out
          Navigator.of(context).pushReplacementNamed('/login');
        }
      },
      child: Scaffold(
        // Use PageView to manage the screens and link it to the BottomNavigationBar
        body: PageView(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(), // Disable swipe
          children: _screens,
          onPageChanged: (index) {
            // Keep the bottom bar and page controller synchronized
            setState(() {
              _selectedIndex = index;
            });
          },
        ),
        
        // 🔹 Bottom Navigation Bar (Persistent)
        bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.add_circle_outline),
              label: 'Add',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
            ),
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
// 2.2 Dashboard Content View (The actual features on the Home tab)
// -----------------------------------------------------------------------------

class DashboardContent extends StatelessWidget {
  const DashboardContent({super.key});

  @override
  Widget build(BuildContext context) {
    // Access the authenticated user data from the BLoC state
    final userState = context.watch<AuthBloc>().state;
    final AppUser user = userState is AuthAuthenticated 
        ? userState.user 
        : AppUser.empty;

    return CustomScrollView(
      slivers: <Widget>[
        // Custom AppBar to show the Greeting
        SliverAppBar(
          automaticallyImplyLeading: false,
          backgroundColor: AppColors.backgroundLightGray,
          expandedHeight: 180.0,
          floating: true,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
            title: Text(
              'Hello, ${user.businessName} 👋',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            background: Align(
              alignment: Alignment.bottomLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 16, bottom: 60),
                child: Text(
                  'Grow your hustle with AI.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.black54,
                        fontSize: 16,
                      ),
                ),
              ),
            ),
          ),
        ),

        SliverPadding(
          padding: const EdgeInsets.all(16.0),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, // 🔹 Grid of 2 columns
              crossAxisSpacing: 16.0,
              mainAxisSpacing: 16.0,
              childAspectRatio: 0.9, // Make cards slightly taller
            ),
            delegate: SliverChildListDelegate(
              [
                // 🔹 Feature Card 1: Poster Generator
                FeatureCard(
                  title: 'Stunning Posters',
                  text: 'Turn your products into stunning posters.',
                  icon: Icons.brush_outlined,
                  onTap: () { /* TODO: Navigate to Poster Generator */ },
                ),
                // 🔹 Feature Card 2: Consultation Booking
                FeatureCard(
                  title: 'AI Consultation',
                  text: 'Book AI consultation for your business.',
                  icon: Icons.support_agent_outlined,
                  onTap: () { /* TODO: Navigate to Consultation Booking */ },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}