part of 'auth_bloc.dart';

// AuthState is the base class for all possible states of the Auth feature.
// The UI listens to these states and rebuilds accordingly.
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object> get props => [];
}

// Default/initial state when the page first loads
// isLogin = true means Login form is shown, false = Register form
class AuthInitial extends AuthState {
  final bool isLogin;
  const AuthInitial({this.isLogin = true});

  @override
  List<Object> get props => [isLogin];
}

// Emitted while waiting for login/register to complete
// UI shows a loading spinner in this state
class AuthLoading extends AuthState {}

// Emitted when login or register succeeds
class AuthSuccess extends AuthState {
  final String message;
  const AuthSuccess({required this.message});

  @override
  List<Object> get props => [message];
}

// Emitted when login or register fails (e.g. empty fields, wrong password)
class AuthFailure extends AuthState {
  final String error;
  const AuthFailure({required this.error});

  @override
  List<Object> get props => [error];
}
