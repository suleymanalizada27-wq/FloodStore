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

class OrderDetailScreen extends ConsumerWidget {
  const OrderDetailScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderId = GoRouterState.of(context).uri.queryParameters['orderId'] ?? '';
    final orderAsync = ref.watch(orderRepositoryProvider.select((repo) => repo.getOrderById(orderId)));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Sipariş Detayı',
          style: AppTextStyles.headlineMedium,
        ),
        centerTitle: true,
      ),
      body: orderAsync.when(
        data: (order) {
          if (order == null) {
            return _buildNotFound(context);
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Order header with status
                GlassCard(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Sipariş #${order.id.substring(0, 8).toUpperCase()}',
                                  style: AppTextStyles.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _formatDate(order.placedAt),
                                  style: AppTextStyles.textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                          ),
                          _StatusChip(status: order.status),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Row(
                        children: [
                          _StatusInfoItem(
                            icon: Icons.payment,
                            label: 'Ödeme',
                            value: _formatPaymentStatus(order.paymentStatus),
                            color: _getPaymentStatusColor(order.paymentStatus),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          _StatusInfoItem(
                            icon: Icons.local_shipping,
                            label: 'Kargo',
                            value: _formatFulfillmentStatus(order.fulfillmentStatus),
                            color: _getFulfillmentStatusColor(order.fulfillmentStatus),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.lg),

                // Tracking info if available
                if (order.tracking != null) ...[
                  GlassCard(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.local_shipping_outlined, color: AppColors.primary, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'Kargo Takibi',
                              style: AppTextStyles.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.md),
                        if (order.tracking!.trackingNumber != null) ...[
                          _TrackingRow(label: 'Takip Numarası', value: order.tracking!.trackingNumber!),
                          const SizedBox(height: AppSpacing.sm),
                        ],
                        if (order.tracking!.carrier != null && order.tracking!.carrier!.isNotEmpty) ...[
                          _TrackingRow(label: 'Kargo Firması', value: order.tracking!.carrier!),
                          const SizedBox(height: AppSpacing.sm),
                        ],
                        if (order.tracking!.estimatedDelivery != null) ...[
                          _TrackingRow(label: 'Tahmini Teslimat', value: _formatDate(order.tracking!.estimatedDelivery!)),
                        ],
                        if (order.tracking!.events.isNotEmpty) ...[
                          const SizedBox(height: AppSpacing.md),
                          Text('Kargo Hareketleri', style: AppTextStyles.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                          const SizedBox(height: AppSpacing.sm),
                          ...order.tracking!.events.map((event) => _TrackingEventTile(event: event)),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.lg),
                ],

                // Shipping address
                GlassCard(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Teslimat Adresi', style: AppTextStyles.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: AppSpacing.sm),
                      _AddressBlock(address: order.shippingAddress),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.lg),

                // Billing address if different
                if (order.billingAddress.line1 != order.shippingAddress.line1 ||
                    order.billingAddress.city != order.shippingAddress.city) ...[
                  GlassCard(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Fatura Adresi', style: AppTextStyles.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: AppSpacing.sm),
                        _AddressBlock(address: order.billingAddress),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                ],

                // Items
                GlassCard(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Sipariş Edilen Ürünler', style: AppTextStyles.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: AppSpacing.md),
                      ...order.items.map((item) => _OrderDetailItemTile(item: item)),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.lg),

                // Price breakdown
                GlassCard(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Fiyat Detayı', style: AppTextStyles.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: AppSpacing.md),
                      _PriceRow(label: 'Ara Toplam', value: '\$${(order.subtotalAmount / 100).toStringAsFixed(2)}'),
                      _PriceRow(label: 'Kargo', value: '\$${(order.shippingAmount / 100).toStringAsFixed(2)}'),
                      _PriceRow(label: 'KDV (%18)', value: '\$${(order.taxAmount / 100).toStringAsFixed(2)}'),
                      if (order.discountAmount > 0)
                        _PriceRow(label: 'İndirim', value: '-\$${(order.discountAmount / 100).toStringAsFixed(2)}', isDiscount: true),
                      const Divider(height: 24, thickness: 1, color: AppColors.border),
                      _PriceRow(
                        label: 'TOPLAM',
                        value: '\$${(order.totalAmount / 100).toStringAsFixed(2)}',
                        isTotal: true,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.lg),

                // Order history timeline
                GlassCard(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Sipariş Geçmişi', style: AppTextStyles.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: AppSpacing.md),
                      ..._buildHistoryTimeline(order),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.xl),

                // Actions
                if (order.status == OrderStatus.pending || order.status == OrderStatus.confirmed) ...[
                  PremiumButton(
                    label: 'Siparişi İptal Et',
                    icon: Icons.cancel_outlined,
                    variant: PremiumButtonVariant.destructive,
                    expand: true,
                    onPressed: () => _showCancelDialog(context, ref, order),
                  ),
                  const SizedBox(height: AppSpacing.md),
                ],

                PremiumButton(
                  label: 'Fatura İndir',
                  icon: Icons.download_outlined,
                  variant: PremiumButtonVariant.outline,
                  expand: true,
                  onPressed: () => _downloadInvoice(order),
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
              Text('Sipariş yüklenemedi', style: AppTextStyles.textTheme.titleMedium),
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
      );
    );
  }

  void _showCancelDialog(BuildContext context, WidgetRef ref, Order order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text('Siparişi İptal Et', style: AppTextStyles.textTheme.titleLarge),
        content: Text('Bu işlem geri alınamaz. Emin misiniz?', style: AppTextStyles.textTheme.bodyMedium),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Hayır', style: AppTextStyles.textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary)),
          ),
          PremiumButton(
            label: 'Evet, İptal Et',
            variant: PremiumButtonVariant.destructive,
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(orderRepositoryProvider).cancelOrder(
                order.id,
                cancelledBy: ref.read(currentUserIdProvider)!,
                reason: 'Kullanıcı isteği',
              );
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Sipariş iptal edildi'), backgroundColor: AppColors.success),
                );
                context.pop();
              }
            },
          ),
        ],
      ),
    );
  }

  void _downloadInvoice(Order order) {
    // TODO: Implement PDF generation and download
    // For now, show a toast
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
      case OrderStatus.refunded:
        return 'İade Edildi';
      case OrderStatus.failed:
        return 'Başarısız';
    }
  }

  String _formatPaymentStatus(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.pending:
        return 'Beklemede';
      case PaymentStatus.authorized:
        return 'Yetkilendirildi';
      case PaymentStatus.paid:
        return 'Ödendi';
      case PaymentStatus.failed:
        return 'Başarısız';
      case PaymentStatus.refunded:
        return 'İade Edildi';
      case PaymentStatus.partiallyRefunded:
        return 'Kısmen İade';
    }
  }

  String _formatFulfillmentStatus(FulfillmentStatus status) {
    switch (status) {
      case FulfillmentStatus.pending:
        return 'Beklemede';
      case FulfillmentStatus.processing:
        return 'İşleniyor';
      case FulfillmentStatus.shipped:
        return 'Gönderildi';
      case FulfillmentStatus.outForDelivery:
        return 'Dağıtımda';
      case FulfillmentStatus.delivered:
        return 'Teslim Edildi';
      case FulfillmentStatus.returned:
        return 'İade Edildi';
      case FulfillmentStatus.cancelled:
        return 'İptal';
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
        return AppColors.error;
      case OrderStatus.refunded:
        return AppColors.info;
    }
  }

  Color _getPaymentStatusColor(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.pending:
        return AppColors.warning;
      case PaymentStatus.authorized:
        return AppColors.info;
      case PaymentStatus.paid:
        return AppColors.success;
      case PaymentStatus.failed:
        return AppColors.error;
      case PaymentStatus.refunded:
      case PaymentStatus.partiallyRefunded:
        return AppColors.info;
    }
  }

  Color _getFulfillmentStatusColor(FulfillmentStatus status) {
    switch (status) {
      case FulfillmentStatus.pending:
        return AppColors.warning;
      case FulfillmentStatus.processing:
        return AppColors.info;
      case FulfillmentStatus.shipped:
        return AppColors.primary;
      case FulfillmentStatus.outForDelivery:
        return AppColors.primary;
      case FulfillmentStatus.delivered:
        return AppColors.success;
      case FulfillmentStatus.returned:
        return AppColors.warning;
      case FulfillmentStatus.cancelled:
        return AppColors.error;
    }
  }

  List<Widget> _buildHistoryTimeline(Order order) {
    final events = <_TimelineEvent>[];

    events.add(_TimelineEvent(
      title: 'Sipariş Oluşturuldu',
      subtitle: _formatDate(order.placedAt),
      icon: Icons.shopping_cart_checkout,
      color: AppColors.primary,
      isCompleted: true,
    ));

    if (order.paymentStatus == PaymentStatus.paid || order.paymentStatus == PaymentStatus.authorized) {
      events.add(_TimelineEvent(
        title: 'Ödeme Onaylandı',
        subtitle: 'Ödeme başarıyla alındı',
        icon: Icons.payment,
        color: AppColors.success,
        isCompleted: true,
      ));
    }

    if (order.fulfillmentStatus != FulfillmentStatus.pending) {
      events.add(_TimelineEvent(
        title: 'Sipariş Hazırlandı',
        subtitle: 'Kargoya verildi',
        icon: Icons.inventory_2_outlined,
        color: AppColors.info,
        isCompleted: order.fulfillmentStatus != FulfillmentStatus.processing,
      ));
    }

    if (order.fulfillmentStatus == FulfillmentStatus.shipped || order.fulfillmentStatus == FulfillmentStatus.outForDelivery) {
      events.add(_TimelineEvent(
        title: 'Kargoda',
        subtitle: order.tracking?.trackingNumber != null ? 'Takip: ${order.tracking!.trackingNumber}' : 'Kargo yolda',
        icon: Icons.local_shipping,
        color: AppColors.primary,
        isCompleted: order.fulfillmentStatus != FulfillmentStatus.outForDelivery,
      ));
    }

    if (order.fulfillmentStatus == FulfillmentStatus.delivered) {
      events.add(_TimelineEvent(
        title: 'Teslim Edildi',
        subtitle: _formatDate(order.completedAt ?? order.updatedAt),
        icon: Icons.check_circle_outline,
        color: AppColors.success,
        isCompleted: true,
      ));
    }

    if (order.status == OrderStatus.cancelled) {
      events.add(_TimelineEvent(
        title: 'Sipariş İptal Edildi',
        subtitle: order.internalNotes ?? 'Kullanıcı tarafından iptal edildi',
        icon: Icons.cancel_outlined,
        color: AppColors.error,
        isCompleted: true,
      ));
    }

    return events.map((e) => _TimelineEventTile(event: e, isLast: e == events.last)).toList();
  }

  Widget _buildHistoryTimeline(Order order) {
    return Column(
      children: _buildHistoryTimeline(order),
    );
  }
}

