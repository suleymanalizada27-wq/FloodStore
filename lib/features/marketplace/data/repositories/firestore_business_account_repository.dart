import 'package:cloud_firestore/cloud_firestore.dart' as fs;
import '../../domain/entities/business_account.dart';
import '../../domain/repositories/business_account_repository.dart';

class FirestoreBusinessAccountRepository implements BusinessAccountRepository {
  final fs.FirebaseFirestore _firestore;

  FirestoreBusinessAccountRepository({fs.FirebaseFirestore? firestore})
      : _firestore = firestore ?? fs.FirebaseFirestore.instance;

  fs.CollectionReference get _accountsRef => _firestore.collection('business_accounts');

  @override
  Future<String> createBusinessAccount(BusinessAccount account) async {
    try {
      final docRef = await _accountsRef.add(account.toFirestore());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create business account: $e');
    }
  }

  @override
  Future<BusinessAccount?> getBusinessAccount(String id) async {
    try {
      final doc = await _accountsRef.doc(id).get();
      if (!doc.exists) return null;
      return BusinessAccount.fromFirestore(doc.data()! as Map<String, dynamic>, doc.id);
    } catch (e) {
      throw Exception('Failed to get business account: $e');
    }
  }

  @override
  Future<BusinessAccount?> getBusinessAccountByUserId(String userId) async {
    try {
      final query = await _accountsRef
          .where('userId', isEqualTo: userId)
          .limit(1)
          .get();
      if (query.docs.isEmpty) return null;
      final doc = query.docs.first;
      return BusinessAccount.fromFirestore(doc.data()! as Map<String, dynamic>, doc.id);
    } catch (e) {
      throw Exception('Failed to get business account by user ID: $e');
    }
  }

  @override
  Future<void> updateBusinessAccount(BusinessAccount account) async {
    try {
      await _accountsRef.doc(account.id).update(account.toFirestore());
    } catch (e) {
      throw Exception('Failed to update business account: $e');
    }
  }

  @override
  Future<void> updateBusinessAccountStatus(
    String id,
    BusinessAccountStatus status, {
    String? rejectionReason,
    String? approvedBy,
  }) async {
    try {
      final updates = <String, dynamic>{
        'status': status.name,
        'updatedAt': fs.FieldValue.serverTimestamp(),
      };
      if (rejectionReason != null) {
        updates['rejectionReason'] = rejectionReason;
      }
      if (status == BusinessAccountStatus.approved) {
        updates['approvedAt'] = fs.FieldValue.serverTimestamp();
        updates['approvedBy'] = approvedBy;
      }
      await _accountsRef.doc(id).update(updates);
    } catch (e) {
      throw Exception('Failed to update business account status: $e');
    }
  }

  @override
  Future<List<BusinessAccount>> getAllBusinessAccounts({
    int limit = 20,
    String? lastDocumentId,
    BusinessAccountStatus? statusFilter,
  }) async {
    try {
      fs.Query query = _accountsRef.orderBy('createdAt', descending: true);

      if (statusFilter != null) {
        query = query.where('status', isEqualTo: statusFilter.name);
      }

      if (lastDocumentId != null) {
        final lastDoc = await _accountsRef.doc(lastDocumentId).get();
        if (lastDoc.exists) {
          query = query.startAfterDocument(lastDoc);
        }
      }

      query = query.limit(limit);

      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => BusinessAccount.fromFirestore(doc.data()! as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      throw Exception('Failed to get business accounts: $e');
    }
  }

  @override
  Future<int> getPendingBusinessAccountsCount() async {
    try {
      final snapshot = await _accountsRef
          .where('status', isEqualTo: BusinessAccountStatus.pending.name)
          .count()
          .get();
      return snapshot.count ?? 0;
    } catch (e) {
      throw Exception('Failed to get pending business accounts count: $e');
    }
  }

  @override
  Future<String> uploadBusinessDocument({
    required String businessAccountId,
    required String documentType,
    required String filePath,
  }) async {
    // This would typically use Firebase Storage
    // For now, return a placeholder URL
    return 'https://firebasestorage.googleapis.com/v0/b/floodstore-fbece.appspot.com/o/business_accounts%2F$businessAccountId%2F$documentType?alt=media';
  }

  @override
  Future<void> deleteBusinessDocument({
    required String businessAccountId,
    required String documentType,
  }) async {
    // Implementation would delete from Firebase Storage
  }
}