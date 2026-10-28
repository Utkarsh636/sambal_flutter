class ScannedDocument {
  ScannedDocument({
    required this.id,
    required this.categoryId,
    required this.label,
    required this.imagePaths,
    this.ocrText = '',
    this.confirmedByUser = false,
    required this.scannedAt,
  });

  final String id;
  final String categoryId;
  final String label;
  final List<String> imagePaths;
  final String ocrText;
  final bool confirmedByUser;
  final DateTime scannedAt;

  Map<String, dynamic> toJson() => {
        'id': id,
        'categoryId': categoryId,
        'label': label,
        'imagePaths': imagePaths,
        'ocrText': ocrText,
        'confirmedByUser': confirmedByUser,
        'scannedAt': scannedAt.toIso8601String(),
      };

  factory ScannedDocument.fromJson(Map<String, dynamic> json) =>
      ScannedDocument(
        id: json['id'] as String,
        categoryId: json['categoryId'] as String,
        label: json['label'] as String,
        imagePaths: (json['imagePaths'] as List).cast<String>(),
        ocrText: json['ocrText'] as String? ?? '',
        confirmedByUser: json['confirmedByUser'] as bool? ?? false,
        scannedAt: DateTime.parse(json['scannedAt'] as String),
      );
}
