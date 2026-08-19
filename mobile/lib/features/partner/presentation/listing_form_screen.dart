import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/utils/api_error.dart';
import '../../../core/widgets/async_error_view.dart';
import '../../../core/widgets/petly_background.dart';
import '../../../core/widgets/status_chip.dart';
import '../../../data/models/listing_hours.dart';
import '../../../data/models/store.dart';
import '../../../data/models/vet.dart';
import '../../../data/repositories/partners_repository.dart';
import '../providers/partner_providers.dart';
import '../widgets/hours_editor.dart';

enum PartnerListingKind { vet, store }

class ListingFormScreen extends ConsumerStatefulWidget {
  const ListingFormScreen({
    super.key,
    required this.kind,
    this.listingId,
  });

  final PartnerListingKind kind;
  final String? listingId;

  @override
  ConsumerState<ListingFormScreen> createState() => _ListingFormScreenState();
}

class _ListingFormScreenState extends ConsumerState<ListingFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _location = TextEditingController();
  final _type = TextEditingController(text: 'Pet Store');
  final _imageUrl = TextEditingController();
  final _lat = TextEditingController();
  final _lng = TextEditingController();
  final _serviceInput = TextEditingController();

  List<String> _services = [];
  bool _isOpenNow = true;
  bool _isEmergency = false;
  ListingHours _hours = ListingHours.template();
  String? _status;
  String? _rejectionReason;
  bool _loading = false;
  bool _saving = false;
  Object? _loadError;

  bool get _isEdit => widget.listingId != null;
  bool get _isVet => widget.kind == PartnerListingKind.vet;

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      _loadExisting();
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _location.dispose();
    _type.dispose();
    _imageUrl.dispose();
    _lat.dispose();
    _lng.dispose();
    _serviceInput.dispose();
    super.dispose();
  }

  Future<void> _loadExisting() async {
    setState(() {
      _loading = true;
      _loadError = null;
    });
    try {
      final repo = ref.read(partnersRepositoryProvider);
      if (_isVet) {
        final vet = await repo.getVet(widget.listingId!);
        _applyVet(vet);
      } else {
        final store = await repo.getStore(widget.listingId!);
        _applyStore(store);
      }
    } catch (error) {
      _loadError = error;
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _applyVet(Vet vet) {
    _name.text = vet.name;
    _phone.text = vet.phone;
    _location.text = vet.location;
    _imageUrl.text = vet.imageUrl ?? '';
    _lat.text = vet.latitude?.toString() ?? '';
    _lng.text = vet.longitude?.toString() ?? '';
    _services = List.of(vet.services);
    _isOpenNow = vet.isOpenNow;
    _isEmergency = vet.isEmergency;
    _hours = vet.hours ?? ListingHours.template();
    _status = vet.status;
    _rejectionReason = vet.rejectionReason;
  }

  void _applyStore(Store store) {
    _name.text = store.name;
    _phone.text = store.phone ?? '';
    _location.text = store.location;
    _type.text = store.type;
    _imageUrl.text = store.imageUrl ?? '';
    _lat.text = store.latitude?.toString() ?? '';
    _lng.text = store.longitude?.toString() ?? '';
    _services = List.of(store.services);
    _isOpenNow = store.isOpenNow;
    _hours = store.hours ?? ListingHours.template();
    _status = store.status;
    _rejectionReason = store.rejectionReason;
  }

  void _addService() {
    final value = _serviceInput.text.trim();
    if (value.isEmpty || _services.contains(value) || _services.length >= 20) {
      return;
    }
    setState(() {
      _services = [..._services, value];
      _serviceInput.clear();
    });
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _saving = true);
    try {
      final repo = ref.read(partnersRepositoryProvider);
      final lat = double.tryParse(_lat.text.trim());
      final lng = double.tryParse(_lng.text.trim());
      if (_isVet) {
        final body = PartnersRepository.vetPayload(
          name: _name.text.trim(),
          phone: _phone.text.trim(),
          location: _location.text.trim(),
          services: _services,
          isEmergency: _isEmergency,
          isOpenNow: _isOpenNow,
          latitude: lat,
          longitude: lng,
          imageUrl: _imageUrl.text.trim(),
          hours: _hours,
        );
        if (_isEdit) {
          await repo.updateVet(widget.listingId!, body);
        } else {
          await repo.createVet(body);
        }
      } else {
        final body = PartnersRepository.storePayload(
          name: _name.text.trim(),
          type: _type.text.trim(),
          location: _location.text.trim(),
          services: _services,
          isOpenNow: _isOpenNow,
          phone: _phone.text.trim(),
          latitude: lat,
          longitude: lng,
          imageUrl: _imageUrl.text.trim(),
          hours: _hours,
        );
        if (_isEdit) {
          await repo.updateStore(widget.listingId!, body);
        } else {
          await repo.createStore(body);
        }
      }
      ref.invalidate(partnerListingsProvider);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Submitted for review. It will appear in Explore once approved.',
          ),
        ),
      );
      context.go('/partner');
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(friendlyErrorMessage(error))),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = _isVet
        ? (_isEdit ? 'Edit clinic' : 'Add clinic')
        : (_isEdit ? 'Edit store' : 'Add store');

    return PetlyBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(title: Text(title)),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : _loadError != null
                ? AsyncErrorView(error: _loadError!, onRetry: _loadExisting)
                : Form(
                    key: _formKey,
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                      children: [
                        if (_status != null) ...[
                          Row(
                            children: [
                              StatusChip(status: _status!),
                              const SizedBox(width: 12),
                              if (_status == 'rejected' &&
                                  (_rejectionReason?.isNotEmpty ?? false))
                                Expanded(child: Text(_rejectionReason!)),
                            ],
                          ),
                          const SizedBox(height: 16),
                        ],
                        TextFormField(
                          controller: _name,
                          textCapitalization: TextCapitalization.words,
                          decoration: InputDecoration(
                            labelText: _isVet ? 'Clinic name' : 'Store name',
                          ),
                          validator: (value) =>
                              (value == null || value.trim().isEmpty)
                                  ? 'Name is required'
                                  : null,
                        ),
                        const SizedBox(height: 14),
                        if (!_isVet) ...[
                          TextFormField(
                            controller: _type,
                            decoration: const InputDecoration(
                              labelText: 'Type',
                              hintText: 'Pet Store, Grooming, Aquarium…',
                            ),
                            validator: (value) =>
                                (value == null || value.trim().isEmpty)
                                    ? 'Type is required'
                                    : null,
                          ),
                          const SizedBox(height: 14),
                        ],
                        TextFormField(
                          controller: _phone,
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            labelText: _isVet ? 'Phone' : 'Phone (optional)',
                            hintText: '9617…',
                          ),
                          validator: (value) {
                            if (!_isVet) return null;
                            if (value == null || value.trim().isEmpty) {
                              return 'Phone is required';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _location,
                          decoration: const InputDecoration(
                            labelText: 'Location',
                            hintText: 'Hamra, Beirut',
                          ),
                          validator: (value) =>
                              (value == null || value.trim().isEmpty)
                                  ? 'Location is required'
                                  : null,
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _lat,
                                keyboardType: const TextInputType.numberWithOptions(
                                  decimal: true,
                                  signed: true,
                                ),
                                decoration: const InputDecoration(
                                  labelText: 'Latitude (optional)',
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                controller: _lng,
                                keyboardType: const TextInputType.numberWithOptions(
                                  decimal: true,
                                  signed: true,
                                ),
                                decoration: const InputDecoration(
                                  labelText: 'Longitude (optional)',
                                ),
                              ),
                            ),
                          ],
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
                            const Expanded(child: Text('Open now')),
                            Switch(
                              value: _isOpenNow,
                              onChanged: (value) =>
                                  setState(() => _isOpenNow = value),
                            ),
                          ],
                        ),
                        if (_isVet)
                          Row(
                            children: [
                              const Expanded(child: Text('Emergency care')),
                              Switch(
                                value: _isEmergency,
                                onChanged: (value) =>
                                    setState(() => _isEmergency = value),
                              ),
                            ],
                          ),
                        const SizedBox(height: 8),
                        Text(
                          'Services',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            for (final service in _services)
                              InputChip(
                                label: Text(service),
                                onDeleted: () {
                                  setState(() {
                                    _services = _services
                                        .where((item) => item != service)
                                        .toList();
                                  });
                                },
                              ),
                          ],
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _serviceInput,
                                decoration: const InputDecoration(
                                  labelText: 'Add a service',
                                ),
                                onFieldSubmitted: (_) => _addService(),
                              ),
                            ),
                            IconButton(
                              tooltip: 'Add service',
                              onPressed: _addService,
                              icon: const Icon(Icons.add_circle_outline),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        HoursEditor(
                          value: _hours,
                          onChanged: (value) => _hours = value,
                        ),
                        if (_isEdit && !_isVet) ...[
                          const SizedBox(height: 16),
                          OutlinedButton.icon(
                            onPressed: () => context.push(
                              '/partner/stores/${widget.listingId}/items',
                            ),
                            icon: const Icon(Icons.inventory_2_outlined),
                            label: const Text('Manage store items'),
                          ),
                        ],
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: _saving ? null : _save,
                          child: _saving
                              ? SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Theme.of(context).colorScheme.onPrimary,
                                  ),
                                )
                              : Text(_isEdit ? 'Resubmit for review' : 'Submit for review'),
                        ),
                      ],
                    ),
                  ),
      ),
    );
  }
}
