import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../logic/bloc/auth_bloc.dart';
import '../../logic/bloc/auth_event.dart';
import '../../logic/bloc/auth_state.dart';
import '../../data/models/user_model.dart';
import '../../theme/app_colors.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userState = context.watch<AuthBloc>().state;
    final AppUser user = userState is AuthAuthenticated 
        ? userState.user 
        : AppUser.empty;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Account & Profile'),
        backgroundColor: AppColors.primarySkyBlue,
        foregroundColor: AppColors.textWhite,
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              const Icon(Icons.person_pin, size: 80, color: AppColors.secondaryBlue),
              const SizedBox(height: 20),
              Text(
                user.businessName,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              Text(
                user.email,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey),
              ),
              const SizedBox(height: 40),
              
              // Logout Button
              ElevatedButton.icon(
                icon: const Icon(Icons.logout),
                label: const Text('Logout'),
                onPressed: () {
                  // Dispatch the logout event
                  BlocProvider.of<AuthBloc>(context).add(AuthLogoutRequested());
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: AppColors.textWhite,
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}