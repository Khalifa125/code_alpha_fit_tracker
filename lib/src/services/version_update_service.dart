import '../imports/imports.dart';

class VersionUpdateService {
  VersionUpdateService._();
  static final VersionUpdateService instance = VersionUpdateService._();

  FutureEither<void> checkForUpdate({String? appleId, String? playStoreId}) async {
    return Right(null);
  }

  FutureEither<void> checkAndShowUpdate({
    String? appleId,
    String? playStoreId,
    bool mandatory = false,
  }) async {
    return Right(null);
  }
}
