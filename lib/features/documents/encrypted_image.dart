import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../core/storage/file_crypto.dart';

class EncryptedImage extends StatefulWidget {
  final String path;
  final double? width;
  final double? height;
  final BoxFit fit;

  const EncryptedImage({
    super.key,
    required this.path,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
  });

  @override
  State<EncryptedImage> createState() => _EncryptedImageState();
}

class _EncryptedImageState extends State<EncryptedImage> {
  Uint8List? _bytes;
  bool _error = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(EncryptedImage old) {
    super.didUpdateWidget(old);
    if (old.path != widget.path) _load();
  }

  Future<void> _load() async {
    try {
      final data = await FileCrypto.decryptFile(widget.path);
      if (mounted) setState(() => _bytes = data);
    } catch (_) {
      if (mounted) setState(() => _error = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error) {
      return SizedBox(
        width: widget.width,
        height: widget.height,
        child: const Center(child: Icon(Icons.broken_image_outlined)),
      );
    }
    if (_bytes == null) {
      return SizedBox(
        width: widget.width,
        height: widget.height,
        child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }
    return Image.memory(
      _bytes!,
      width: widget.width,
      height: widget.height,
      fit: widget.fit,
    );
  }
}
