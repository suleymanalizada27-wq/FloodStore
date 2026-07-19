import 'package:equatable/equatable.dart';

/// Represents a business/seller account in FloodStore
class BusinessAccount extends Equatable {
  final String id;
  final String userId; // Firebase UID of the owner
  final String businessName;
  final String businessType; // individual, company, partnership
  final String taxId; // Vergi numarası / Tax ID
  final String businessEmail;
  final String businessPhone;
  final BusinessAddress address;
  final String? website;
  final String? description;
  final String? logoUrl;
  final String? taxCertificateUrl; // Vergi levazı / Tax certificate
  final String? tradeRegistryUrl; // Ticaret sicil gazetesi / Trade registry gazette
  final String? authorizedPersonName; // Yetkili kişi adı
  final String? authorizedPersonTc; // Yetkili kişi TC/Passport
  final String? authorizedPersonPhone; // Yetkili kişi telefonu
  final String? authorizedPersonEmail; // Yetkili kişi email
  final BusinessAccountStatus status; // pending, approved, rejected, suspended
  final String? rejectionReason;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? approvedAt;
  final String? approvedBy; // Admin UID

  const BusinessAccount({
    required this.id,
    required this.userId,
    required this.businessName,
    required this.businessType,
    required this.taxId,
    required this.businessEmail,
    required this.businessPhone,
    required this.address,
    this.website,
    this.description,
    this.logoUrl,
    this.taxCertificateUrl,
    this.tradeRegistryUrl,
    this.authorizedPersonName,
    this.authorizedPersonTc,
    this.authorizedPersonPhone,
    this.authorizedPersonEmail,
    this.status = BusinessAccountStatus.pending,
    this.rejectionReason,
    required this.createdAt,
    required this.updatedAt,
    this.approvedAt,
    this.approvedBy,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        businessName,
        businessType,
        taxId,
        businessEmail,
        businessPhone,
        address,
        website,
        description,
        logoUrl,
        taxCertificateUrl,
        tradeRegistryUrl,
        authorizedPersonName,
        authorizedPersonTc,
        authorizedPersonPhone,
        authorizedPersonEmail,
        status,
        rejectionReason,
        createdAt,
        updatedAt,
        approvedAt,
        approvedBy,
      ];

  BusinessAccount copyWith({
    String? id,
    String? userId,
    String? businessName,
    String? businessType,
    String? taxId,
    String? businessEmail,
    String? businessPhone,
    BusinessAddress? address,
    String? website,
    String? description,
    String? logoUrl,
    String? taxCertificateUrl,
    String? tradeRegistryUrl,
    String? authorizedPersonName,
    String? authorizedPersonTc,
    String? authorizedPersonPhone,
    String? authorizedPersonEmail,
    BusinessAccountStatus? status,
    String? rejectionReason,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? approvedAt,
    String? approvedBy,
  }) {
    return BusinessAccount(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      businessName: businessName ?? this.businessName,
      businessType: businessType ?? this.businessType,
      taxId: taxId ?? this.taxId,
      businessEmail: businessEmail ?? this.businessEmail,
      businessPhone: businessPhone ?? this.businessPhone,
      address: address ?? this.address,
      website: website ?? this.website,
      description: description ?? this.description,
      logoUrl: logoUrl ?? this.logoUrl,
      taxCertificateUrl: taxCertificateUrl ?? this.taxCertificateUrl,
      tradeRegistryUrl: tradeRegistryUrl ?? this.tradeRegistryUrl,
      authorizedPersonName: authorizedPersonName ?? this.authorizedPersonName,
      authorizedPersonTc: authorizedPersonTc ?? this.authorizedPersonTc,
      authorizedPersonPhone: authorizedPersonPhone ?? this.authorizedPersonPhone,
      authorizedPersonEmail: authorizedPersonEmail ?? this.authorizedPersonEmail,
      status: status ?? this.status,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      approvedAt: approvedAt ?? this.approvedAt,
      approvedBy: approvedBy ?? this.approvedBy,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'businessName': businessName,
      'businessType': businessType,
      'taxId': taxId,
      'businessEmail': businessEmail,
      'businessPhone': businessPhone,
      'address': address.toFirestore(),
      'website': website,
      'description': description,
      'logoUrl': logoUrl,
      'taxCertificateUrl': taxCertificateUrl,
      'tradeRegistryUrl': tradeRegistryUrl,
      'authorizedPersonName': authorizedPersonName,
      'authorizedPersonTc': authorizedPersonTc,
      'authorizedPersonPhone': authorizedPersonPhone,
      'authorizedPersonEmail': authorizedPersonEmail,
      'status': status.name,
      'rejectionReason': rejectionReason,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'approvedAt': approvedAt?.toIso8601String(),
      'approvedBy': approvedBy,
    };
  }

  static BusinessAccount fromFirestore(Map<String, dynamic> data, String documentId) {
    return BusinessAccount(
      id: documentId,
      userId: data['userId'] ?? '',
      businessName: data['businessName'] ?? '',
      businessType: data['businessType'] ?? '',
      taxId: data['taxId'] ?? '',
      businessEmail: data['businessEmail'] ?? '',
      businessPhone: data['businessPhone'] ?? '',
      address: BusinessAddress.fromFirestore(data['address'] ?? {}),
      website: data['website'],
      description: data['description'],
      logoUrl: data['logoUrl'],
      taxCertificateUrl: data['taxCertificateUrl'],
      tradeRegistryUrl: data['tradeRegistryUrl'],
      authorizedPersonName: data['authorizedPersonName'],
      authorizedPersonTc: data['authorizedPersonTc'],
      authorizedPersonPhone: data['authorizedPersonPhone'],
      authorizedPersonEmail: data['authorizedPersonEmail'],
      status: BusinessAccountStatus.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => BusinessAccountStatus.pending,
      ),
      rejectionReason: data['rejectionReason'],
      createdAt: DateTime.parse(data['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(data['updatedAt'] ?? DateTime.now().toIso8601String()),
      approvedAt: data['approvedAt'] != null ? DateTime.parse(data['approvedAt']) : null,
      approvedBy: data['approvedBy'],
    );
  }
}

enum BusinessAccountStatus {
  pending, // Başvuru yapıldı, onay bekliyor
  approved, // Onaylandı, satış yapabilir
  rejected, // Reddedildi
  suspended, // Askıya alındı (yönetici tarafından)
}

class BusinessAddress extends Equatable {
  final String country; // Ülke
  final String city; // İl
  final String district; // İlçe
  final String neighborhood; // Mahalle
  final String street; // Cadde/Sokak
  final String buildingNumber; // Bina numarası
  final String? apartmentNumber; // Daire numarası
  final String postalCode; // Posta kodu
  final String fullAddress; // Tam adres (tek satır)

  const BusinessAddress({
    required this.country,
    required this.city,
    required this.district,
    required this.neighborhood,
    required this.street,
    required this.buildingNumber,
    this.apartmentNumber,
    required this.postalCode,
    required this.fullAddress,
  });

  @override
  List<Object?> get props => [
        country,
        city,
        district,
        neighborhood,
        street,
        buildingNumber,
        apartmentNumber,
        postalCode,
        fullAddress,
      ];

  BusinessAddress copyWith({
    String? country,
    String? city,
    String? district,
    String? neighborhood,
    String? street,
    String? buildingNumber,
    String? apartmentNumber,
    String? postalCode,
    String? fullAddress,
  }) {
    return BusinessAddress(
      country: country ?? this.country,
      city: city ?? this.city,
      district: district ?? this.district,
      neighborhood: neighborhood ?? this.neighborhood,
      street: street ?? this.street,
      buildingNumber: buildingNumber ?? this.buildingNumber,
      apartmentNumber: apartmentNumber ?? this.apartmentNumber,
      postalCode: postalCode ?? this.postalCode,
      fullAddress: fullAddress ?? this.fullAddress,
    );
  }

  static BusinessAddress empty() => const BusinessAddress(
        country: '',
        city: '',
        district: '',
        neighborhood: '',
        street: '',
        buildingNumber: '',
        apartmentNumber: '',
        postalCode: '',
        fullAddress: '',
      );

  Map<String, dynamic> toFirestore() {
    return {
      'country': country,
      'city': city,
      'district': district,
      'neighborhood': neighborhood,
      'street': street,
      'buildingNumber': buildingNumber,
      'apartmentNumber': apartmentNumber,
      'postalCode': postalCode,
      'fullAddress': fullAddress,
    };
  }

  static BusinessAddress fromFirestore(Map<String, dynamic> data) {
    return BusinessAddress(
      country: data['country'] ?? '',
      city: data['city'] ?? '',
      district: data['district'] ?? '',
      neighborhood: data['neighborhood'] ?? '',
      street: data['street'] ?? '',
      buildingNumber: data['buildingNumber'] ?? '',
      apartmentNumber: data['apartmentNumber'],
      postalCode: data['postalCode'] ?? '',
      fullAddress: data['fullAddress'] ?? '',
    );
  }
}

enum BusinessType {
  individual, // Şahıs firması
  limitedCompany, // Limited Şirketi
  jointStockCompany, // Anonim Şirketi
  partnership, // Kolektif Şirket
  limitedPartnership, // Komandit Şirket
  cooperative, // Kooperatif
  other, // Diğer
}

extension BusinessTypeExtension on BusinessType {
  String get displayName {
    switch (this) {
      case BusinessType.individual:
        return 'Şahıs Firması';
      case BusinessType.limitedCompany:
        return 'Limited Şirketi';
      case BusinessType.jointStockCompany:
        return 'Anonim Şirketi';
      case BusinessType.partnership:
        return 'Kolektif Şirket';
      case BusinessType.limitedPartnership:
        return 'Komandit Şirket';
      case BusinessType.cooperative:
        return 'Kooperatif';
      case BusinessType.other:
        return 'Diğer';
    }
  }

  String get value {
    switch (this) {
      case BusinessType.individual:
        return 'individual';
      case BusinessType.limitedCompany:
        return 'limited_company';
      case BusinessType.jointStockCompany:
        return 'joint_stock_company';
      case BusinessType.partnership:
        return 'partnership';
      case BusinessType.limitedPartnership:
        return 'limited_partnership';
      case BusinessType.cooperative:
        return 'cooperative';
      case BusinessType.other:
        return 'other';
    }
  }

  static BusinessType fromValue(String value) {
    switch (value) {
      case 'individual':
        return BusinessType.individual;
      case 'limited_company':
        return BusinessType.limitedCompany;
      case 'joint_stock_company':
        return BusinessType.jointStockCompany;
      case 'partnership':
        return BusinessType.partnership;
      case 'limited_partnership':
        return BusinessType.limitedPartnership;
      case 'cooperative':
        return BusinessType.cooperative;
      default:
        return BusinessType.other;
    }
  }
}