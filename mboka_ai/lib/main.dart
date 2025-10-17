import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart'; 
import 'theme/app_theme.dart';
import 'data/repositories/auth_repository.dart';
import 'logic/bloc/auth_bloc.dart';
import 'presentation/screens/splash_screen.dart'; // The initial screen
import 'presentation/screens/home_dashboard.dart';
import 'presentation/screens/login_page.dart';

import 'logic/bloc/auth_event.dart'; 
// import 'presentation/screens/splash_screen.dart'; 
// import 'presentation/screens/home_dashboard.dart';
// import 'presentation/screens/login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MbokaAIApp());
}

class MbokaAIApp extends StatelessWidget {
  const MbokaAIApp({super.key});

  @override
  Widget build(BuildContext context) {
    // We use RepositoryProvider to provide the AuthRepository to our BLoCs
    return RepositoryProvider(
      create: (context) => AuthRepository(firebaseAuth: FirebaseAuth.instance),
      child: BlocProvider(
        // The main AuthBloc is created and has access to the AuthRepository
        create: (context) => AuthBloc(
          authRepository: RepositoryProvider.of<AuthRepository>(context),
        )..add(AppStarted()), // Trigger the initial state check
        child: MaterialApp(
          title: 'MbokaAI',
          theme: AppTheme.lightTheme,
          // The Splash screen will handle the initial routing based on AuthBloc state
          home: const SplashScreen(), 
          routes: {
            '/login': (context) => const LoginPage(),
            '/home': (context) => const HomeDashboard(),
          },
        ),
      ),
    );
  }
}