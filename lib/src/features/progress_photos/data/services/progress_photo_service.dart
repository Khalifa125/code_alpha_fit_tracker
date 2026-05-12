import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fit_tracker/src/features/progress_photos/data/models/progress_photo_models.dart';

class ProgressPhotoService {
  static const _entriesKey = 'progress_photos';
  static const _photosFolder = 'progress_photos';

  final SharedPreferences _prefs;

  ProgressPhotoService(this._prefs);

  static Future<ProgressPhotoService> init() async {
    final prefs = await SharedPreferences.getInstance();
    return ProgressPhotoService(prefs);
  }

  Future<String> get _photosPath async {
    final dir = await getApplicationDocumentsDirectory();
    final photosDir = Directory('${dir.path}/$_photosFolder');
    if (!await photosDir.exists()) {
      await photosDir.create(recursive: true);
    }
    return photosDir.path;
  }

  List<ProgressPhoto> _getAllEntries() {
    final data = _prefs.getString(_entriesKey);
    if (data == null) return [];
    final list = jsonDecode(data) as List;
    return list.map((e) => ProgressPhoto.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<ProgressPhoto>> getAllPhotos() async {
    final all = _getAllEntries();
    return all..sort((a, b) => b.date.compareTo(a.date));
  }

  Future<List<ProgressPhoto>> getPhotosByCategory(String category) async {
    final all = _getAllEntries();
    return all.where((p) => p.category == category).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  Future<ProgressPhoto> addPhoto({
    required DateTime date,
    required String sourcePath,
    String? category,
    String? note,
    double? weight,
  }) async {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final ext = sourcePath.split('.').last;
    final destPath = '${await _photosPath}/$id.$ext';
    
    await File(sourcePath).copy(destPath);
    
    final photo = ProgressPhoto(
      id: id,
      date: date,
      imagePath: destPath,
      category: category,
      note: note,
      weight: weight,
    );
    
    final all = _getAllEntries();
    all.add(photo);
    await _prefs.setString(_entriesKey, jsonEncode(all.map((e) => e.toJson()).toList()));
    
    return photo;
  }

  Future<void> deletePhoto(String id) async {
    final all = _getAllEntries();
    final photo = all.firstWhere((p) => p.id == id, orElse: () => throw Exception('Not found'));
    
    if (photo.imagePath != null) {
      final file = File(photo.imagePath!);
      if (await file.exists()) await file.delete();
    }
    
    all.removeWhere((p) => p.id == id);
    await _prefs.setString(_entriesKey, jsonEncode(all.map((e) => e.toJson()).toList()));
  }

  Future<File?> getPhotoFile(String id) async {
    final all = _getAllEntries();
    final photo = all.where((p) => p.id == id).firstOrNull;
    if (photo?.imagePath == null) return null;
    final file = File(photo!.imagePath!);
    return file.existsSync() ? file : null;
  }
}
