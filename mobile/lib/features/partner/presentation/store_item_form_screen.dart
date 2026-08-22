import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/pet_taxonomy.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/utils/api_error.dart';
import '../../../core/widgets/async_error_view.dart';
import '../../../core/widgets/petly_background.dart';
import '../../../data/models/store_item.dart';
import '../../../data/repositories/partners_repository.dart';
import '../providers/partner_providers.dart';

class StoreItemFormScreen extends ConsumerStatefulWidget {
  const StoreItemFormScreen({
    super.key,
    required this.storeId,
    this.itemId,
  });

  final String storeId;
  final String? itemId;

  @override
  ConsumerState<StoreItemFormScreen> createState() => _StoreItemFormScreenState();
}

class _StoreItemFormScreenState extends ConsumerState<StoreItemFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _description = TextEditingController();
  final _price = TextEditingController();
  final _imageUrl = TextEditingController();
  String _currency = 'USD';
  bool _inStock = true;
  ItemCategory _category = ItemCategory.other;
  List<PetType> _petTypes = [];
  bool _loading = false;
  bool _saving = false;
  Object? _loadError;

  bool get _isEdit => widget.itemId != null;

  @override
  void initState() {
    super.initState();
    if (_isEdit) _loadExisting();
  }

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    _price.dispose();
    _imageUrl.dispose();
    super.dispose();
  }

  Future<void> _loadExisting() async {
    setState(() {
      _loading = true;
      _loadError = null;
    });
    try {
      final items = await ref
          .read(partnersRepositoryProvider)
          .listStoreItems(widget.storeId);
      StoreItem? item;
      for (final row in items) {
        if (row.id == widget.itemId) {
          item = row;
          break;
        }
      }
      if (item == null) {
        throw ApiException('Item not found');
      }
      _name.text = item.name;
      _description.text = item.description ?? '';
      _price.text = item.price?.toString() ?? '';
      _imageUrl.text = item.imageUrl ?? '';
      _currency = item.currency == 'LBP' ? 'LBP' : 'USD';
      _inStock = item.inStock;
      _category = item.category;
      _petTypes = List.of(item.petTypes);
    } catch (error) {
      _loadError = error;
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final priceText = _price.text.trim();
      final body = PartnersRepository.storeItemPayload(
        name: _name.text.trim(),
        description: _description.text.trim(),
        price: priceText.isEmpty ? null : double.parse(priceText),
        currency: _currency,
        imageUrl: _imageUrl.text.trim(),
        inStock: _inStock,
        category: _category,
        petTypes: _petTypes,
      );
      final repo = ref.read(partnersRepositoryProvider);
      if (_isEdit) {
        await repo.updateStoreItem(widget.storeId, widget.itemId!, body);
      } else {
        await repo.createStoreItem(widget.storeId, body);
      }
      ref.invalidate(partnerStoreItemsProvider(widget.storeId));
      if (!mounted) return;
      context.pop();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(friendlyErrorMessage(context, error))),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PetlyBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(title: Text(_isEdit ? 'Edit item' : 'Add item')),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : _loadError != null
                ? AsyncErrorView(error: _loadError!, onRetry: _loadExisting)
                : Form(
                    key: _formKey,
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                      children: [
                        TextFormField(
                          controller: _name,
                          decoration: const InputDecoration(
                            labelText: 'Name',
                            hintText: 'Premium dog food 12kg',
                          ),
                          validator: (value) =>
                              (value == null || value.trim().isEmpty)
                                  ? 'Name is required'
                                  : null,
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _description,
                          maxLines: 3,
                          decoration: const InputDecoration(
                            labelText: 'Description (optional)',
                          ),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _price,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                  decimal: true,
                                ),
                                decoration: const InputDecoration(
                                  labelText: 'Price (optional)',
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return null;
                                  }
                                  final parsed = double.tryParse(value.trim());
                                  if (parsed == null || parsed < 0) {
                                    return 'Enter a valid price';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: InputDecorator(
                                decoration: const InputDecoration(
                                  labelText: 'Currency',
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: _currency,
                                    isExpanded: true,
                                    items: const [
                                      DropdownMenuItem(
                                        value: 'USD',
                                        child: Text('USD'),
                                      ),
                                      DropdownMenuItem(
                                        value: 'LBP',
                                        child: Text('LBP'),
                                      ),
                                    ],
                                    onChanged: (value) {
                                      if (value == null) return;
                                      setState(() => _currency = value);
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Category',
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<ItemCategory>(
                              value: _category,
                              isExpanded: true,
                              items: ItemCategory.values
                                  .map(
                                    (category) => DropdownMenuItem(
                                      value: category,
                                      child: Text(category.label),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (value) {
                                if (value == null) return;
                                setState(() => _category = value);
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _imageUrl,
                          decoration: const InputDecoration(
                            labelText: 'Image URL (optional)',
                            hintText: 'https://… or asset:listings/…',
                          ),
                        ),
                        Row(
                          children: [
                            const Expanded(child: Text('In stock')),
                            Switch(
                              value: _inStock,
                              onChanged: (value) =>
                                  setState(() => _inStock = value),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Text(
                          'Which pets is this for?',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Leave empty to show for all pets.',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: PetType.values
                              .map(
                                (type) => FilterChip(
                                  avatar: Icon(type.icon, size: 16),
                                  label: Text(type.label),
                                  selected: _petTypes.contains(type),
                                  onSelected: (selected) {
                                    setState(() {
                                      _petTypes = selected
                                          ? [..._petTypes, type]
                                          : _petTypes
                                              .where((t) => t != type)
                                              .toList();
                                    });
                                  },
                                ),
                              )
                              .toList(),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: _saving ? null : _save,
                          child: _saving
                              ? SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onPrimary,
                                  ),
                                )
                              : Text(_isEdit ? 'Save item' : 'Add item'),
                        ),
                      ],
                    ),
                  ),
      ),
    );
  }
}
