import 'package:flutter_bloc/flutter_bloc.dart';
import 'auth_event.dart';
import 'auth_state.dart';
import '../../data/repositories/auth_repository.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;
  AuthBloc(this._authRepository) : super(AuthInitial()) {
    on<RegisterUser>(_onRegisterUser);
    on<LoginUser>(_onLoginUser);
    on<LoggedOut>(_onLogout);
  }

  Future<void> _onRegisterUser(RegisterUser event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await _authRepository.signUp(
        name: event.name,
        email: event.email,
        password: event.password,
      );
      emit(Authenticated());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onLoginUser(LoginUser event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await _authRepository.login(email: event.email, password: event.password);
      emit(Authenticated());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onLogout(LoggedOut event, Emitter<AuthState> emit) async {
    await _authRepository.logout();
    emit(Unauthenticated());
  }
}
