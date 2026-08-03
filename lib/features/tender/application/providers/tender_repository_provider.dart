import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:floodstore/features/tender/data/repositories/mock_tender_repository.dart';
import 'package:floodstore/features/tender/domain/repositories/tender_repository.dart';

/// Provider for tender repository
final tenderRepositoryProvider = Provider<TenderRepository>((ref) {
  return MockTenderRepository();
});
