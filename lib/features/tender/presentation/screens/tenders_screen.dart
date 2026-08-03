import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:floodstore/features/tender/application/providers/tender_providers.dart';
import 'package:floodstore/features/tender/domain/entities/tender.dart';

class TendersScreen extends ConsumerWidget {
  const TendersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tendersAsync = ref.watch(tendersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tenders'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // Navigate to create tender screen
              Navigator.of(context).pushNamed('/tender/create');
            },
          ),
        ],
      ),
      body: tendersAsync.when(
        data: (tenders) {
          if (tenders.isEmpty) {
            return const Center(
              child: Text('No tenders available'),
            );
          }

          return ListView.builder(
            itemCount: tenders.length,
            itemBuilder: (context, index) {
              final tender = tenders[index];
              return ListTile(
                title: Text('Tender ${tender.id.substring(0, 8)}'),
                subtitle: Text('Status: ${tender.status}'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  // Navigate to tender detail
                  Navigator.of(context).pushNamed(
                    '/tender/detail',
                    arguments: tender.id,
                  );
                },
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Text('Error: $error'),
        ),
      ),
    );
  }
}
