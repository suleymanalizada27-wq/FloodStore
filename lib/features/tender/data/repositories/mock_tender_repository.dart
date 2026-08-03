import 'package:flutter/foundation.dart';
import 'package:floodstore/features/tender/domain/entities/tender.dart';
import 'package:floodstore/features/tender/domain/entities/tender_bid.dart';
import 'package:floodstore/features/tender/domain/entities/tender_participant.dart';
import 'package:floodstore/features/tender/domain/repositories/tender_repository.dart';

/// Mock implementation of TenderRepository using in-memory lists
/// TODO: replace with SupabaseTenderRepository once Supabase project is provisioned
/// (see docs/decisions/ADR-004-PAYMENTS.md, docs/database/12_MIGRATIONS.md)
class MockTenderRepository implements TenderRepository {
  // In-memory storage
  final Map<String, Tender> _tenders = {};
  final Map<String, List<TenderParticipant>> _tenderParticipants = {};
  final Map<String, List<TenderBid>> _tenderBids = {};

  // ID generators
  String _generateId() => DateTime.now().millisecondsSinceEpoch.toString();

  @override
  Future<List<Tender>> getTenders() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    return _tenders.values.toList();
  }

  @override
  Future<Tender> createTender(Tender tender) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final id = _generateId();
    final newTender = tender.copyWith(id: id);
    _tenders[id] = newTender;
    _tenderParticipants[id] = [];
    _tenderBids[id] = [];

    return newTender;
  }

  @override
  Future<Tender> getTenderDetail(String tenderId) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final tender = _tenders[tenderId];
    if (tender == null) {
      throw Exception('Tender not found');
    }
    return tender;
  }

  @override
  Future<TenderParticipant> inviteParticipant(TenderParticipant participant) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final id = _generateId();
    final newParticipant = participant.copyWith(id: id);
    (_tenderParticipants[participant.tenderId] ??= []).add(newParticipant);

    return newParticipant;
  }

  @override
  Future<TenderBid> submitBid(TenderBid bid) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final id = _generateId();
    final newBid = bid.copyWith(id: id);
    (_tenderBids[bid.tenderId] ??= []).add(newBid);

    return newBid;
  }

  @override
  Future<List<TenderBid>> getBidsForTender(String tenderId) async {
    await Future.delayed(const Duration(milliseconds: 300));

    return _tenderBids[tenderId] ?? [];
  }

  @override
  Future<void> closeTender(String tenderId) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final tender = _tenders[tenderId];
    if (tender == null) {
      throw Exception('Tender not found');
    }

    final updatedTender = tender.copyWith(status: TenderStatus.cancelled);
    _tenders[tenderId] = updatedTender;
  }
}
