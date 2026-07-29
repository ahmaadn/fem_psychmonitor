import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

Future<void> initDatabaseFactory() async {
  databaseFactory = databaseFactoryFfiWeb;
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
