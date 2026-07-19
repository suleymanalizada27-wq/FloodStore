import 'package:equatable/equatable.dart';

/// Visual search result
class VisualSearchResult extends Equatable {
  final String id;
  final String imageUrl;
  final List<VisualMatch> matches;
  final DateTime searchedAt;
  final VisualSearchStatus status;
  final String? errorMessage;

  const VisualSearchResult({
    required this.id,
    required this.imageUrl,
    this.matches = const [],
    required this.searchedAt,
    this.status = VisualSearchStatus.completed,
    this.errorMessage,
  });

  @override
  List<Object?> get props => [id, imageUrl, matches, searchedAt, status, errorMessage];

  Map<String, dynamic> toFirestore() {
    return {
      'imageUrl': imageUrl,
      'matches': matches.map((m) => m.toFirestore()).toList(),
      'searchedAt': searchedAt.toIso8601String(),
      'status': status.name,
      'errorMessage': errorMessage,
    };
  }

  static VisualSearchResult fromFirestore(Map<String, dynamic> data, String id) {
    return VisualSearchResult(
      id: id,
      imageUrl: data['imageUrl'] ?? '',
      matches: (data['matches'] as List?)
              ?.map((m) => VisualMatch.fromFirestore(m))
              .toList() ??
          [],
      searchedAt: DateTime.parse(data['searchedAt'] ?? DateTime.now().toIso8601String()),
      status: VisualSearchStatus.values.firstWhere(
        (s) => s.name == data['status'],
        orElse: () => VisualSearchStatus.completed,
      ),
      errorMessage: data['errorMessage'],
    );
  }
}

class VisualMatch extends Equatable {
  final String productId;
  final String productTitle;
  final String productImageUrl;
  final double similarityScore; // 0-1
  final double price;
  final double rating;
  final String category;
  final Map<String, dynamic> attributes; // Color, pattern, style, etc.

  const VisualMatch({
    required this.productId,
    required this.productTitle,
    required this.productImageUrl,
    required this.similarityScore,
    required this.price,
    required this.rating,
    required this.category,
    this.attributes = const {},
  });

  @override
  List<Object?> get props => [
        productId,
        productTitle,
        productImageUrl,
        similarityScore,
        price,
        rating,
        category,
        attributes,
      ];

  Map<String, dynamic> toFirestore() {
    return {
      'productId': productId,
      'productTitle': productTitle,
      'productImageUrl': productImageUrl,
      'similarityScore': similarityScore,
      'price': price,
      'rating': rating,
      'category': category,
      'attributes': attributes,
    };
  }

  static VisualMatch fromFirestore(Map<String, dynamic> data) {
    return VisualMatch(
      productId: data['productId'] ?? '',
      productTitle: data['productTitle'] ?? '',
      productImageUrl: data['productImageUrl'] ?? '',
      similarityScore: (data['similarityScore'] as num?)?.toDouble() ?? 0.0,
      price: (data['price'] as num?)?.toDouble() ?? 0.0,
      rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
      category: data['category'] ?? '',
      attributes: Map<String, dynamic>.from(data['attributes'] ?? {}),
    );
  }
}

enum VisualSearchStatus { uploading, processing, completed, failed }

/// User's visual search history
class VisualSearchHistory extends Equatable {
  final String userId;
  final List<VisualSearchResult> searches;
  final int maxHistorySize;

  const VisualSearchHistory({
    required this.userId,
    this.searches = const [],
    this.maxHistorySize = 50,
  });

  @override
  List<Object?> get props => [userId, searches, maxHistorySize];

  VisualSearchHistory addSearch(VisualSearchResult result) {
    final newSearches = [result, ...searches].take(maxHistorySize).toList();
    return copyWith(searches: newSearches);
  }

  VisualSearchHistory copyWith({
    String? userId,
    List<VisualSearchResult>? searches,
    int? maxHistorySize,
  }) {
    return VisualSearchHistory(
      userId: userId ?? this.userId,
      searches: searches ?? this.searches,
      maxHistorySize: maxHistorySize ?? this.maxHistorySize,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'searches': searches.map((s) => s.toFirestore()).toList(),
      'maxHistorySize': maxHistorySize,
    };
  }

  static VisualSearchHistory fromFirestore(Map<String, dynamic> data, String id) {
    return VisualSearchHistory(
      userId: data['userId'] ?? '',
      searches: (data['searches'] as List?)
              ?.map((s) => VisualSearchResult.fromFirestore(s, s['id'] ?? ''))
              .toList() ??
          [],
      maxHistorySize: data['maxHistorySize'] ?? 50,
    );
  }
}

/// Image attributes extracted by visual search
class ImageAttributes {
  final String dominantColor;
  final List<String> colors;
  final String? pattern;
  final String? style;
  final String category;
  final List<String> tags;
  final Map<String, double> confidence;

  ImageAttributes({
    required this.dominantColor,
    required this.colors,
    this.pattern,
    this.style,
    required this.category,
    this.tags = const [],
    this.confidence = const {},
  });

  Map<String, dynamic> toFirestore() {
    return {
      'dominantColor': dominantColor,
      'colors': colors,
      'pattern': pattern,
      'style': style,
      'category': category,
      'tags': tags,
      'confidence': confidence,
    };
  }

  static ImageAttributes fromFirestore(Map<String, dynamic> data) {
    return ImageAttributes(
      dominantColor: data['dominantColor'] ?? '',
      colors: List<String>.from(data['colors'] ?? []),
      pattern: data['pattern'],
      style: data['style'],
      category: data['category'] ?? '',
      tags: List<String>.from(data['tags'] ?? []),
      confidence: Map<String, double>.from(data['confidence'] ?? {}),
    );
  }
}

/// User's visual search preference
class VisualSearchPreference {
  final String userId;
  final List<String> preferredCategories;
  final List<String> preferredColors;
  final List<String> preferredStyles;
  final List<String> preferredPatterns;
  final Map<String, double> categoryWeights;
  final DateTime updatedAt;

  VisualSearchPreference({
    required this.userId,
    this.preferredCategories = const [],
    this.preferredColors = const [],
    this.preferredStyles = const [],
    this.preferredPatterns = const [],
    this.categoryWeights = const {},
    required this.updatedAt,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'preferredCategories': preferredCategories,
      'preferredColors': preferredColors,
      'preferredStyles': preferredStyles,
      'preferredPatterns': preferredPatterns,
      'categoryWeights': categoryWeights,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  static VisualSearchPreference fromFirestore(Map<String, dynamic> data) {
    return VisualSearchPreference(
      userId: data['userId'] ?? '',
      preferredCategories: List<String>.from(data['preferredCategories'] ?? []),
      preferredColors: List<String>.from(data['preferredColors'] ?? []),
      preferredStyles: List<String>.from(data['preferredStyles'] ?? []),
      preferredPatterns: List<String>.from(data['preferredPatterns'] ?? []),
      categoryWeights: Map<String, double>.from(data['categoryWeights'] ?? {}),
      updatedAt: DateTime.parse(data['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }
}