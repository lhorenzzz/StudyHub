import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
    on<LogoutRequested>(_onLogout);
    on<AuthCheckRequested>(_onAuthCheck);
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

    try {
      final userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: event.email,
        password: event.password,
      );

      final user = userCredential.user;
      if (user != null) {
        final isAdmin = event.email == 'admin@studyhub.com';
        emit(
          AuthSuccess(
            message: 'Login successful!',
            role: isAdmin ? 'admin' : 'student',
            uid: user.uid,
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'No user found with this email.';
          break;
        case 'wrong-password':
          errorMessage = 'Wrong password provided.';
          break;
        case 'invalid-email':
          errorMessage = 'Invalid email address.';
          break;
        case 'user-disabled':
          errorMessage = 'This user account has been disabled.';
          break;
        default:
          errorMessage = 'Login failed: ${e.message}';
      }
      emit(AuthFailure(error: errorMessage));
    } catch (e) {
      emit(AuthFailure(error: 'An unexpected error occurred.'));
    }
  }

  // Handles registration logic
  Future<void> _onRegister(
    RegisterSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    // Show loading spinner
    emit(AuthLoading());

    try {
      final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: event.email,
        password: event.password,
      );

      final user = userCredential.user;
      if (user != null) {
        // Update display name
        await user.updateDisplayName(event.name);
        await user.reload();

        emit(const AuthSuccess(message: 'Account created successfully!'));
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'weak-password':
          errorMessage = 'The password provided is too weak.';
          break;
        case 'email-already-in-use':
          errorMessage = 'An account already exists with this email.';
          break;
        case 'invalid-email':
          errorMessage = 'Invalid email address.';
          break;
        default:
          errorMessage = 'Registration failed: ${e.message}';
      }
      emit(AuthFailure(error: errorMessage));
    } catch (e) {
      emit(AuthFailure(error: 'An unexpected error occurred.'));
    }
  }

  // Handles logout — clears state back to login form
  Future<void> _onLogout(LogoutRequested event, Emitter<AuthState> emit) async {
    await FirebaseAuth.instance.signOut();
    _isLogin = true;
    emit(const AuthInitial());
  }

  // Checks on app start if a user session already exists
  Future<void> _onAuthCheck(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final isAdmin = user.email == 'admin@studyhub.com';
      emit(
        AuthSuccess(
          message: 'Welcome back!',
          role: isAdmin ? 'admin' : 'student',
          uid: user.uid,
        ),
      );
    } else {
      emit(const AuthInitial());
    }
  }
}
