import 'package:equatable/equatable.dart';

/// Represents a user in the marketplace context
/// This extends the core Auth User with marketplace-specific properties
class MarketplaceUser extends Equatable {
  final String id; // Firebase UID
  final String email;
  final String displayName;
  final String? photoUrl;
  final bool emailVerified;
  final String? phoneNumber;
  final UserRole role;
  final DateTime createdAt;
  final DateTime lastSignInAt;
  final bool isAnonymous;
  final bool isEmailLinked;
  final bool isAnonymousLinked;

  // Marketplace-specific fields
  final UserProfile? profile;
  final UserPreferences? preferences;
  final Wallet? wallet;

  const MarketplaceUser({
    required this.id,
    required this.email,
    required this.displayName,
    this.photoUrl,
    required this.emailVerified,
    this.phoneNumber,
    required this.role,
    required this.createdAt,
    required this.lastSignInAt,
    required this.isAnonymous,
    required this.isEmailLinked,
    required this.isAnonymousLinked,
    this.profile,
    this.preferences,
    this.wallet,
  });

  @override
  List<Object?> get props => [
        id,
        email,
        displayName,
        photoUrl,
        emailVerified,
        phoneNumber,
        role,
        createdAt,
        lastSignInAt,
        isAnonymous,
        isEmailLinked,
        isAnonymousLinked,
        profile,
        preferences,
        wallet,
      ];

  MarketplaceUser copyWith({
    String? id,
    String? email,
    String? displayName,
    String? photoUrl,
    bool? emailVerified,
    String? phoneNumber,
    UserRole? role,
    DateTime? createdAt,
    DateTime? lastSignInAt,
    bool? isAnonymous,
    bool? isEmailLinked,
    bool? isAnonymousLinked,
    UserProfile? profile,
    UserPreferences? preferences,
    Wallet? wallet,
  }) {
    return MarketplaceUser(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      emailVerified: emailVerified ?? this.emailVerified,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      lastSignInAt: lastSignInAt ?? this.lastSignInAt,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      isEmailLinked: isEmailLinked ?? this.isEmailLinked,
      isAnonymousLinked: isAnonymousLinked ?? this.isAnonymousLinked,
      profile: profile ?? this.profile,
      preferences: preferences ?? this.preferences,
      wallet: wallet ?? this.wallet,
    );
  }

  /// Checks if the user is a customer
  bool get isCustomer => role == UserRole.customer;

  /// Checks if the user is a seller
  bool get isSeller => role == UserRole.seller;

  /// Checks if the user is an admin or admin/moderator
  bool get isStaff =>
      role == UserRole.admin ||
      role == UserRole.moderator ||
      role == UserRole.storeManager;

  /// Checks if the user has full admin privileges
  bool get isAdmin => role == UserRole.admin;

  /// Checks if the user has moderator privileges
  bool get isModerator =>
      role == UserRole.moderator || role == UserRole.admin;
}

enum UserRole { customer, seller, admin, moderator, storeManager }

class UserProfile extends Equatable {
  final String bio;
  final String? avatarUrl;
  final String? coverPhotoUrl;
  final String? location;
  final String? website;
  final String? twitterHandle;
  final String? instagramHandle;

  const UserProfile({
    required this.bio,
    this.avatarUrl,
    this.coverPhotoUrl,
    this.location,
    this.website,
    this.twitterHandle,
    this.instagramHandle,
  });

  @override
  List<Object?> get props => [
        bio,
        avatarUrl,
        coverPhotoUrl,
        location,
        website,
        twitterHandle,
        instagramHandle,
      ];

  UserProfile copyWith({
    String? bio,
    String? avatarUrl,
    String? coverPhotoUrl,
    String? location,
    String? website,
    String? twitterHandle,
    String? instagramHandle,
  }) {
    return UserProfile(
      bio: bio ?? this.bio,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      coverPhotoUrl: coverPhotoUrl ?? this.coverPhotoUrl,
      location: location ?? this.location,
      website: website ?? this.website,
      twitterHandle: twitterHandle ?? this.twitterHandle,
      instagramHandle: instagramHandle ?? this.instagramHandle,
    );
  }
}

