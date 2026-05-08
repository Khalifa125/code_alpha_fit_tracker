import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fit_tracker/src/features/progress_photos/data/models/progress_photo_models.dart';
import 'package:fit_tracker/src/features/progress_photos/data/services/progress_photo_service.dart';

final progressPhotoServiceProvider = Provider<ProgressPhotoService>((ref) {
  throw UnimplementedError('ProgressPhotoService must be initialized before use');
});

final progressPhotosProvider = StateNotifierProvider<ProgressPhotosNotifier, ProgressPhotosState>((ref) {
  final service = ref.watch(progressPhotoServiceProvider);
  return ProgressPhotosNotifier(service);
});

class ProgressPhotosState {
  final List<ProgressPhoto> photos;
  final bool isLoading;
  final String? selectedCategory;

  ProgressPhotosState({
    this.photos = const [],
    this.isLoading = false,
    this.selectedCategory,
  });

  ProgressPhotosState copyWith({
    List<ProgressPhoto>? photos,
    bool? isLoading,
    String? selectedCategory,
  }) => ProgressPhotosState(
    photos: photos ?? this.photos,
    isLoading: isLoading ?? this.isLoading,
    selectedCategory: selectedCategory ?? this.selectedCategory,
  );
}

class ProgressPhotosNotifier extends StateNotifier<ProgressPhotosState> {
  final ProgressPhotoService _service;
  final ImagePicker _picker = ImagePicker();

  ProgressPhotosNotifier(this._service) : super(ProgressPhotosState()) {
    _loadPhotos();
  }

  Future<void> _loadPhotos() async {
    state = state.copyWith(isLoading: true);
    final photos = await _service.getAllPhotos();
    state = state.copyWith(photos: photos, isLoading: false);
  }

  Future<void> addPhotoFromCamera({String? category, String? note, double? weight}) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      await _service.addPhoto(
        date: DateTime.now(),
        sourcePath: image.path,
        category: category,
        note: note,
        weight: weight,
      );
      await _loadPhotos();
    }
  }

  Future<void> addPhotoFromGallery({String? category, String? note, double? weight}) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      await _service.addPhoto(
        date: DateTime.now(),
        sourcePath: image.path,
        category: category,
        note: note,
        weight: weight,
      );
      await _loadPhotos();
    }
  }

  Future<void> deletePhoto(String id) async {
    await _service.deletePhoto(id);
    await _loadPhotos();
  }

  void setCategory(String? category) {
    state = state.copyWith(selectedCategory: category);
  }

  Future<File?> getPhotoFile(String id) => _service.getPhotoFile(id);
}

final progressComparisonProvider = FutureProvider.family<ProgressComparison?, String>((ref, category) async {
  final service = ref.watch(progressPhotoServiceProvider);
  final photos = await service.getPhotosByCategory(category);
  if (photos.length < 2) return null;
  return ProgressComparison(before: photos.last, after: photos.first);
});