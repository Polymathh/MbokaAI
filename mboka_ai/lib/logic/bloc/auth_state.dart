import 'package:equatable/equatable.dart';
import '../../data/models/user_model.dart';


abstract class AuthState extends Equatable {
  const AuthState();
  @override
  List<Object> get props => [];
}

// Initial state, before any check is made
class AuthInitial extends AuthState {}

// User is authenticated (Show Dashboard)
class AuthAuthenticated extends AuthState {
  final AppUser user;
  const AuthAuthenticated({required this.user});
  @override
  List<Object> get props => [user];
}
// class AuthAuthenticated extends AuthState {}

// User is NOT authenticated (Show Login/Register)
class AuthUnauthenticated extends AuthState {}

// A request (login/register/logout) is in progress (Show Loading Indicator)
class AuthLoading extends AuthState {}

// A request failed (Show Error Message)
class AuthError extends AuthState {
  final String message;
  const AuthError({required this.message});
  @override
  List<Object> get props => [message];
}