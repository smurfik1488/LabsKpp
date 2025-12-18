import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:trezo/models/collection_item.dart';
import 'package:trezo/repositories/storage_repository.dart';
import 'package:trezo/state/collection_items_provider.dart';
import 'package:trezo/state/item_image_upload_provider.dart';
import 'package:trezo/state/mutation_status.dart';

class AddItemScreen extends StatefulWidget {
  const AddItemScreen({super.key, this.initialItem});

  final CollectionItem? initialItem;

  @override
  State<AddItemScreen> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController();

  late final ItemImageUploadProvider _uploadProvider;
  Uint8List? _pickedImageBytes;
  XFile? _pickedImageFile;

  final List<String> _conditions = ['Mint', 'Good', 'Fair', 'Poor'];
  String _selectedCondition = 'Mint';
  ItemStatus _selectedStatus = ItemStatus.collectionOnly;

  @override
  void initState() {
    super.initState();
    _uploadProvider = ItemImageUploadProvider(
      repository: context.read<StorageRepository>(),
    );
    final initial = widget.initialItem;
    if (initial != null) {
      _nameController.text = initial.name;
      _yearController.text = initial.year.toString();
      _priceController.text = initial.price.toString();
      _descriptionController.text = initial.description;
      _imageUrlController.text = initial.imageUrl;
      if (!_conditions.contains(initial.condition)) {
        _conditions.add(initial.condition);
      }
      _selectedCondition = initial.condition;
      _selectedStatus = initial.status;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _yearController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _imageUrlController.dispose();
    _uploadProvider.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (file == null) return;
    final bytes = await file.readAsBytes();
    setState(() {
      _pickedImageFile = file;
      _pickedImageBytes = bytes;
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final itemsProvider = context.read<CollectionItemsProvider>();
    final uploadProvider = _uploadProvider;
    final isEditing = widget.initialItem != null;
    final imageUrlValue = _imageUrlController.text.trim();
    final fallbackImageUrl = imageUrlValue.isEmpty
        ? 'https://media.istockphoto.com/id/1308330049/vector/prohibition-sign-no-video-recording.jpg?s=612x612&w=0&k=20&c=p907qk9TZjC9gUYy_Ou8UbGuLB23-HdfCl-QK_bZ7gM='
        : imageUrlValue;

    final baseItem = CollectionItem(
      id: widget.initialItem?.id ?? '',
      name: _nameController.text.trim(),
      year: int.tryParse(_yearController.text.trim()) ?? DateTime.now().year,
      price: int.parse(_priceController.text.trim()),
      status: _selectedStatus,
      condition: _selectedCondition,
      imageUrl: isEditing ? widget.initialItem!.imageUrl : fallbackImageUrl,
      description: _descriptionController.text.trim().isEmpty
          ? 'No description provided.'
          : _descriptionController.text.trim(),
      ownerId: widget.initialItem?.ownerId,
      collectionId: widget.initialItem?.collectionId,
      imagePath: widget.initialItem?.imagePath,
      createdAt: widget.initialItem?.createdAt,
      updatedAt: widget.initialItem?.updatedAt,
    );

    if (isEditing) {
      if (_pickedImageBytes != null) {
        final upload = await uploadProvider.uploadItemImage(
          collectionId: itemsProvider.collectionId,
          itemId: baseItem.id,
          bytes: _pickedImageBytes!,
        );
        if (upload == null) return;
        await itemsProvider.updateItem(
          baseItem.copyWith(imageUrl: upload.downloadUrl, imagePath: upload.path),
        );
        final previousPath = widget.initialItem?.imagePath;
        if (previousPath != null && previousPath != upload.path) {
          try {
            await uploadProvider.deleteImage(previousPath);
          } catch (_) {}
        }
      } else {
        final effectiveUrl =
            imageUrlValue.isEmpty ? widget.initialItem!.imageUrl : imageUrlValue;
        await itemsProvider.updateItem(baseItem.copyWith(imageUrl: effectiveUrl));
      }
    } else {
      if (_pickedImageBytes != null) {
        final created = await itemsProvider.createItem(baseItem);
        if (created == null) return;
        final upload = await uploadProvider.uploadItemImage(
          collectionId: itemsProvider.collectionId,
          itemId: created.id,
          bytes: _pickedImageBytes!,
        );
        if (upload == null) return;
        await itemsProvider.updateItem(
          created.copyWith(imageUrl: upload.downloadUrl, imagePath: upload.path),
        );
      } else {
        await itemsProvider.createItem(baseItem.copyWith(imageUrl: fallbackImageUrl));
      }
    }

    if (!mounted) return;
    if (itemsProvider.mutationStatus == MutationStatus.error) {
      final message = itemsProvider.mutationError ?? 'Failed to save item.';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
      return;
    }

    itemsProvider.resetMutationStatus();
    uploadProvider.reset();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _uploadProvider,
      child: Builder(
        builder: (context) {
          final itemsProvider = context.watch<CollectionItemsProvider>();
          final uploadProvider = context.watch<ItemImageUploadProvider>();
          final isSaving = itemsProvider.mutationStatus == MutationStatus.saving ||
              uploadProvider.status == UploadStatus.uploading;
          final isEditing = widget.initialItem != null;

          return Scaffold(
            appBar: AppBar(
              leading: const BackButton(),
              title: Text(isEditing ? 'Edit item' : 'New item'),
            ),
            body: Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    GestureDetector(
                      onTap: isSaving ? null : _pickImage,
                      child: Container(
                        height: 180,
                        decoration: BoxDecoration(
                          color: const Color(0xFF11161C),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFF1F2A33)),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Stack(
                            children: [
                              Positioned.fill(
                                child: _pickedImageBytes != null
                                    ? Image.memory(
                                        _pickedImageBytes!,
                                        fit: BoxFit.cover,
                                      )
                                    : (isEditing && widget.initialItem!.imageUrl.isNotEmpty)
                                        ? Image.network(
                                            widget.initialItem!.imageUrl,
                                            fit: BoxFit.cover,
                                            errorBuilder: (c, o, s) =>
                                                _buildImagePlaceholder(),
                                          )
                                        : _buildImagePlaceholder(),
                              ),
                              if (!isSaving)
                                Positioned(
                                  right: 12,
                                  bottom: 12,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.6),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Text(
                                      'Tap to choose',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextButton.icon(
                      onPressed: isSaving ? null : _pickImage,
                      icon: const Icon(Icons.photo_library_outlined),
                      label: Text(
                        _pickedImageFile == null ? 'Pick image' : 'Change image',
                      ),
                    ),
                    if (uploadProvider.status == UploadStatus.uploading)
                      const Padding(
                        padding: EdgeInsets.only(top: 8.0),
                        child: LinearProgressIndicator(),
                      ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _imageUrlController,
                      decoration: const InputDecoration(
                        hintText: 'Image URL (optional)',
                        prefixIcon: Icon(Icons.link_outlined),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        hintText: 'Item name...',
                        labelText: 'Name',
                      ),
                      validator: (value) =>
                          value == null || value.trim().isEmpty ? 'Name is required.' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _yearController,
                      decoration: const InputDecoration(
                        hintText: 'Year',
                        labelText: 'Year',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) =>
                          value == null || value.trim().isEmpty ? 'Year is required.' : null,
                    ),
                    const SizedBox(height: 16),
                    const Text('Condition', style: TextStyle(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _conditions.map((condition) {
                        final bool isSelected = _selectedCondition == condition;
                        return ChoiceChip(
                          label: Text(condition),
                          selected: isSelected,
                          onSelected: (_) => setState(() => _selectedCondition = condition),
                          selectedColor: const Color(0xFF00C6FF).withOpacity(0.15),
                          backgroundColor: const Color(0xFF11161C),
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : const Color(0xFFC7C7C7),
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: isSelected ? const Color(0xFF00C6FF) : const Color(0xFF1F2A33),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _priceController,
                      decoration: const InputDecoration(
                        hintText: 'Price',
                        labelText: 'Price',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) =>
                          value == null || value.trim().isEmpty ? 'Price is required.' : null,
                    ),
                    const SizedBox(height: 16),
                    const Text('Status', style: TextStyle(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _statusButton('Collection only', ItemStatus.collectionOnly),
                        _statusButton('Exchange', ItemStatus.exchange),
                        _statusButton('For sale', ItemStatus.sale),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionController,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        hintText: 'Description...',
                        labelText: 'Description',
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isSaving ? null : _submit,
                        child: Text(isSaving ? 'Saving...' : 'Save'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      color: const Color(0xFF11161C),
      child: const Center(
        child: Icon(Icons.photo_camera_outlined, size: 32, color: Color(0xFF6C7B8F)),
      ),
    );
  }

  Widget _statusButton(String label, ItemStatus status) {
    final bool isSelected = _selectedStatus == status;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => setState(() => _selectedStatus = status),
      selectedColor: const Color(0xFF00C6FF).withOpacity(0.15),
      backgroundColor: const Color(0xFF11161C),
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : const Color(0xFFC7C8CF),
        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? const Color(0xFF00C6FF) : const Color(0xFF1F2A33),
        ),
      ),
    );
  }
}