class _TimelineEvent {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final bool isCompleted;

  const _TimelineEvent({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.isCompleted,
  });
}

class _TimelineEventTile extends StatelessWidget {
  final _TimelineEvent event;
  final bool isLast;

  const _TimelineEventTile({required this.event, required this.isLast});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: event.color,
                  shape: BoxShape.circle,
                ),
                child: Icon(event.icon, size: 12, color: Colors.white),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: AppColors.border,
                    margin: const EdgeInsets.only(top: 4),
                  ),
                ),
            ],
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  style: AppTextStyles.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: event.isCompleted ? AppColors.textPrimary : AppColors.textTertiary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  event.subtitle,
                  style: AppTextStyles.textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final OrderStatus status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final colors = _getStatusColors(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.border),
      ),
      child: Text(
        _formatStatus(status),
        style: AppTextStyles.textTheme.bodySmall?.copyWith(
          fontWeight: FontWeight.w600,
          color: colors.text,
        ),
      ),
    );
  }

  ({Color background, Color border, Color text}) _getStatusColors(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return (background: AppColors.warning.withValues(alpha: 0.15), border: AppColors.warning, text: AppColors.warning);
      case OrderStatus.confirmed:
      case OrderStatus.processing:
        return (background: AppColors.info.withValues(alpha: 0.15), border: AppColors.info, text: AppColors.info);
      case OrderStatus.shipped:
        return (background: AppColors.primary.withValues(alpha: 0.15), border: AppColors.primary, text: AppColors.primary);
      case OrderStatus.delivered:
        return (background: AppColors.success.withValues(alpha: 0.15), border: AppColors.success, text: AppColors.success);
      case OrderStatus.cancelled:
      case OrderStatus.failed:
        return (background: AppColors.error.withValues(alpha: 0.15), border: AppColors.error, text: AppColors.error);
      case OrderStatus.refunded:
        return (background: AppColors.info.withValues(alpha: 0.15), border: AppColors.info, text: AppColors.info);
    }
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
      case OrderStatus.refunded:
        return 'İade Edildi';
      case OrderStatus.failed:
        return 'Başarısız';
    }
  }
}

