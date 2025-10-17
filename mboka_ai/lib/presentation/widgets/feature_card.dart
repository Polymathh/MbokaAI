import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class FeatureCard extends StatelessWidget {
  final String title;
  final String text;
  final IconData icon;
  final VoidCallback onTap;

  const FeatureCard({
    super.key,
    required this.title,
    required this.text,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      // Use the background light color for the card body to contrast with blue cards
      color: AppColors.textWhite, 
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              // Image/Icon Area
              Icon(
                icon,
                size: 50,
                color: AppColors.primarySkyBlue,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    text,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.black54,
                        ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}