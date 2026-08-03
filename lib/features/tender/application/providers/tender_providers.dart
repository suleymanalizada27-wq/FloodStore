import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:floodstore/features/tender/domain/entities/tender.dart';
import 'package:floodstore/features/tender/domain/entities/tender_bid.dart';
import 'package:floodstore/features/tender/domain/entities/tender_participant.dart';
import 'package:floodstore/features/tender/domain/repositories/tender_repository.dart';
import 'package:floodstore/features/tender/data/repositories/mock_tender_repository.dart';

/// Provider for tender repository
final tenderRepositoryProvider = Provider<TenderRepository>((ref) {
  // In a real app, we would use the actual repository based on environment
  // For now, we use the mock repository
  return MockTenderRepository();
});

/// Provider for list of tenders
final tendersProvider = FutureProvider<List<Tender>>((ref) async {
  final repository = ref.read(tenderRepositoryProvider);
  return await repository.getTenders();
});

/// Provider for a specific tender detail
final tenderDetailProvider = FutureProvider.family<Tender, String>((ref, tenderId) {
  final repository = ref.read(tenderRepositoryProvider);
  return repository.getTenderDetail(tenderId);
});

/// Provider for bids of a tender
final tenderBidsProvider = FutureProvider.family<List<TenderBid>, String>((ref, tenderId) {
  final repository = ref.read(tenderRepositoryProvider);
  return repository.getBidsForTender(tenderId);
});

/// Provider for creating a tender
final createTenderProvider = FutureProvider.family<Tender, Tender>((ref, tender) {
  final repository = ref.read(tenderRepositoryProvider);
  return repository.createTender(tender);
});

/// Provider for inviting a participant
final inviteParticipantProvider = FutureProvider.family<TenderParticipant, TenderParticipant>((ref, participant) {
  final repository = ref.read(tenderRepositoryProvider);
  return repository.inviteParticipant(participant);
});

/// Provider for submitting a bid
final submitBidProvider = FutureProvider.family<TenderBid, TenderBid>((ref, bid) {
  final repository = ref.read(tenderRepositoryProvider);
  return repository.submitBid(bid);
});

/// Provider for closing a tender
final closeTenderProvider = FutureProvider.family<void, String>((ref, tenderId) {
  final repository = ref.read(tenderRepositoryProvider);
  return repository.closeTender(tenderId);
});