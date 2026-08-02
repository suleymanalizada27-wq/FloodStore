import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:floodstore/features/procurement/application/providers/procurement_providers.dart';
import 'package:floodstore/features/procurement/domain/entities/rfq.dart';

class RFQDetailScreen extends ConsumerStatefulWidget {
  final String rfqId;

  const RFQDetailScreen({Key? key, required this.rfqId}) : super(key: key);

  @override
  ConsumerState<RFQDetailScreen> createState() => _RFQDetailScreenState();
}

class _RFQDetailScreenState extends ConsumerState<RFQDetailScreen> {
  late final String _rfqId;

  @override
  void initState() {
    super.initState();
    _rfqId = widget.rfqId;
  }

  @override
  Widget build(BuildContext context) {
    final rfqAsync = ref.watch(rfqProvider(_rfqId));
    final itemsAsync = ref.watch(rfqItemsProvider(_rfqId));
    final responsesAsync = ref.watch(rfqResponsesProvider(_rfqId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('RFQ Details'),
      ),
      body: rfqAsync.when(
        data: (rfq) {
          if (rfq == null) {
            return const Center(child: Text('RFQ not found'));
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  rfq.title,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text.rich(
                  TextSpan(
                    text: 'Status: ',
                    style: TextStyle(fontWeight: FontWeight.bold),
                    children: [
                      TextSpan(
                        text: rfq.status,
                        style: TextStyle(
                          color: _getStatusColor(rfq.status),
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 32),
                const Text(
                  'Details',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                InfoRow(label: 'Description', value: rfq.description ?? 'No description'),
                InfoRow(
                    label: 'Budget',
                    value: '\$${rfq.totalBudget.toStringAsFixed(2)} ${rfq.currency}'),
                InfoRow(
                    label: 'Issue Date',
                    value: _formatDate(rfq.issueDate)),
                InfoRow(
                    label: 'Response Deadline',
                    value: _formatDate(rfq.responseDeadline)),
                const Divider(height: 24),
                const Text(
                  'Items',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                itemsAsync.when(
                  data: (items) {
                    if (items.isEmpty) {
                      return const Text('No items added yet.');
                    }
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final item = items[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          child: ListTile(
                            title: Text(item.description),
                            subtitle: Text('${item.quantity} ${item.unitOfMeasure}'),
                          ),
                        );
                      },
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Text('Error loading items: $e'),
                ),
                const Divider(height: 24),
                const Text(
                  'Responses',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                responsesAsync.when(
                  data: (responses) {
                    if (responses.isEmpty) {
                      return const Center(
                        child: Text('No responses received yet.'),
                      );
                    }
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: responses.length,
                      itemBuilder: (context, index) {
                        final response = responses[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          child: ListTile(
                            leading: CircleAvatar(
                              child: Text(response.id.substring(0, 2).toUpperCase()),
                            ),
                            title: Text('Supplier: ${response.supplierId}'),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Response Date: ${_formatDate(response.responseDate)}'),
                                Text('Status: ${response.status}'),
                                if (response.notes != null && response.notes!.isNotEmpty)
                                  Text('Notes: ${response.notes}'),
                              ],
                            ),
                            trailing: Chip(
                              label: Text(response.status),
                              backgroundColor: _getStatusColor(response.status),
                            ),
                            onTap: () {
                              // TODO: navigate to response detail screen
                            },
                          ),
                        );
                      },
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Text('Error loading responses: $e'),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Not set';
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'draft':
        return Colors.grey;
      case 'open':
        return Colors.blue;
      case 'closed':
        return Colors.orange;
      case 'awarded':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      case 'accepted':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.blueGrey;
    }
  }
}

class InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const InfoRow({Key? key, required this.label, required this.value}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}