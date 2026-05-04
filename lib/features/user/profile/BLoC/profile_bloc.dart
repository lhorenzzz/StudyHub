import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc() : super(ProfileLoading()) {
    on<ProfileStarted>(_onStarted);
    on<ProfileEditToggled>(_onEditToggled);
    on<ProfileNameChanged>(_onNameChanged);
    on<ProfileEmailChanged>(_onEmailChanged);
    on<ProfileBioChanged>(_onBioChanged);
    on<ProfileSaved>(_onSaved);
  }

  Future<void> _onStarted(ProfileStarted e, Emitter<ProfileState> emit) async {
    emit(ProfileLoading());
    await Future.delayed(const Duration(milliseconds: 500));
    // Dummy data — replace with real user data later
    emit(
      const ProfileLoaded(
        name: 'Lhorenz Magtibay',
        email: 'lhorenz@email.com',
        bio: 'IT student at CatSU. Loves coding and learning new things.',
        totalUploaded: 6,
        totalDone: 2,
        totalStarred: 3,
        totalPinned: 1,
      ),
    );
  }

  // Toggle edit mode — copy current values into edit fields
  void _onEditToggled(ProfileEditToggled e, Emitter<ProfileState> emit) {
    if (state is ProfileLoaded) {
      final cur = state as ProfileLoaded;
      if (cur.isEditing) {
        // Cancel — discard changes, exit edit mode
        emit(cur.copyWith(isEditing: false));
      } else {
        // Enter edit mode — pre-fill edit fields with current values
        emit(
          cur.copyWith(
            isEditing: true,
            editName: cur.name,
            editEmail: cur.email,
            editBio: cur.bio,
          ),
        );
      }
    }
  }

  void _onNameChanged(ProfileNameChanged e, Emitter<ProfileState> emit) {
    if (state is ProfileLoaded)
      emit((state as ProfileLoaded).copyWith(editName: e.name));
  }

  void _onEmailChanged(ProfileEmailChanged e, Emitter<ProfileState> emit) {
    if (state is ProfileLoaded)
      emit((state as ProfileLoaded).copyWith(editEmail: e.email));
  }

  void _onBioChanged(ProfileBioChanged e, Emitter<ProfileState> emit) {
    if (state is ProfileLoaded)
      emit((state as ProfileLoaded).copyWith(editBio: e.bio));
  }

  Future<void> _onSaved(ProfileSaved e, Emitter<ProfileState> emit) async {
    if (state is! ProfileLoaded) return;
    final cur = state as ProfileLoaded;

    emit(cur.copyWith(isSaving: true));
    await Future.delayed(const Duration(milliseconds: 800));

    // Apply edit values to actual profile
    emit(
      cur.copyWith(
        name: cur.editName.isNotEmpty ? cur.editName : cur.name,
        email: cur.editEmail.isNotEmpty ? cur.editEmail : cur.email,
        bio: cur.editBio,
        isEditing: false,
        isSaving: false,
      ),
    );
  }
}