class UserPreferences extends Equatable {
  final bool newsletterSubscription;
  final bool promotionalEmails;
  final bool orderUpdates;
  final bool shippingUpdates;
  final bool priceDropAlerts;
  final bool restockAlerts;
  final String? preferredLanguage;
  final String? currencyPreference;
  final bool allowLocationTracking;
  final bool showAdultContent;

  const UserPreferences({
    this.newsletterSubscription = true,
    this.promotionalEmails = true,
    this.orderUpdates = true,
    this.shippingUpdates = true,
    this.priceDropAlerts = true,
    this.restockAlerts = true,
    this.preferredLanguage,
    this.currencyPreference,
    this.allowLocationTracking = false,
    this.showAdultContent = false,
  });

  @override
  List<Object?> get props => [
        newsletterSubscription,
        promotionalEmails,
        orderUpdates,
        shippingUpdates,
        priceDropAlerts,
        restockAlerts,
        preferredLanguage,
        currencyPreference,
        allowLocationTracking,
        showAdultContent,
      ];

  UserPreferences copyWith({
    bool? newsletterSubscription,
    bool? promotionalEmails,
    bool? orderUpdates,
    bool? shippingUpdates,
    bool? priceDropAlerts,
    bool? restockAlerts,
    String? preferredLanguage,
    String? currencyPreference,
    bool? allowLocationTracking,
    bool? showAdultContent,
  }) {
    return UserPreferences(
      newsletterSubscription:
          newsletterSubscription ?? this.newsletterSubscription,
      promotionalEmails: promotionalEmails ?? this.promotionalEmails,
      orderUpdates: orderUpdates ?? this.orderUpdates,
      shippingUpdates: shippingUpdates ?? this.shippingUpdates,
      priceDropAlerts: priceDropAlerts ?? this.priceDropAlerts,
      restockAlerts: restockAlerts ?? this.restockAlerts,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
      currencyPreference: currencyPreference ?? this.currencyPreference,
      allowLocationTracking:
          allowLocationTracking ?? this.allowLocationTracking,
      showAdultContent: showAdultContent ?? this.showAdultContent,
    );
  }
}

class Wallet extends Equatable {
  final double balance; // in cents
  final String currency;
  final double lifetimeEarnings; // total added to wallet (for tracking)
  final double lifetimeSpent; // total spent from wallet
  final DateTime lastUpdated;

  const Wallet({
    required this.balance,
    required this.currency,
    required this.lifetimeEarnings,
    required this.lifetimeSpent,
    required this.lastUpdated,
  });

  @override
  List<Object?> get props => [
        balance,
        currency,
        lifetimeEarnings,
        lifetimeSpent,
        lastUpdated,
      ];

  Wallet copyWith({
    double? balance,
    String? currency,
    double? lifetimeEarnings,
    double? lifetimeSpent,
    DateTime? lastUpdated,
  }) {
    return Wallet(
      balance: balance ?? this.balance,
      currency: currency ?? this.currency,
      lifetimeEarnings: lifetimeEarnings ?? this.lifetimeEarnings,
      lifetimeSpent: lifetimeSpent ?? this.lifetimeSpent,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  /// Adds funds to the wallet
  Wallet addFunds(double amount) {
    return copyWith(
      balance: balance + amount,
      lifetimeEarnings: lifetimeEarnings + amount,
      lastUpdated: DateTime.now(),
    );
  }

  /// Deducts funds from the wallet
  Wallet deductFunds(double amount) {
    final newBalance = (balance - amount).clamp(0.0, double.infinity);
    return copyWith(
      balance: newBalance,
      lifetimeSpent: lifetimeSpend + (balance - newBalance),
      lastUpdated: DateTime.now(),
    );
  }

  double get getLifetimeSpend => lifetimeSpent;
}