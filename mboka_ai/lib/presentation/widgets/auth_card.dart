import 'package:flutter/material.dart';

class AuthCard extends StatelessWidget {
  final Widget child;
  final String title;

  const AuthCard({
    super.key,
    required this.child,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    // Card uses AppTheme's CardTheme: Blue background, white text, 16px radius
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Theme.of(context).colorScheme.onPrimary, // White text
                fontWeight: FontWeight.w600, // Poppins Semi-bold
              ),
            ),
            const SizedBox(height: 40),
            child,
          ],
        ),
      ),
    );
  }
}