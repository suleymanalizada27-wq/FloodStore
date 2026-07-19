import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/premium_button.dart';
import '../../../../core/widgets/premium_text_field.dart';
import '../../domain/entities/order.dart';
import '../../application/providers/marketplace_providers.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _line1Controller = TextEditingController();
  final _line2Controller = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _postalCodeController = TextEditingController();
  final _countryController = TextEditingController();
  final _phoneController = TextEditingController();

  bool _isLoading = false;
  String _selectedPaymentMethod = 'card';
  bool _sameAsBilling = true;

  @override
  void initState() {
    super.initState();
    _loadSavedAddresses();
  }

  Future<void> _loadSavedAddresses() async {
    final userId = ref.read(currentUserIdProvider);
    final addresses = await ref.read(userRepositoryProvider).getUserAddresses(userId!);
    if (addresses.isNotEmpty) {
      final defaultAddress = addresses.firstWhere((a) => a['isDefault'] == true, orElse: () => addresses.first);
      _fillAddressForm(defaultAddress);
    }
  }

  void _fillAddressForm(Map<String, dynamic> address) {
    _nameController.text = address['name'] ?? '';
    _line1Controller.text = address['line1'] ?? '';
    _line2Controller.text = address['line2'] ?? '';
    _cityController.text = address['city'] ?? '';
    _stateController.text = address['state'] ?? '';
    _postalCodeController.text = address['postalCode'] ?? '';
    _countryController.text = address['country'] ?? '';
    _phoneController.text = address['phone'] ?? '';
  }

  Future<void> _handlePayment(double amount) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Simulate payment processing
      await Future.delayed(const Duration(seconds: 2));
      
      // Simulate payment success (90% success rate for demo)
      if (DateTime.now().millisecondsSinceEpoch % 10 != 0) {
        await _completeOrder('simulated_payment_${DateTime.now().millisecondsSinceEpoch}');
      } else {
        _showError('Ödeme reddedildi. Lütfen tekrar deneyin.');
      }
    } catch (e) {
      _showError('Ödeme hatası: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _completeOrder(String paymentIntentId) async {
    try {
      final userId = ref.read(currentUserIdProvider)!;
      final cart = await ref.read(cartRepositoryProvider).getCart(userId);
      
      if (cart == null || cart.items.isEmpty) {
        _showError('Sepetiniz boş');
        return;
      }

      final orderId = await ref.read(orderRepositoryProvider).createOrderFromCart(userId, cart);

      // Add payment info
      await ref.read(orderRepositoryProvider).addPaymentInfo(orderId, PaymentInfo(
        provider: PaymentProvider.stripe,
        providerPaymentId: paymentIntentId,
        status: 'succeeded',
        amount: cart.subtotalAmount + 500 + (cart.subtotalAmount * 0.18).roundToDouble(),
        currency: 'USD',
        details: {'paymentMethod': _selectedPaymentMethod},
      ));

      // Update payment status
      await ref.read(orderRepositoryProvider).updateOrderPaymentStatus(
        orderId,
        PaymentStatus.captured,
        changedBy: userId,
      );

      if (mounted) {
        context.go('${AppRoutes.orderConfirmation}?orderId=$orderId');
      }
    } catch (e) {
      _showError('Sipariş oluşturulamadı: $e');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _line1Controller.dispose();
    _line2Controller.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _postalCodeController.dispose();
    _countryController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userId = ref.watch(currentUserIdProvider);
    final cartAsync = ref.watch(cartForUserProvider(userId!));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Ödeme',
          style: AppTextStyles.headlineMedium,
        ),
        centerTitle: true,
      ),
      body: cartAsync.when(
        data: (cart) {
          if (cart == null || cart.items.isEmpty) {
            return _buildEmptyCart(context);
          }

          const shipping = 500.0;
          final taxAmount = (cart.subtotalAmount * 0.18).roundToDouble();
          final total = cart.subtotalAmount + shipping + taxAmount;

          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.md),
              children: [
                // Shipping Address Section
                _SectionTitle(title: 'Teslimat Adresi'),
                GlassCard(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    children: [
                      PremiumTextField(
                        controller: _nameController,
                        label: 'Ad Soyad',
                        hint: 'Ad Soyad',
                        validator: (v) => v!.isEmpty ? 'Zorunlu' : null,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      PremiumTextField(
                        controller: _phoneController,
                        label: 'Telefon',
                        hint: '+90 XXX XXX XX XX',
                        keyboardType: TextInputType.phone,
                        validator: (v) => v!.isEmpty ? 'Zorunlu' : null,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      PremiumTextField(
                        controller: _line1Controller,
                        label: 'Adres Satırı 1',
                        hint: 'Mahalle, Sokak, No',
                        validator: (v) => v!.isEmpty ? 'Zorunlu' : null,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      PremiumTextField(
                        controller: _line2Controller,
                        label: 'Adres Satırı 2 (İsteğe Bağlı)',
                        hint: 'Daire, Blok, Kat',
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Row(
                        children: [
                          Expanded(
                            child: PremiumTextField(
                              controller: _cityController,
                              label: 'Şehir',
                              hint: 'İstanbul',
                              validator: (v) => v!.isEmpty ? 'Zorunlu' : null,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: PremiumTextField(
                              controller: _stateController,
                              label: 'İlçe/İl',
                              hint: 'Kadıköy',
                              validator: (v) => v!.isEmpty ? 'Zorunlu' : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Row(
                        children: [
                          Expanded(
                            child: PremiumTextField(
                              controller: _postalCodeController,
                              label: 'Posta Kodu',
                              hint: '34000',
                              keyboardType: TextInputType.number,
                              validator: (v) => v!.isEmpty ? 'Zorunlu' : null,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: PremiumTextField(
                              controller: _countryController,
                              label: 'Ülke',
                              hint: 'Türkiye',
                              validator: (v) => v!.isEmpty ? 'Zorunlu' : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Row(
                        children: [
                          Checkbox(
                            value: _sameAsBilling,
                            onChanged: (v) => setState(() => _sameAsBilling = v!),
                            activeColor: AppColors.primary,
                          ),
                          Text('Fatura adresi aynı', style: AppTextStyles.textTheme.bodyMedium),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.lg),

                // Payment Method Section
                _SectionTitle(title: 'Ödeme Yöntemi'),
                GlassCard(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    children: [
                      _PaymentMethodTile(
                        icon: Icons.credit_card,
                        title: 'Kredi / Banka Kartı',
                        subtitle: 'Visa, Mastercard, Troy',
                        isSelected: _selectedPaymentMethod == 'card',
                        onTap: () => setState(() => _selectedPaymentMethod = 'card'),
                      ),
                      const Divider(height: 1, color: AppColors.border),
                      _PaymentMethodTile(
                        icon: Icons.money_outlined,
                        title: 'Kapıda Ödeme',
                        subtitle: 'Nakit veya kart ile teslimatta ödeme',
                        isSelected: _selectedPaymentMethod == 'cod',
                        onTap: () => setState(() => _selectedPaymentMethod = 'cod'),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.lg),

                // Order Summary Section
                _SectionTitle(title: 'Sipariş Özeti'),
                GlassCard(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    children: [
                      _SummaryRow(label: 'Ara Toplam', value: '\$${(cart.subtotalAmount / 100).toStringAsFixed(2)}'),
                      _SummaryRow(label: 'Kargo', value: '\$${(shipping / 100).toStringAsFixed(2)}'),
                      _SummaryRow(label: 'KDV (%18)', value: '\$${(taxAmount / 100).toStringAsFixed(2)}'),
                      const Divider(height: 24, thickness: 1, color: AppColors.border),
                      _SummaryRow(
                        label: 'TOPLAM',
                        value: '\$${(total / 100).toStringAsFixed(2)}',
                        isTotal: true,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.xl),

                // Place Order Button
                PremiumButton(
                  label: 'Siparişi Ver (\$${(total / 100).toStringAsFixed(2)})',
                  icon: Icons.lock_outline,
                  expand: true,
                  loading: _isLoading,
                  onPressed: _isLoading ? null : () => _handlePayment(total),
                ),

                const SizedBox(height: AppSpacing.md),

                // Security notice
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.lock_outline, size: 16, color: AppColors.textTertiary),
                    const SizedBox(width: 4),
                    Text(
                      'Güvenli ödeme - SSL şifreli',
                      style: AppTextStyles.textTheme.bodySmall?.copyWith(color: AppColors.textTertiary),
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
              Text('Sepet yüklenemedi', style: AppTextStyles.textTheme.titleMedium),
              const SizedBox(height: 8),
              Text(error.toString(), style: AppTextStyles.textTheme.bodySmall?.copyWith(color: AppColors.textSecondary)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyCart(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.shopping_cart_outlined, size: 64, color: AppColors.textTertiary),
          const SizedBox(height: 16),
          Text('Sepetiniz boş', style: AppTextStyles.textTheme.headlineSmall?.copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: 24),
          PremiumButton(
            label: 'Alışverişe Başla',
            icon: Icons.shopping_bag_outlined,
            onPressed: () => context.push(AppRoutes.marketplaceProducts),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Text(
        title,
        style: AppTextStyles.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _PaymentMethodTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const _PaymentMethodTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm, horizontal: AppSpacing.sm),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.border,
                  width: 2,
                ),
                color: isSelected ? AppColors.primary : Colors.transparent,
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: AppSpacing.md),
            Icon(icon, size: 28, color: AppColors.textPrimary),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: AppTextStyles.textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isTotal;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.isTotal = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
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
                    color: AppColors.primary,
                  )
                : AppTextStyles.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}