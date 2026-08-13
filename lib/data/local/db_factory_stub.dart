import 'package:sqflite/sqflite.dart';

/// Fallback when neither html nor io is available (should not run in practice).
Future<void> initDatabaseFactory() async {
  // Leave default factory; open may fail without a platform factory.
}

Future<String> resolveDatabasePath(String dbName) async => dbName;

Future<Database> openAppDatabase({
  required String path,
  required int version,
  OnDatabaseConfigureFn? onConfigure,
  required OnDatabaseCreateFn onCreate,
  required OnDatabaseVersionChangeFn onUpgrade,
}) {
  return openDatabase(
    path,
    version: version,
    onConfigure: onConfigure,
    onCreate: onCreate,
    onUpgrade: onUpgrade,
  );
}
