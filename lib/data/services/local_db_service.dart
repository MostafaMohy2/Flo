// Conditional export: sqflite on mobile/desktop, hive on web.
// Both implementations expose the exact same LocalDbService class.
export 'local_db_service_mobile.dart'
    if (dart.library.html) 'local_db_service_web.dart';
