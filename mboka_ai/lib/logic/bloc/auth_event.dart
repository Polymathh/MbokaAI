import 'package:equatable/equatable.dart';
import '../../data/models/user_model.dart';
abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object> get props => [];
}

// Check initial status and listen to stream
class AppStarted extends AuthEvent {}

// Triggered when user attempts to log in
class AuthLoginRequested extends AuthEvent {
  final String email;
  final String password;
  const AuthLoginRequested({required this.email, required this.password});
  @override
  List<Object> get props => [email, password];
}

// Triggered when user attempts to register
class AuthRegisterRequested extends AuthEvent {
  final String email;
  final String password;
  final String businessName;
  const AuthRegisterRequested({
    required this.email,
    required this.password,
    required this.businessName,
  });
  @override
  List<Object> get props => [email, password, businessName];
}

// Triggered on successful sign-in/sign-up or when stream detects an active user
// class AuthUserChanged extends AuthEvent {
//   final bool isAuthenticated;
//   const AuthUserChanged({required this.isAuthenticated});
//   @override
//   List<Object> get props => [isAuthenticated];
// }

class AuthUserChanged extends AuthEvent {
  final AppUser user; // Changed to AppUser
  const AuthUserChanged({required this.user});
  @override
  List<Object> get props => [user];
}

// Triggered when user attempts to sign out
class AuthLogoutRequested extends AuthEvent {}