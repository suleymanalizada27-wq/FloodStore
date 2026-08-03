import 'package:floodstore/features/tender/domain/entities/tender.dart';
import 'package:floodstore/features/tender/domain/entities/tender_bid.dart';
import 'package:floodstore/features/tender/domain/entities/tender_participant.dart';

abstract class TenderRepository {
  Future<List<Tender>> getTenders();

  Future<Tender> createTender(Tender tender);

  Future<Tender> getTenderDetail(String tenderId);

  Future<TenderParticipant> inviteParticipant(TenderParticipant participant);

  Future<TenderBid> submitBid(TenderBid bid);

  Future<List<TenderBid>> getBidsForTender(String tenderId);

  Future<void> closeTender(String tenderId);
}
