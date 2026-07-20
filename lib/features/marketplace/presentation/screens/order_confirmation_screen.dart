import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/premium_button.dart';
import '../../domain/entities/order.dart';
import '../../application/providers/marketplace_providers.dart';

class OrderConfirmationScreen extends ConsumerWidget {
  const OrderConfirmationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderId = GoRouterState.of(context).uri.queryParameters['orderId'] ?? '';
    final orderAsync = ref.watch(orderForIdProvider(orderId));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Sipariş Onayı',
          style: AppTextStyles.headlineMedium,
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: orderAsync.when(
        data: (order) {
          if (order == null) {
            return _buildNotFound(context);
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              children: [
                // Success animation/icon
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle_outline,
                    size: 64,
                    color: AppColors.success,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),

                // Status text
                Text(
                  'Siparişiniz Alındı!',
                  style: AppTextStyles.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.success,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Sipariş numaranız: #${order.id.substring(0, 8).toUpperCase()}',
                  style: AppTextStyles.textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.lg),

                // Order summary
                GlassCard(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    children: [
                      _OrderSummaryRow(label: 'Sipariş Tarihi', value: _formatDate(order.placedAt ?? order.createdAt)),
                      _OrderSummaryRow(label: 'Ödeme Durum', value: _formatStatus(order.status), valueColor: _getStatusColor(order.status)),
                      _OrderSummaryRow(label: 'Toplam Tutar', value: '\$${(order.totalAmount / 100).toStringAsFixed(2)}', isTotal: true),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.lg),

                // Shipping address
                GlassCard(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Teslimat Adresi',
                        style: AppTextStyles.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      _AddressBlock(address: order.shippingAddress),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.lg),

                // Items
                GlassCard(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sipariş Edilen Ürünler',
                        style: AppTextStyles.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      ...order.items.map((item) => _OrderItemTile(item: item)),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.xl),

                // Action buttons
                Column(
                  children: [
                    PremiumButton(
                      label: 'Sipariş Detayını Gör',
                      icon: Icons.visibility,
                      expand: true,
                      onPressed: () => context.push('${AppRoutes.orderDetail}?orderId=${order.id}'),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    PremiumButton(
                      label: 'Alışverişe Devam Et',
                      icon: Icons.shopping_bag_outlined,
                      expand: true,
                      onPressed: () => context.go(AppRoutes.marketplaceProducts),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    PremiumButton(
                      label: 'Ana Sayfa',
                      icon: Icons.home_outlined,
                      expand: true,
                      onPressed: () => context.go(AppRoutes.home),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: AppColors.error),
              const SizedBox(height: 16),
              Text('Sipariş bulunamadı', style: AppTextStyles.textTheme.titleMedium),
              const SizedBox(height: 8),
              Text(error.toString(), style: AppTextStyles.textTheme.bodySmall?.copyWith(color: AppColors.textSecondary)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotFound(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.receipt_long_outlined, size: 64, color: AppColors.textTertiary),
          const SizedBox(height: 16),
          Text('Sipariş bulunamadı', style: AppTextStyles.textTheme.headlineSmall?.copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: 24),
          PremiumButton(
            label: 'Ana Sayfaya Dön',
            icon: Icons.home_outlined,
            onPressed: () => context.go(AppRoutes.home),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  String _formatStatus(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 'Beklemede';
      case OrderStatus.confirmed:
        return 'Onaylandı';
      case OrderStatus.processing:
        return 'Hazırlanıyor';
      case OrderStatus.shipped:
        return 'Kargoda';
      case OrderStatus.delivered:
        return 'Teslim Edildi';
      case OrderStatus.cancelled:
        return 'İptal Edildi';
      case OrderStatus.returned:
        return 'İade Edildi';
      case OrderStatus.refunded:
        return 'İade Edildi';
      case OrderStatus.failed:
        return 'Başarısız';
    }
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return AppColors.warning;
      case OrderStatus.confirmed:
      case OrderStatus.processing:
        return AppColors.info;
      case OrderStatus.shipped:
        return AppColors.primary;
      case OrderStatus.delivered:
        return AppColors.success;
      case OrderStatus.cancelled:
      case OrderStatus.failed:
      case OrderStatus.returned:
        return AppColors.error;
      case OrderStatus.refunded:
        return AppColors.info;
    }
  }
}

class _OrderSummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final bool isTotal;

  const _OrderSummaryRow({
    required this.label,
    required this.value,
    this.valueColor,
    this.isTotal = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: isTotal
                ? AppTextStyles.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)
                : AppTextStyles.textTheme.bodyMedium,
          ),
          Text(
            value,
            style: isTotal
                ? AppTextStyles.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: valueColor ?? AppColors.primary,
                  )
                : AppTextStyles.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: valueColor,
                  ),
          ),
        ],
      ),
    );
  }
}

class _AddressBlock extends StatelessWidget {
  final Address address;

  const _AddressBlock({required this.address});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(address.name, style: AppTextStyles.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
        Text(address.line1, style: AppTextStyles.textTheme.bodyMedium),
        if (address.line2 != null && address.line2!.isNotEmpty)
          Text(address.line2!, style: AppTextStyles.textTheme.bodyMedium),
        Text('${address.city}, ${address.state} ${address.postalCode}', style: AppTextStyles.textTheme.bodyMedium),
        Text(address.country, style: AppTextStyles.textTheme.bodyMedium),
        if (address.phone.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text('Tel: ${address.phone}', style: AppTextStyles.textTheme.bodyMedium),
        ],
      ],
    );
  }
}

class _OrderItemTile extends StatelessWidget {
  final OrderItem item;

  const _OrderItemTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.card.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Icon(Icons.image, size: 24, color: AppColors.textTertiary),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productTitle,
                  style: AppTextStyles.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (item.variantAttributes.isNotEmpty)
                  Text(
                    item.variantAttributes.entries.map((e) => '${e.key}: ${e.value}').join(', '),
                    style: AppTextStyles.textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
                  ),
                Text(
                  '${item.quantity} x \$${(item.unitPrice / 100).toStringAsFixed(2)}',
                  style: AppTextStyles.textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          Text(
            '\$${(item.totalPrice / 100).toStringAsFixed(2)}',
            style: AppTextStyles.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}