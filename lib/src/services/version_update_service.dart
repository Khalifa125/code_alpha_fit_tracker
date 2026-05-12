// ignore_for_file: prefer_const_constructors

import '../imports/imports.dart';

class VersionUpdateService {
  const VersionUpdateService._();
  static const VersionUpdateService instance = VersionUpdateService._();

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
