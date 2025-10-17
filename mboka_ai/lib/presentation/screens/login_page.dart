import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../logic/bloc/auth_bloc.dart';
import '../../logic/bloc/auth_event.dart';
import '../../logic/bloc/auth_state.dart';
import '../widgets/auth_card.dart';
import '../widgets/custom_button.dart';
import '../../theme/app_colors.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final GlobalKey<FormState> _loginFormKey = GlobalKey();
  final GlobalKey<FormState> _registerFormKey = GlobalKey();
  
  // Text controllers
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _bizNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _bizNameController.dispose();
    super.dispose();
  }

  // --- Form Submission Handlers ---
  void _onLoginSubmitted() {
    if (_loginFormKey.currentState!.validate()) {
      BlocProvider.of<AuthBloc>(context).add(
        AuthLoginRequested(
          email: _emailController.text,
          password: _passwordController.text,
        ),
      );
    }
  }

  void _onRegisterSubmitted() {
    if (_registerFormKey.currentState!.validate()) {
      BlocProvider.of<AuthBloc>(context).add(
        AuthRegisterRequested(
          email: _emailController.text,
          password: _passwordController.text,
          businessName: _bizNameController.text,
        ),
      );
    }
  }

  // --- UI Builder Functions ---
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String? Function(String?) validator,
    bool isPassword = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword,
        style: const TextStyle(color: AppColors.textWhite),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: AppColors.textWhite),
          filled: true,
          fillColor: Colors.white.withOpacity(0.15), // Semi-transparent for contrast
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12), // Rounded inputs
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.primarySkyBlue, width: 2),
          ),
        ),
        validator: validator,
      ),
    );
  }

  // --- Login Form UI ---
  Widget _buildLoginForm(bool isLoading) {
    return Form(
      key: _loginFormKey,
      child: Column(
        children: [
          _buildTextField(
            controller: _emailController,
            label: 'Email Address',
            validator: (value) {
              if (value == null || value.isEmpty || !value.contains('@')) {
                return 'Enter a valid email.';
              }
              return null;
            },
          ),
          _buildTextField(
            controller: _passwordController,
            label: 'Password',
            isPassword: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Password cannot be empty.';
              }
              return null;
            },
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                // TODO: Implement Forgot Password functionality later
              },
              child: const Text(
                'Forgot Password?',
                style: TextStyle(color: AppColors.textWhite),
              ),
            ),
          ),
          const SizedBox(height: 16),
          CustomElevatedButton(
            text: 'Login',
            onPressed: _onLoginSubmitted,
            isLoading: isLoading,
          ),
        ],
      ),
    );
  }

  // --- Register Form UI ---
  Widget _buildRegisterForm(bool isLoading) {
    return Form(
      key: _registerFormKey,
      child: Column(
        children: [
          _buildTextField(
            controller: _bizNameController,
            label: 'Business Name',
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Business name is required.';
              }
              return null;
            },
          ),
          _buildTextField(
            controller: _emailController,
            label: 'Email Address',
            validator: (value) {
              if (value == null || value.isEmpty || !value.contains('@')) {
                return 'Enter a valid email.';
              }
              return null;
            },
          ),
          _buildTextField(
            controller: _passwordController,
            label: 'Password (Min 8 characters)',
            isPassword: true,
            validator: (value) {
              if (value == null || value.length < 8) {
                return 'Password must be at least 8 characters.';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),
          CustomElevatedButton(
            text: 'Register',
            onPressed: _onRegisterSubmitted,
            isLoading: isLoading,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500), // Max width for web/desktop
            child: BlocConsumer<AuthBloc, AuthState>(
              listener: (context, state) {
                if (state is AuthAuthenticated) {
                  // Handled by Splash Screen, but good to have a fallback
                  Navigator.of(context).pushReplacementNamed('/home');
                } else if (state is AuthError) {
                  // Show the error message (UX Feel: minimal clutter)
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              builder: (context, state) {
                final bool isLoading = state is AuthLoading;

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Tabs
                    TabBar(
                      controller: _tabController,
                      indicatorColor: AppColors.primarySkyBlue,
                      labelColor: AppColors.primarySkyBlue,
                      unselectedLabelColor: Colors.black54,
                      tabs: const [
                        Tab(text: 'Login'),
                        Tab(text: 'Register'),
                      ],
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 500, // Fixed height for tab content
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          // Login Tab
                          AuthCard(
                            title: 'Welcome Back!',
                            child: _buildLoginForm(isLoading),
                          ),
                          // Register Tab
                          AuthCard(
                            title: 'Join MbokaAI',
                            child: _buildRegisterForm(isLoading),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}