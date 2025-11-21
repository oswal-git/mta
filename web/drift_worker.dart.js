import 'package:drift/wasm.dart';

void main() {
  driftWorkerMain(() => WasmDatabase.open(
        databaseName: 'mta_db',
        sqlite3Uri: Uri.parse('sqlite3.wasm'),
        driftWorkerUri: Uri.parse('drift_worker.dart.js'),
      ));
}