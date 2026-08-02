import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:floodstore/features/procurement/application/providers/procurement_providers.dart';
import 'package:floodstore/features/procurement/domain/entities/rfq.dart';
import 'package:floodstore/features/procurement/presentation/screens/rfq_list_screen.dart';

class CreateRFQScreen extends ConsumerStatefulWidget {
  const CreateRFQScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<CreateRFQScreen> createState() => _CreateRFQScreenState();
}

class _CreateRFQScreenState extends ConsumerState<CreateRFQScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _deliveryLocationController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _budgetController = TextEditingController();
  final _deadlineController = TextEditingController();
  // For simplicity, we'll just have one item; in a real app you'd have a list
  final _itemNameController = TextEditingController();
  final _itemQuantityController = TextEditingController();
  final _itemUnitOfMeasureController = TextEditingController();
  final _itemDescriptionController = TextEditingController();

  // Demo buyer ID
  static const String _demoBuyerId = 'buyer_001';

  @override
  void dispose() {
    _titleController.dispose();
    _deliveryLocationController.dispose();
    _descriptionController.dispose();
    _budgetController.dispose();
    _deadlineController.dispose();
    _itemNameController.dispose();
    _itemQuantityController.dispose();
    _itemUnitOfMeasureController.dispose();
    _itemDescriptionController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Show loading indicator
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Creating RFQ...')),
    );

    try {
      final rfqRepo = ref.read(rfqRepositoryProvider);

      // Create RFQ
      final rfq = RFQ(
        id: '', // will be set by repository
        buyerId: _demoBuyerId,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        totalBudget: double.tryParse(_budgetController.text) ?? 0.0,
        currency: 'USD',
        status: 'draft',
        issueDate: DateTime.now(),
        responseDeadline: DateTime.parse(_deadlineController.text),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final rfqId = await rfqRepo.createRFQ(rfq);

      // Create item
      final item = RFQItem(
        id: '',
        rfqId: rfqId,
        description: _itemNameController.text.trim(),
        specifications: _itemDescriptionController.text.trim(),
        quantity: double.tryParse(_itemQuantityController.text) ?? 0.0,
        unitOfMeasure: _itemUnitOfMeasureController.text.trim().isEmpty ? 'units' : _itemUnitOfMeasureController.text.trim(),
        deliveryLocation: _deliveryLocationController.text.trim(),
        deliveryDate: null,
        notes: null,
        customFields: null,
      );

      await rfqRepo.createRFQItem(item);

      // Update RFQ total (optional, we could compute from items)
      // For simplicity, we'll just update the RFQ with the item count? Not needed.

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('RFQ created successfully!')),
      );

      // Navigate to list
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const RFQListScreen()),
            (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create New RFQ'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title *'),
                validator: (value) =>
                value == null || value.isEmpty ? 'Please enter a title' : null,
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
              ),
              TextFormField(
                controller: _deliveryLocationController,
                decoration:
                const InputDecoration(labelText: 'Delivery Location *'),
                validator: (value) =>
                value == null || value.isEmpty ? 'Please enter a location' : null,
              ),
              TextFormField(
                controller: _budgetController,
                decoration:
                const InputDecoration(labelText: 'Total Budget (USD) *'),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a budget';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _deadlineController,
                decoration: const InputDecoration(
                  labelText: 'Response Deadline (YYYY-MM-DD) *',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a deadline';
                  }
                  final date = DateTime.tryParse('$value 00:00:00');
                  if (date == null) {
                    return 'Please enter a valid date';
                  }
                  return null;
                },
              ),
              const Divider(height: 32),
              const Text(
                'Item Details',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextFormField(
                controller: _itemNameController,
                decoration: const InputDecoration(labelText: 'Item Description *'),
                validator: (value) =>
                value == null || value.isEmpty ? 'Please enter item description' : null,
              ),
              TextFormField(
                controller: _itemDescriptionController,
                decoration: const InputDecoration(labelText: 'Specification'),
                maxLines: 2,
              ),
              TextFormField(
                controller: _itemQuantityController,
                decoration: const InputDecoration(labelText: 'Quantity *'),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter quantity';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _itemUnitOfMeasureController,
                decoration:
                const InputDecoration(labelText: 'Unit of Measure *'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter unit of measure';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              Center(
                child: ElevatedButton(
                  onPressed: _submitForm,
                  child: const Text('Create RFQ'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}