class _StatusInfoItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatusInfoItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(label, style: AppTextStyles.textTheme.bodySmall?.copyWith(color: AppColors.textSecondary)),
            const SizedBox(height: 2),
            Text(value, style: AppTextStyles.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600, color: color)),
          ],
        ),
      ),
    );
  }
}

class _TrackingRow extends StatelessWidget {
  final String label;
  final String value;

  const _TrackingRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(label, style: AppTextStyles.textTheme.bodySmall?.copyWith(color: AppColors.textSecondary)),
        ),
        Expanded(
          child: Text(value, style: AppTextStyles.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }
}

class _TrackingEventTile extends StatelessWidget {
  final TrackingEvent event;

  const _TrackingEventTile({required this.event});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.only(top: 6),
            decoration: BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(event.description, style: AppTextStyles.textTheme.bodyMedium),
                const SizedBox(height: 2),
                Text(
                  '${event.location != null ? '${event.location} • ' : ''}${_formatDateTime(event.timestamp)}',
                  style: AppTextStyles.textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
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
        if (address.phone != null && address.phone!.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text('Tel: ${address.phone}', style: AppTextStyles.textTheme.bodyMedium),
        ],
      ],
    );
  }
}

class _OrderDetailItemTile extends StatelessWidget {
  final OrderItem item;

  const _OrderDetailItemTile({required this.item});

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
                Text(item.productTitle, style: AppTextStyles.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
                if (item.variantAttributes.isNotEmpty)
                  Text(item.variantAttributes.entries.map((e) => '${e.key}: ${e.value}').join(', '), style: AppTextStyles.textTheme.bodySmall?.copyWith(color: AppColors.textSecondary)),
                Text('${item.quantity} x \$${(item.unitPrice / 100).toStringAsFixed(2)}', style: AppTextStyles.textTheme.bodySmall?.copyWith(color: AppColors.textSecondary)),
              ],
            ),
          ),
          Text('\$${(item.totalPrice / 100).toStringAsFixed(2)}', style: AppTextStyles.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold, color: AppColors.primary)),
        ],
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isTotal;
  final bool isDiscount;

  const _PriceRow({
    required this.label,
    required this.value,
    this.isTotal = false,
    this.isDiscount = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: isTotal ? AppTextStyles.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold) : AppTextStyles.textTheme.bodyMedium),
          Text(
            value,
            style: isTotal
                ? AppTextStyles.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: AppColors.primary)
                : isDiscount
                    ? AppTextStyles.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600, color: AppColors.error)
                    : AppTextStyles.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}