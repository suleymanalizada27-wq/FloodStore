import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:floodstore/features/tender/application/providers/tender_providers.dart';
import 'package:floodstore/features/tender/domain/entities/tender.dart';
import 'package:floodstore/features/tender/domain/entities/tender_bid.dart';

class TenderDetailScreen extends ConsumerStatefulWidget {
  const TenderDetailScreen({
    super.key,
    required this.tenderId,
  });

  final String tenderId;

  @override
  ConsumerState<TenderDetailScreen> createState() => _TenderDetailScreenState();
}

class _TenderDetailScreenState extends ConsumerState<TenderDetailScreen> {
  late final String tenderId;
  bool _isSubmitting = false;
  bool _isClosing = false;
  final _bidFormKey = GlobalKey<FormState>();
  double _bidPrice = 0;
  int? _deliveryDays;

  @override
  void initState() {
    super.initState();
    tenderId = widget.tenderId;
  }

  @override
  Widget build(BuildContext context) {
    final tenderAsync = ref.watch(tenderDetailProvider(tenderId));
    final bidsAsync = ref.watch(tenderBidsProvider(tenderId));

    return Scaffold(
      appBar: AppBar(
        title: Text('Tender Details'),
        actions: [
          // Only show close button if tender is open and we are the owner?
          // For simplicity, we'll show it if tender is open (in a real app, check ownership)
          if (tenderAsync.when(
                data: (tender) => tender.status == TenderStatus.open,
                loading: () => false,
                error: (_, __) => false,
              ))
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: _isClosing ? null : _closeTender,
              tooltip: 'Close Tender',
            ),
        ],
      ),
      body: tenderAsync.when(
        data: (tender) => _buildContent(tender, bidsAsync),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Text('Error: $error'),
        ),
      ),
    );
  }

  Widget _buildContent(Tender tender, AsyncValue<List<TenderBid>> bidsAsync) {
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              _buildTenderInfo(tender),
              const Divider(),
              const Text(
                'Bids',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              bidsAsync.when(
                data: (bids) => _buildBidsList(bids),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stackTrace) => Center(
                  child: Text('Error: $error'),
                ),
              ),
            ],
          ),
        ),
        if (tender.status == TenderStatus.open)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: _buildBidForm(),
          ),
      ],
    );
  }

  Widget _buildTenderInfo(Tender tender) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tender ID: ${tender.id}',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text('RFQ ID: ${tender.rfqId ?? 'N/A'}'),
        const SizedBox(height: 4),
        Text('Mode: ${_formatMode(tender.mode)}'),
        const SizedBox(height: 4),
        Text('Current Round: ${tender.currentRound}'),
        const SizedBox(height: 4),
        Text('Status: ${_formatStatus(tender.status)}'),
        const SizedBox(height: 4),
        Text('Created: ${tender.createdAt.toLocal()}'),
      ],
    );
  }

  String _formatMode(TenderMode mode) {
    switch (mode) {
      case TenderMode.open:
        return 'Open';
      case TenderMode.sealed:
        return 'Sealed';
      case TenderMode.reverseAuction:
        return 'Reverse Auction';
      case TenderMode.multiRound:
        return 'Multi-round';
      default:
        return 'Unknown';
    }
  }

  String _formatStatus(TenderStatus status) {
    switch (status) {
      case TenderStatus.open:
        return 'Open';
      case TenderStatus.evaluating:
        return 'Evaluating';
      case TenderStatus.awarded:
        return 'Awarded';
      case TenderStatus.cancelled:
        return 'Cancelled';
      default:
        return 'Unknown';
    }
  }

  Widget _buildBidsList(List<TenderBid> bids) {
    if (bids.isEmpty) {
      return const Center(
        child: Text('No bids yet'),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: bids.length,
      itemBuilder: (context, index) {
        final bid = bids[index];
        return ListTile(
          title: Text('Bid by Seller: ${bid.sellerId}'),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Price: \$${bid.price.toStringAsFixed(2)}'),
              if (bid.deliveryDays != null)
                Text('Delivery Days: ${bid.deliveryDays}'),
              Text('Submitted: ${bid.submittedAt.toLocal()}'),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBidForm() {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _bidFormKey,
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Bid Price (\$)',
                  prefixText: '\$ ',
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a bid price';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
                onSaved: (value) {
                  _bidPrice = double.parse(value!);
                },
              ),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Delivery Days (optional)',
                  hintText: 'Enter number of days for delivery',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return null; // Optional field
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
                onSaved: (value) {
                  _deliveryDays = (value != null && value.isNotEmpty) ? int.parse(value) : null;
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submitBid,
                child: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : const Text('Submit Bid'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submitBid() async {
    if (_bidFormKey.currentState!.validate()) {
      _bidFormKey.currentState!.save();
      setState(() {
        _isSubmitting = true;
      });

      final bid = TenderBid(
        id: '', // Will be generated by repository
        tenderId: tenderId,
        sellerId: 'current_seller_id', // In a real app, get from auth
        round: 1, // For open mode, we assume round 1; in a real app, get from tender.currentRound
        price: _bidPrice,
        deliveryDays: _deliveryDays,
        submittedAt: DateTime.now(),
      );

      try {
        await ref.read(submitBidProvider(bid).future);
        // Successfully submitted
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Bid submitted successfully')),
          );
          // Reset form
          _bidFormKey.currentState!.reset();
          setState(() {
            _isSubmitting = false;
            _bidPrice = 0;
            _deliveryDays = null;
          });
          // Refresh bids
          ref.refresh(tenderBidsProvider(tenderId));
        }
      } catch (error) {
        if (mounted) {
          setState(() {
            _isSubmitting = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error submitting bid: $error')),
          );
        }
      }
    }
  }

  void _closeTender() async {
    setState(() {
      _isClosing = true;
    });

    try {
      await ref.read(closeTenderProvider(tenderId).future);
      // Successfully closed
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tender closed successfully')),
        );
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _isClosing = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error closing tender: $error')),
        );
      }
    }
  }
}