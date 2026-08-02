import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:floodstore/features/procurement/application/providers/procurement_providers.dart';
import 'package:floodstore/features/procurement/domain/entities/rfq.dart';
import 'package:floodstore/features/procurement/presentation/screens/create_rfq_screen.dart';
import 'package:floodstore/features/procurement/presentation/screens/rfq_detail_screen.dart';

class RFQListScreen extends ConsumerStatefulWidget {
  const RFQListScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<RFQListScreen> createState() => _RFQListScreenState();
}

class _RFQListScreenState extends ConsumerState<RFQListScreen> {
  // For demo, we use a fixed buyer ID; in real app, this would come from auth
  static const String _demoBuyerId = 'buyer_001';

  @override
  Widget build(BuildContext context) {
    final rfqAsync = ref.watch(rfqListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My RFQs'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const CreateRFQScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: rfqAsync.when(
        data: (rfqs) {
          if (rfqs.isEmpty) {
            return const Center(
              child: Text('No RFQs found. Create one to get started!'),
            );
          }
          return ListView.builder(
            itemCount: rfqs.length,
            itemBuilder: (context, index) {
              final rfq = rfqs[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    child: Text(rfq.id.substring(0, 2).toUpperCase()),
                  ),
                  title: Text(rfq.title),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Budget: \$${rfq.totalBudget.toStringAsFixed(2)} ${rfq.currency}'),
                      Text('Status: ${rfq.status}'),
                    ],
                  ),
                  trailing: Chip(
                    label: Text(rfq.status),
                    backgroundColor: _getStatusColor(rfq.status),
                  ),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => RFQDetailScreen(rfqId: rfq.id),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
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
      default:
        return Colors.blueGrey;
    }
  }
}