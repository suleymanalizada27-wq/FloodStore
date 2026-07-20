import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/premium_button.dart';
import '../../application/providers/marketplace_providers.dart';
import '../../domain/entities/cart.dart';
import '../../domain/entities/order.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _line1Controller = TextEditingController();
  final _line2Controller = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _postalCodeController = TextEditingController();
  final _countryController = TextEditingController();

  String _selectedPaymentMethod = 'card';
  String _selectedDeliveryOption = 'standard';
  Address? _selectedAddress;
  List<Address> _savedAddresses = [];
  bool _isLoading = false;
  bool _isLoadingAddresses = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadSavedAddresses();
  }

  Future<void> _loadSavedAddresses() async {
    setState(() {
      _isLoadingAddresses = true;
      _errorMessage = null;
    });

    try {
      final userId = ref.read(currentUserIdProvider)!;
      final addressesData =
          await ref.read(userRepositoryProvider).getUserAddresses(userId);

      setState(() {
        _savedAddresses = addressesData
            .map((addr) => Address(
                  name: addr['name'] ?? '',
                  phone: addr['phone'] ?? '',
                  line1: addr['line1'] ?? '',
                  line2: addr['line2'],
                  city: addr['city'] ?? '',
                  state: addr['state'] ?? '',
                  postalCode: addr['postalCode'] ?? '',
                  country: addr['country'] ?? '',
                ))
            .toList();
        _isLoadingAddresses = false;

        // Select first address by default if none selected
        if (_selectedAddress == null && _savedAddresses.isNotEmpty) {
          _selectedAddress = _savedAddresses.first;
          _populateAddressForm(_selectedAddress!);
        }
      });
    } catch (e) {
      setState(() {
        _isLoadingAddresses = false;
        _errorMessage = 'Failed to load addresses: $e';
      });
    }
  }

  void _populateAddressForm(Address address) {
    _nameController.text = address.name;
    _phoneController.text = address.phone;
    _line1Controller.text = address.line1;
    _line2Controller.text = address.line2 ?? '';
    _cityController.text = address.city;
    _stateController.text = address.state;
    _postalCodeController.text = address.postalCode;
    _countryController.text = address.country;
  }

  Address _getFormAddress() {
    return Address(
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      line1: _line1Controller.text.trim(),
      line2: _line2Controller.text.trim().isEmpty
          ? null
          : _line2Controller.text.trim(),
      city: _cityController.text.trim(),
      state: _stateController.text.trim(),
      postalCode: _postalCodeController.text.trim(),
      country: _countryController.text.trim(),
    );
  }

  Future<void> _placeOrder() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final userId = ref.read(currentUserIdProvider)!;
      final cart = await ref.read(cartRepositoryProvider).getCart(userId);

      if (cart == null || cart.items.isEmpty) {
        throw Exception('Your cart is empty');
      }

      final address = _getFormAddress();

      // Calculate totals
      const shippingCost = 500.0; // 5.00 in cents
      final taxAmount = (cart.subtotalAmount * 0.18).roundToDouble();

      double shippingMultiplier = 1.0;
      switch (_selectedDeliveryOption) {
        case 'express':
          shippingMultiplier = 2.0;
          break;
        case 'overnight':
          shippingMultiplier = 4.0;
          break;
        default: // standard
          shippingMultiplier = 1.0;
      }

      final shippingAmount = (shippingCost * shippingMultiplier).roundToDouble();
      final totalAmount = cart.subtotalAmount + shippingAmount + taxAmount;

      // Create order
      final orderId = await ref.read(orderRepositoryProvider).createOrderFromCart(
        userId,
        cart,
        notes: 'Checkout via mobile app',
      );

      // Update order with shipping address and payment info
      final order = Order(
        id: orderId,
        userId: userId,
        status: OrderStatus.pending,
        fulfillmentStatus: FulfillmentStatus.pending,
        paymentStatus: PaymentStatus.pending, // Will be updated after payment
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        placedAt: DateTime.now(),
        subtotalAmount: cart.subtotalAmount,
        taxAmount: taxAmount,
        shippingAmount: shippingAmount,
        discountAmount: 0,
        totalAmount: totalAmount,
        currency: 'USD',
        customerNotes: null,
        internalNotes: null,
        shippingAddress: address,
        billingAddress: address, // For now, same as shipping
        items: cart.items
            .map((item) => OrderItem(
                  id: item.id,
                  productId: item.productId,
                  variantId: item.variantId,
                  quantity: item.quantity,
                  unitPrice: item.unitPrice,
                  totalPrice: item.totalPrice,
                  productTitle: item.productTitle,
                  variantAttributes: item.variantAttributes,
                ))
            .toList(),
        discounts: [],
        payment: PaymentInfo(
          provider: _selectedPaymentMethod == 'card'
              ? PaymentProvider.stripe
              : PaymentProvider.paypal,
          providerPaymentId: 'mock_payment_${DateTime.now().millisecondsSinceEpoch}',
          status: 'paid',
          amount: totalAmount,
          currency: 'USD',
          details: {'method': _selectedPaymentMethod},
        ),
        tracking: null,
        history: [],
      );

      // Update the order with complete information
      await ref
          .read(orderRepositoryProvider)
          .updateOrderStatus(orderId, OrderStatus.confirmed);
      await ref.read(orderRepositoryProvider).addPaymentInfo(
            orderId,
            order.payment!,
          );

      // Clear cart after successful order
      await ref.read(cartRepositoryProvider).clearCart(userId);

      if (mounted) {
        // Navigate to order confirmation screen
        context.go('${AppRoutes.orderConfirmation}?orderId=$orderId');
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to place order: $e';
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _line1Controller.dispose();
    _line2Controller.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _postalCodeController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userId = ref.watch(currentUserIdProvider);
    final cartAsync = ref.watch(cartProvider(userId ?? ''));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Checkout',
          style: AppTextStyles.headlineMedium,
        ),
        centerTitle: true,
      ),
      body: cartAsync.when(
        data: (cart) {
          if (cart == null || cart.items.isEmpty) {
            return _buildEmptyCart(context);
          }

          if (_isLoadingAddresses) {
            return const Center(child: CircularProgressIndicator());
          }

          if (_errorMessage != null) {
            return _buildErrorState(context, _errorMessage!);
          }

          return _buildCheckoutForm(context, cart);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _buildErrorState(context, error.toString()),
      ),
    );
  }

  Widget _buildEmptyCart(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.shopping_cart_outlined,
              size: 64,
              color: AppColors.textTertiary,
            ),
            const SizedBox(height: 16),
            Text(
              'Your cart is empty',
              style: AppTextStyles.textTheme.headlineSmall
                  ?.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),
            PremiumButton(
              label: 'Continue Shopping',
              icon: Icons.shopping_bag_outlined,
              onPressed: () => context.go(AppRoutes.marketplaceProducts),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 48,
              color: AppColors.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Something went wrong',
              style: AppTextStyles.textTheme.titleMedium
                  ?.copyWith(color: AppColors.error),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: AppTextStyles.textTheme.bodySmall
                  ?.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            PremiumButton(
              label: 'Try Again',
              onPressed: _loadSavedAddresses,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckoutForm(BuildContext context, Cart cart) {
    // Calculate totals
    const shippingCost = 500.0; // 5.00 in cents
    final taxAmount = (cart.subtotalAmount * 0.18).roundToDouble();

    double shippingMultiplier = 1.0;
    switch (_selectedDeliveryOption) {
      case 'express':
        shippingMultiplier = 2.0;
        break;
      case 'overnight':
        shippingMultiplier = 3.0;
        break;
      default: // standard
        shippingMultiplier = 1.0;
    }

    final shippingAmount = (shippingCost * shippingMultiplier).roundToDouble();
    final totalAmount = cart.subtotalAmount + shippingAmount + taxAmount;

    return SingleChildScrollView(
      padding: EdgeInsets.all(AppSpacing.md),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Address Section
            const Text(
              'Shipping Address',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            _buildAddressSection(),
            const SizedBox(height: 24),

            // Delivery Options Section
            const Text(
              'Delivery Options',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            _buildDeliveryOptions(),
            const SizedBox(height: 24),

            // Payment Method Section
            const Text(
              'Payment Method',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            _buildPaymentMethods(),
            const SizedBox(height: 24),

            // Order Summary
            const Text(
              'Order Summary',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            _buildOrderSummary(cart, shippingAmount, taxAmount, totalAmount),
            const SizedBox(height: 24),

            // Place Order Button
            PremiumButton(
              label: 'Place Order',
              icon: Icons.check_circle_outline,
              isLoading: _isLoading,
              onPressed: _isLoading ? null : _placeOrder,
            ),
          ],
        ),
      ),
    );
  }

  void _showAddressSelectionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.card,
        title: Text(
          'Select Address',
          style: AppTextStyles.textTheme.titleLarge,
        ),
        content: SingleChildScrollView(
          child: ListBody(
            children: _savedAddresses.map((address) => ListTile(
              leading: const Icon(Icons.home, color: AppColors.primary),
              title: Text(address.name),
              subtitle: Text('${address.line1}, ${address.city}, ${address.postalCode}'),
              onTap: () {
                setState(() {
                  _selectedAddress = address;
                  _populateAddressForm(address);
                });
                Navigator.of(context).pop();
              },
            )).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSummary(Cart cart, double shippingAmount, double taxAmount, double totalAmount) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          _buildOrderSummaryRow('Subtotal', '\$${(cart.subtotalAmount / 100).toStringAsFixed(2)}'),
          _buildOrderSummaryRow('Shipping', '\$${(shippingAmount / 100).toStringAsFixed(2)}'),
          _buildOrderSummaryRow('Tax (18%)', '\$${(taxAmount / 100).toStringAsFixed(2)}'),
          const Divider(height: 24, thickness: 1, color: AppColors.border),
          _buildOrderSummaryRow(
            'TOTAL',
            '\$${(totalAmount / 100).toStringAsFixed(2)}',
            isTotal: true,
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSummaryRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? AppColors.primary : Colors.black87,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isTotal ? AppColors.primary : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}