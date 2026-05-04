part of 'profile_bloc.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();
  @override
  List<Object?> get props => [];
}

// Load profile data
class ProfileStarted extends ProfileEvent {}

// Toggle edit mode on/off
class ProfileEditToggled extends ProfileEvent {}

// Field change events
class ProfileNameChanged extends ProfileEvent {
  final String name;
  const ProfileNameChanged(this.name);
  @override
  List<Object?> get props => [name];
}

class ProfileEmailChanged extends ProfileEvent {
  final String email;
  const ProfileEmailChanged(this.email);
  @override
  List<Object?> get props => [email];
}

class ProfileBioChanged extends ProfileEvent {
  final String bio;
  const ProfileBioChanged(this.bio);
  @override
  List<Object?> get props => [bio];
}

class ProfilePasswordChanged extends ProfileEvent {
  final String currentPassword;
  final String newPassword;
  const ProfilePasswordChanged({
    required this.currentPassword,
    required this.newPassword,
  });
  @override
  List<Object?> get props => [currentPassword, newPassword];
}

// Save profile changes
class ProfileSaved extends ProfileEvent {}
