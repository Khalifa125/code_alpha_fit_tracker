import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fit_tracker/src/features/progress_photos/data/models/progress_photo_models.dart';
import 'package:fit_tracker/src/features/progress_photos/data/services/progress_photo_service.dart';

final progressPhotoServiceProvider = Provider<ProgressPhotoService>((ref) {
  throw UnimplementedError('ProgressPhotoService must be initialized before use');
});

final progressPhotosProvider = NotifierProvider<ProgressPhotosNotifier, ProgressPhotosState>(() => ProgressPhotosNotifier());

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

class ProgressPhotosNotifier extends Notifier<ProgressPhotosState> {
  final ImagePicker _picker = ImagePicker();

  @override
  ProgressPhotosState build() {
    final service = ref.watch(progressPhotoServiceProvider);
    Future.microtask(() => _loadPhotos(service));
    return ProgressPhotosState();
  }

  Future<void> _loadPhotos(ProgressPhotoService service) async {
    try {
      state = state.copyWith(isLoading: true);
      final photos = await service.getAllPhotos();
      state = state.copyWith(photos: photos, isLoading: false);
    } catch (_) {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> addPhotoFromCamera({String? category, String? note, double? weight}) async {
    final service = ref.read(progressPhotoServiceProvider);
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      await service.addPhoto(
        date: DateTime.now(),
        sourcePath: image.path,
        category: category,
        note: note,
        weight: weight,
      );
      _loadPhotos(service);
    }
  }

  Future<void> addPhotoFromGallery({String? category, String? note, double? weight}) async {
    final service = ref.read(progressPhotoServiceProvider);
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      await service.addPhoto(
        date: DateTime.now(),
        sourcePath: image.path,
        category: category,
        note: note,
        weight: weight,
      );
      _loadPhotos(service);
    }
  }

  Future<void> deletePhoto(String id) async {
    final service = ref.read(progressPhotoServiceProvider);
    await service.deletePhoto(id);
    _loadPhotos(service);
  }

  void setCategory(String? category) {
    state = state.copyWith(selectedCategory: category);
  }

  Future<File?> getPhotoFile(String id) {
    final service = ref.read(progressPhotoServiceProvider);
    return service.getPhotoFile(id);
  }
}

final progressComparisonProvider = FutureProvider.family<ProgressComparison?, String>((ref, category) async {
  final service = ref.watch(progressPhotoServiceProvider);
  final photos = await service.getPhotosByCategory(category);
  if (photos.length < 2) return null;
  return ProgressComparison(before: photos.last, after: photos.first);
});
