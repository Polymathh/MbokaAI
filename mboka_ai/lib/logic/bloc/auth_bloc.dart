import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../data/repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';
import '../../data/models/user_model.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;
  late StreamSubscription<User?> _userSubscription;

  // AuthBloc({required AuthRepository authRepository})
  //     : _authRepository = authRepository,
  //       super(AuthInitial()) {
  //   // Listen for the Firebase user stream changes immediately
  //   _userSubscription = _authRepository.user.listen(
  //     (user) => add(AuthUserChanged(isAuthenticated: user != null)),
  //   );
  AuthBloc({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(AuthInitial()) {
    // 💡 Update listener to handle async user data fetch
    _userSubscription = _authRepository.user.listen(
      (user) async {
        if (user != null) {
          // Fetch the full user model with business name
          final appUser = await _authRepository.getUserData(user);
          add(AuthUserChanged(user: appUser));
        } else {
          add(AuthUserChanged(user: AppUser.empty));
        }
      },
    );


    // Register all event handlers
    on<AppStarted>(_onAppStarted);
    on<AuthUserChanged>(_onAuthUserChanged);
    on<AuthLoginRequested>(_onAuthLoginRequested);
    on<AuthRegisterRequested>(_onAuthRegisterRequested);
    on<AuthLogoutRequested>(_onAuthLogoutRequested);
  }

  // Initial check (from AppStarted event)
  void _onAppStarted(AppStarted event, Emitter<AuthState> emit) async {
    // The AuthUserChanged event will handle the final state change
    // This event simply ensures the stream has time to fire.
    // The stream listener is the main source of truth.
  }

  // Handle stream updates
  // void _onAuthUserChanged(AuthUserChanged event, Emitter<AuthState> emit) {
  //   emit(event.isAuthenticated ? AuthAuthenticated() : AuthUnauthenticated());
  // }

  void _onAuthUserChanged(AuthUserChanged event, Emitter<AuthState> emit) {
    if (event.user.uid.isNotEmpty) {
      emit(AuthAuthenticated(user: event.user)); // Pass the AppUser
    } else {
      emit(AuthUnauthenticated());
    }
  }
  
  // Handle Login
  void _onAuthLoginRequested(
      AuthLoginRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await _authRepository.signIn(
        email: event.email,
        password: event.password,
      );
      // Success will be caught by the stream and AuthUserChanged event
    } catch (e) {
      emit(AuthError(message: e.toString().replaceFirst('Exception: ', '')));
      // Immediately revert to Unauthenticated state to allow user to retry
      emit(AuthUnauthenticated()); 
    }
  }

  // Handle Registration
  void _onAuthRegisterRequested(
      AuthRegisterRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await _authRepository.signUp(
        email: event.email,
        password: event.password,
        businessName: event.businessName,
      );
      // Success will be caught by the stream and AuthUserChanged event
    } catch (e) {
      emit(AuthError(message: e.toString().replaceFirst('Exception: ', '')));
      emit(AuthUnauthenticated());
    }
  }

  // Handle Logout
  void _onAuthLogoutRequested(
      AuthLogoutRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    await _authRepository.signOut();
    // The stream will detect the sign-out and fire AuthUserChanged(false)
  }

  @override
  Future<void> close() {
    _userSubscription.cancel();
    return super.close();
  }
}