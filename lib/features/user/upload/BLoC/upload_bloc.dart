import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

part 'upload_event.dart';
part 'upload_state.dart';

class UploadBloc extends Bloc<UploadEvent, UploadState> {
  UploadBloc() : super(const UploadIdle()) {
    on<UploadTitleChanged>(_onTitleChanged);
    on<UploadFileSelected>(_onFileSelected);
    on<UploadCategoryChanged>(_onCategoryChanged);
    on<UploadDifficultyChanged>(_onDifficultyChanged);
    on<UploadDescriptionChanged>(_onDescriptionChanged);
    on<UploadTagsChanged>(_onTagsChanged);
    on<UploadSubmitted>(_onSubmitted);
    on<UploadReset>(_onReset);
  }

  void _onTitleChanged(UploadTitleChanged e, Emitter<UploadState> emit) {
    if (state is UploadIdle)
      emit((state as UploadIdle).copyWith(title: e.title));
  }

  void _onFileSelected(UploadFileSelected e, Emitter<UploadState> emit) {
    if (state is UploadIdle) {
      emit(
        (state as UploadIdle).copyWith(
          fileName: e.fileName,
          fileType: e.fileType,
        ),
      );
    }
  }

  void _onCategoryChanged(UploadCategoryChanged e, Emitter<UploadState> emit) {
    if (state is UploadIdle) {
      emit(
        (state as UploadIdle).copyWith(
          categoryId: e.categoryId,
          categoryName: e.categoryName,
        ),
      );
    }
  }

  void _onDifficultyChanged(
    UploadDifficultyChanged e,
    Emitter<UploadState> emit,
  ) {
    if (state is UploadIdle)
      emit((state as UploadIdle).copyWith(difficulty: e.difficulty));
  }

  void _onDescriptionChanged(
    UploadDescriptionChanged e,
    Emitter<UploadState> emit,
  ) {
    if (state is UploadIdle)
      emit((state as UploadIdle).copyWith(description: e.description));
  }

  void _onTagsChanged(UploadTagsChanged e, Emitter<UploadState> emit) {
    if (state is UploadIdle) emit((state as UploadIdle).copyWith(tags: e.tags));
  }

  Future<void> _onSubmitted(
    UploadSubmitted e,
    Emitter<UploadState> emit,
  ) async {
    if (state is! UploadIdle) return;
    final current = state as UploadIdle;
    if (!current.isValid) {
      emit(const UploadFailure('Please fill in all required fields.'));
      await Future.delayed(const Duration(seconds: 2));
      emit(current);
      return;
    }

    emit(UploadLoading());
    // Simulate upload delay — replace with real backend later
    await Future.delayed(const Duration(milliseconds: 1200));
    emit(UploadSuccess(current.title));
  }

  void _onReset(UploadReset e, Emitter<UploadState> emit) {
    emit(const UploadIdle());
  }
}
