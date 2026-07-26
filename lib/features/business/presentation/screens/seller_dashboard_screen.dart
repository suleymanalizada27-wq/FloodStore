import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:floodstore/core/router/app_router.dart';
import 'package:floodstore/features/marketplace/application/providers/marketplace_providers.dart';
import 'package:floodstore/features/business/application/providers/business_providers.dart';
import 'package:floodstore/features/marketplace/domain/entities/product.dart';
import 'package:floodstore/features/marketplace/domain/entities/order.dart';

class SellerDashboardScreen extends ConsumerWidget {
  const SellerDashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = ref.watch(currentUserIdProvider);
    if (userId == null) {
      return const Scaffold(
        body: Center(child: Text('User not logged in')),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Seller Dashboard'),
      ),
      body: RefreshIndicator(
        onRefresh: () => Future.wait([
          ref.refresh(sellerProductsProvider(userId).future),
          ref.refresh(sellerOrdersProvider(userId).future),
        ]),
        child: ListView(
          children: [
            _buildSection(
              context: context,
              ref: ref,
              title: 'My Products',
              future: ref.watch(sellerProductsProvider(userId)),
              emptyMessage: 'No products yet',
              itemBuilder: (context, product) => ListTile(
                title: Text(product.base.title),
                subtitle: Text('\$${(product.pricing.basePrice / 100).toStringAsFixed(2)}'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  context.push(
                    AppRoutes.productDetail,
                    extra: product.id,
                  );
                },
              ),
            ),
            const Divider(height: 1),
            _buildSection(
              context: context,
              ref: ref,
              title: 'My Orders',
              future: ref.watch(sellerOrdersProvider(userId)),
              emptyMessage: 'No orders yet',
              itemBuilder: (context, order) => ListTile(
                title: Text('Order #${order.id.substring(0, 8)}'),
                subtitle: Text(
                  'Total: \$${(order.totalAmount / 100).toStringAsFixed(2)} • ${order.items.length} items',
                ),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  context.push(
                    AppRoutes.orderDetail,
                    extra: order.id,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection<T>({
    required BuildContext context,
    required WidgetRef ref,
    required String title,
    required AsyncValue<List<T>> future,
    required String emptyMessage,
    required Widget Function(BuildContext, T) itemBuilder,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          future.when(
            data: (data) {
              if (data.isEmpty) {
                return Center(child: Text(emptyMessage));
              }
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: data.length,
                itemBuilder: (context, index) => itemBuilder(context, data[index]),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Error: $e')),
          ),
        ],
      ),
    );
  }
}