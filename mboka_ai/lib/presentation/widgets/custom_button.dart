import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class CustomElevatedButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;

  const CustomElevatedButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: Theme.of(context).elevatedButtonTheme.style!.copyWith(
          // Subtle shadow/motion feedback on press
          overlayColor: MaterialStateProperty.resolveWith<Color?>(
            (Set<MaterialState> states) {
              if (states.contains(MaterialState.pressed)) {
                return AppColors.primaryDarkBlue; // Slightly darker blue
              }
              return null;
            },
          ),
        ),
        child: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  color: AppColors.textWhite,
                  strokeWidth: 2.0,
                ),
              )
            : Text(text),
      ),
    );
  }
}