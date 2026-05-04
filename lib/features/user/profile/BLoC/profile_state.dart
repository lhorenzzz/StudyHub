part of 'profile_bloc.dart';

abstract class ProfileState extends Equatable {
  const ProfileState();
  @override
  List<Object?> get props => [];
}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final String name;
  final String email;
  final String bio;
  final bool isEditing;
  final bool isSaving;

  // Stats
  final int totalUploaded;
  final int totalDone;
  final int totalStarred;
  final int totalPinned;

  // Edit form fields (separate from saved values so cancel works)
  final String editName;
  final String editEmail;
  final String editBio;

  const ProfileLoaded({
    required this.name,
    required this.email,
    required this.bio,
    this.isEditing = false,
    this.isSaving = false,
    this.totalUploaded = 0,
    this.totalDone = 0,
    this.totalStarred = 0,
    this.totalPinned = 0,
    this.editName = '',
    this.editEmail = '',
    this.editBio = '',
  });

  ProfileLoaded copyWith({
    String? name,
    String? email,
    String? bio,
    bool? isEditing,
    bool? isSaving,
    int? totalUploaded,
    int? totalDone,
    int? totalStarred,
    int? totalPinned,
    String? editName,
    String? editEmail,
    String? editBio,
  }) {
    return ProfileLoaded(
      name: name ?? this.name,
      email: email ?? this.email,
      bio: bio ?? this.bio,
      isEditing: isEditing ?? this.isEditing,
      isSaving: isSaving ?? this.isSaving,
      totalUploaded: totalUploaded ?? this.totalUploaded,
      totalDone: totalDone ?? this.totalDone,
      totalStarred: totalStarred ?? this.totalStarred,
      totalPinned: totalPinned ?? this.totalPinned,
      editName: editName ?? this.editName,
      editEmail: editEmail ?? this.editEmail,
      editBio: editBio ?? this.editBio,
    );
  }

  // Initials for avatar display
  String get initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    if (parts[0].isNotEmpty) return parts[0][0].toUpperCase();
    return '?';
  }

  @override
  List<Object?> get props => [
    name,
    email,
    bio,
    isEditing,
    isSaving,
    totalUploaded,
    totalDone,
    totalStarred,
    totalPinned,
    editName,
    editEmail,
    editBio,
  ];
}

class ProfileSaveSuccess extends ProfileState {
  const ProfileSaveSuccess();
}

class ProfileError extends ProfileState {
  final String message;
  const ProfileError(this.message);
  @override
  List<Object?> get props => [message];
}
