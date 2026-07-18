import 'package:equatable/equatable.dart';

/// Represents a product review
class Review extends Equatable {
  final String id;
  final String productId;
  final String userId;
  final double rating; // 1-5 stars
  final String? title;
  final String? comment;
  final List<String> images; // URLs or paths to images
  final bool isVerifiedPurchase;
  final int helpfulVotes;
  final int totalVotes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isApproved; // for moderation
  final bool isFlagged; // for inappropriate content

  const Review({
    required this.id,
    required this.productId,
    required this.userId,
    required this.rating,
    this.title,
    this.comment,
    required this.images,
    required this.isVerifiedPurchase,
    required this.helpfulVotes,
    required this.totalVotes,
    required this.createdAt,
    required this.updatedAt,
    required this.isApproved,
    required this.isFlagged,
  });

  @override
  List<Object?> get props => [
        id,
        productId,
        userId,
        rating,
        title,
        comment,
        images,
        isVerifiedPurchase,
        helpfulVotes,
        totalVotes,
        createdAt,
        updatedAt,
        isApproved,
        isFlagged,
      ];

  Review copyWith({
    String? id,
    String? productId,
    String? userId,
    double? rating,
    String? title,
    String? comment,
    List<String>? images,
    bool? isVerifiedPurchase,
    int? helpfulVotes,
    int? totalVotes,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isApproved,
    bool? isFlagged,
  }) {
    return Review(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      userId: userId ?? this.userId,
      rating: rating ?? this.rating,
      title: title ?? this.title,
      comment: comment ?? this.comment,
      images: images ?? this.images,
      isVerifiedPurchase: isVerifiedPurchase ?? this.isVerifiedPurchase,
      helpfulVotes: helpfulVotes ?? this.helpfulVotes,
      totalVotes: totalVotes ?? this.totalVotes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isApproved: isApproved ?? this.isApproved,
      isFlagged: isFlagged ?? this.isFlagged,
    );
  }

  /// Gets the percentage of helpful votes
  double get helpfulPercentage =>
      totalVotes > 0 ? (helpfulVotes / totalVotes) * 100 : 0.0;

  /// Checks if the review is visible (approved and not flagged)
  bool get isVisible => isApproved && !isFlagged;
}