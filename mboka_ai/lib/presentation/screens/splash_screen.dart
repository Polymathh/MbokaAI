import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../logic/bloc/auth_bloc.dart';
import '../../logic/bloc/auth_state.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            // User is logged in, navigate to the Dashboard
            Navigator.of(context).pushReplacementNamed('/home');
          } else if (state is AuthUnauthenticated) {
            // User is not logged in, navigate to the Login/Register page
            Navigator.of(context).pushReplacementNamed('/login');
          }
          // The AuthInitial and AuthLoading states keep the splash screen visible
        },
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animated logo (Fade-in as requested)
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(seconds: 1),
                builder: (context, opacity, child) {
                  return Opacity(
                    opacity: opacity,
                    child: child,
                  );
                },
                child: Image.asset(
                  'assets/mboka_logo.png', // Replace with your actual logo asset path
                  height: 150,
                  width: 150,
                ),
              ),
              const SizedBox(height: 20),
              // Use the primary color for the loading indicator
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).primaryColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}