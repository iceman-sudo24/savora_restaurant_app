import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/menu_package_model.dart';
import '../../data/repositories/menu_repository.dart';
import '../common/widgets/app_button.dart';
import '../common/widgets/app_text_field.dart';
import '../common/widgets/error_dialog.dart';

/// Shared form for creating and editing menu packages.
/// If [packageId] is provided, we're in edit mode — loads existing data.
class PackageFormScreen extends ConsumerStatefulWidget {
  final String? packageId;

  const PackageFormScreen({super.key, this.packageId});

  @override
  ConsumerState<PackageFormScreen> createState() => _PackageFormScreenState();
}

class _PackageFormScreenState extends ConsumerState<PackageFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _priceController = TextEditingController();
  final _itemsController = TextEditingController();
  final _imageUrlController = TextEditingController();

  bool _isLoading = false;
  bool _isInitLoading = true;

  bool get _isEditMode => widget.packageId != null;

  @override
  void initState() {
    super.initState();
    if (_isEditMode) {
      _loadExistingPackage();
    } else {
      _isInitLoading = false;
    }
  }

  Future<void> _loadExistingPackage() async {
    final repo = ref.read(menuRepositoryProvider);
    final package = await repo.getPackage(widget.packageId!);
    if (package != null && mounted) {
      setState(() {
        _nameController.text = package.name;
        _descController.text = package.description;
        _priceController.text = package.basePrice.toStringAsFixed(2);
        _itemsController.text = package.items.join(', ');
        _imageUrlController.text = package.imageUrl;
        _isInitLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _priceController.dispose();
    _itemsController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  List<String> _parseItems() {
    return _itemsController.text
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final repo = ref.read(menuRepositoryProvider);
      final price = double.tryParse(_priceController.text) ?? 0;

      final package = MenuPackageModel(
        id: widget.packageId ?? '',
        name: _nameController.text.trim(),
        description: _descController.text.trim(),
        basePrice: price,
        imageUrl: _imageUrlController.text.trim(),
        items: _parseItems(),
        createdAt: DateTime.now(),
      );

      if (_isEditMode) {
        await repo.updatePackage(package);
      } else {
        await repo.createPackage(package);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_isEditMode ? 'Package updated' : 'Package created')),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) showErrorDialog(context, e);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitLoading) {
      return Scaffold(
        appBar: AppBar(title: Text(_isEditMode ? 'Edit Package' : 'Add Package')),
        body: const Center(child: CircularProgressIndicator(color: AppColors.navy)),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Edit Package' : 'Add Package'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Image preview
              if (_imageUrlController.text.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: SizedBox(
                      height: 180,
                      width: double.infinity,
                      child: CachedNetworkImage(
                        imageUrl: _imageUrlController.text,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: AppColors.grey100,
                          child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: AppColors.grey100,
                          child: const Center(child: Icon(Icons.broken_image, color: AppColors.grey400)),
                        ),
                      ),
                    ),
                  ),
                ),

              // Image URL
              AppTextField(
                controller: _imageUrlController,
                label: 'Image URL (optional)',
                hint: 'https://example.com/image.jpg',
                prefixIcon: Icons.link,
                textInputAction: TextInputAction.next,
                onChanged: (_) => setState(() {}), // Refresh preview
              ),
              const SizedBox(height: 20),

              // Name
              AppTextField(
                controller: _nameController,
                label: 'Package Name',
                hint: 'e.g., Premium Buffet',
                prefixIcon: Icons.restaurant_menu,
                textInputAction: TextInputAction.next,
                validator: (v) => v == null || v.trim().isEmpty ? 'Name is required' : null,
              ),
              const SizedBox(height: 16),

              // Description
              AppTextField(
                controller: _descController,
                label: 'Description',
                hint: 'What makes this package special?',
                prefixIcon: Icons.description,
                maxLines: 3,
                textInputAction: TextInputAction.next,
                validator: (v) => v == null || v.trim().isEmpty ? 'Description is required' : null,
              ),
              const SizedBox(height: 16),

              // Base Price
              AppTextField(
                controller: _priceController,
                label: 'Base Price (${AppConstants.currencySymbol})',
                hint: 'e.g., 45.00',
                prefixIcon: Icons.attach_money,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Price is required';
                  final price = double.tryParse(v);
                  if (price == null || price <= 0) return 'Enter a valid price';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Items (comma-separated)
              AppTextField(
                controller: _itemsController,
                label: 'Included Items',
                hint: 'e.g., Nasi Lemak, Teh Tarik, Kuih',
                prefixIcon: Icons.list,
                maxLines: 2,
                textInputAction: TextInputAction.done,
              ),
              const SizedBox(height: 8),
              Text(
                'Separate items with commas',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 32),

              // Submit
              AppButton.primary(
                label: _isEditMode ? 'Update Package' : 'Create Package',
                onPressed: _isLoading ? null : _submit,
                loading: _isLoading,
                icon: _isEditMode ? Icons.save : Icons.add_circle,
              ),
            ],
          ),
        ),
      ),
    );
  }
}