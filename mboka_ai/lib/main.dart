import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'blocs/auth/auth_bloc.dart';
import 'data/repositories/auth_repository.dart';
import 'screens/auth/login_screen.dart';
import 'screens/dashboard/dashboard_screen.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'blocs/auth/auth_state.dart';
import 'blocs/dashboard/dashboard_bloc.dart';
import 'blocs/visual_generator/visual_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// import 'blocs/auth/auth_event.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await dotenv.load(fileName: ".env");
  runApp(const MbokaAIApp());
}

final apiKey = dotenv.env['GEMINI_API_KEY'];

class MbokaAIApp extends StatelessWidget {
  const MbokaAIApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authRepository = AuthRepository();
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AuthBloc(authRepository),
        ),
        BlocProvider(
            create: (_) => DashboardBloc(firestore: FirebaseFirestore.instance)),
            BlocProvider(
              create: (_) => VisualBloc(storage: FirebaseStorage.instance),
        )
      ],
      child: MaterialApp(
        title: 'MbokaAI',
        theme: ThemeData(primarySwatch: Colors.green),
        debugShowCheckedModeBanner: false,
        home: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (state is Authenticated) return const DashboardScreen();
            if (state is AuthLoading) return const Center(child: CircularProgressIndicator());
            return const LoginScreen();
          },
        ),
      ),
    );
  }
}
