import 'package:flutter/material.dart';

import 'app.dart';
import 'core/storage/local_storage.dart';
import 'features/documents/scanner_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalStorage.init();
  LocalStorage.migratePlaintextPin();
  ScannerService.cleanupTempDecrypted();
  runApp(const SambalApp());
}
