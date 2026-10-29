import 'dart:io';

import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import '../../core/storage/file_crypto.dart';

class ScannerService {
  static final _picker = ImagePicker();

  static Future<String?> captureFromCamera() async {
    final xFile = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
    );
    if (xFile == null) return null;
    return _saveEncrypted(xFile);
  }

  static Future<String?> pickFromGallery() async {
    final xFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (xFile == null) return null;
    return _saveEncrypted(xFile);
  }

  static Future<String> _saveEncrypted(XFile xFile) async {
    final dir = await getApplicationDocumentsDirectory();
    final scanDir = Directory('${dir.path}/scans');
    if (!scanDir.existsSync()) scanDir.createSync(recursive: true);
    final name = '${DateTime.now().millisecondsSinceEpoch}_${xFile.name}';
    final dest = '${scanDir.path}/$name';
    await xFile.saveTo(dest);
    await FileCrypto.encryptFile(dest);
    return dest;
  }

  static Future<File> getDecryptedTempFile(String encryptedPath) async {
    final bytes = await FileCrypto.decryptFile(encryptedPath);
    final tmpDir = await getTemporaryDirectory();
    final tmpFile = File(
        '${tmpDir.path}/dec_${DateTime.now().millisecondsSinceEpoch}.jpg');
    await tmpFile.writeAsBytes(bytes);
    return tmpFile;
  }

  static Future<String> recognizeText(String encryptedPath) async {
    final tmpFile = await getDecryptedTempFile(encryptedPath);
    try {
      final inputImage = InputImage.fromFilePath(tmpFile.path);
      final recognizer = TextRecognizer();
      try {
        final result = await recognizer.processImage(inputImage);
        return result.text;
      } finally {
        await recognizer.close();
      }
    } finally {
      if (await tmpFile.exists()) await tmpFile.delete();
    }
  }

  static Future<void> deleteFile(String path) async {
    final file = File(path);
    if (await file.exists()) await file.delete();
  }

  static Future<void> deleteAllScans() async {
    final dir = await getApplicationDocumentsDirectory();
    final scanDir = Directory('${dir.path}/scans');
    if (await scanDir.exists()) await scanDir.delete(recursive: true);
  }
}
