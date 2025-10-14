import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class AppStarted extends AuthEvent {}
class LoggedIn extends AuthEvent {}
class LoggedOut extends AuthEvent {}
class RegisterUser extends AuthEvent {
  final String name;
  final String email;
  final String password;
  RegisterUser({required this.name, required this.email, required this.password});
}
class LoginUser extends AuthEvent {
  final String email;
  final String password;
  LoginUser({required this.email, required this.password});
}
