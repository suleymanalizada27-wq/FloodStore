import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:floodstore/features/tender/application/providers/tender_providers.dart';
import 'package:floodstore/features/tender/domain/entities/tender.dart';

class CreateTenderScreen extends ConsumerStatefulWidget {
  const CreateTenderScreen({super.key});

  @override
  ConsumerState<CreateTenderScreen> createState() => _CreateTenderScreenState();
}

class _CreateTenderScreenState extends ConsumerState<CreateTenderScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _rfqId;
  String _modeString = 'open';
  int _currentRound = 1;
  String _statusString = 'open';
  bool _isCreating = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Tender'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _isCreating
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'RFQ ID (optional)',
                        hintText: 'Enter RFQ ID if this tender is related to an RFQ',
                      ),
                      validator: (value) {
                        if (value != null && value.isNotEmpty) {
                          return null;
                        }
                        return 'Please enter some text';
                      },
                      onSaved: (value) {
                        _rfqId = value;
                      },
                    ),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: 'Mode'),
                      value: _modeString,
                      items: const [
                        DropdownMenuItem(value: 'open', child: Text('Open')),
                        DropdownMenuItem(value: 'sealed', child: Text('Sealed')),
                        DropdownMenuItem(
                            value: 'reverse_auction', child: Text('Reverse Auction')),
                        DropdownMenuItem(
                            value: 'multi_round', child: Text('Multi-round')),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _modeString = value;
                          });
                        }
                      },
                    ),
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'Current Round'),
                      initialValue: _currentRound.toString(),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a number';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _currentRound = int.parse(value!);
                      },
                    ),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: 'Status'),
                      value: _statusString,
                      items: const [
                        DropdownMenuItem(value: 'open', child: Text('Open')),
                        DropdownMenuItem(value: 'evaluating', child: Text('Evaluating')),
                        DropdownMenuItem(value: 'awarded', child: Text('Awarded')),
                        DropdownMenuItem(value: 'cancelled', child: Text('Cancelled')),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _statusString = value;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _isCreating ? null : _submitForm,
                      child: _isCreating
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : const Text('Create Tender'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        _isCreating = true;
      });

      // Convert string values to enums
      TenderMode mode;
      switch (_modeString) {
        case 'open':
          mode = TenderMode.open;
          break;
        case 'sealed':
          mode = TenderMode.sealed;
          break;
        case 'reverse_auction':
          mode = TenderMode.reverseAuction;
          break;
        case 'multi_round':
          mode = TenderMode.multiRound;
          break;
        default:
          mode = TenderMode.open;
      }

      TenderStatus status;
      switch (_statusString) {
        case 'open':
          status = TenderStatus.open;
          break;
        case 'evaluating':
          status = TenderStatus.evaluating;
          break;
        case 'awarded':
          status = TenderStatus.awarded;
          break;
        case 'cancelled':
          status = TenderStatus.cancelled;
          break;
        default:
          status = TenderStatus.open;
      }

      final tender = Tender(
        id: '', // Will be generated by repository
        rfqId: _rfqId,
        mode: mode,
        currentRound: _currentRound,
        status: status,
        createdAt: DateTime.now(),
      );

      // Use the createTenderProvider to create the tender
      ref
          .read(createTenderProvider(tender).future)
          .then((_) {
            // Successfully created
            if (mounted) {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Tender created successfully')),
              );
            }
          })
          .catchError((error) {
            if (mounted) {
              setState(() {
                _isCreating = false;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error creating tender: $error')),
              );
            }
          });
    }
  }
}
