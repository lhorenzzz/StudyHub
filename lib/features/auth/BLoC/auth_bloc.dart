import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

// These two files are "parts" of this file — they share the same library
part 'auth_event.dart';
part 'auth_state.dart';

// AuthBloc is the brain of the Auth feature.
// It receives AuthEvents from the UI and emits AuthStates back.
// Flow: UI dispatches event → Bloc processes → Bloc emits state → UI rebuilds
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  // Start with AuthInitial (login form showing by default)
  AuthBloc() : super(const AuthInitial()) {
    // Register event handlers — each event maps to a handler function
    on<LoginSubmitted>(_onLogin);
    on<RegisterSubmitted>(_onRegister);
    on<AuthToggleForm>(_onToggle);
  }

  // Tracks which form is currently active
  bool _isLogin = true;

  // Toggles between Login and Register form
  void _onToggle(AuthToggleForm event, Emitter<AuthState> emit) {
    _isLogin = !_isLogin;
    emit(AuthInitial(isLogin: _isLogin));
  }

  // Handles login logic
  Future<void> _onLogin(LoginSubmitted event, Emitter<AuthState> emit) async {
    // Show loading spinner
    emit(AuthLoading());

    // Simulate network delay — replace this with real Firebase/API call later
    await Future.delayed(const Duration(seconds: 1));

    if (event.email.isEmpty || event.password.isEmpty) {
      emit(const AuthFailure(error: 'Please fill in all fields.'));
    } else {
      final isAdmin = event.email == 'admin@studyhub.com';
      emit(
        AuthSuccess(
          message: 'Login successful!',
          role: isAdmin ? 'admin' : 'student',
        ),
      );
    }
  }

  // Handles registration logic
  Future<void> _onRegister(
    RegisterSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    // Show loading spinner
    emit(AuthLoading());

    // Simulate network delay — replace with real API call later
    await Future.delayed(const Duration(seconds: 1));

    // Basic validation
    if (event.name.isEmpty || event.email.isEmpty || event.password.isEmpty) {
      emit(const AuthFailure(error: 'Please fill in all fields.'));
    } else {
      // TODO: Replace with real registration (Firebase, REST API, etc.)
      emit(const AuthSuccess(message: 'Account created!'));
    }
  }
}
