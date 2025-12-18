import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:trezo/models/user_collection.dart';
import 'package:trezo/repositories/storage_repository.dart';
import 'package:trezo/state/collections_provider.dart';
import 'package:trezo/state/mutation_status.dart';

class AddCollectionScreen extends StatefulWidget {
  const AddCollectionScreen({super.key, this.initialCollection});

  final UserCollection? initialCollection;

  @override
  State<AddCollectionScreen> createState() => _AddCollectionScreenState();
}

class _AddCollectionScreenState extends State<AddCollectionScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _typeController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController();

  Uint8List? _pickedImageBytes;
  XFile? _pickedImageFile;
  bool _isUploading = false;
  String? _uploadError;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialCollection;
    if (initial != null) {
      _titleController.text = initial.title;
      _typeController.text = initial.type;
      _imageUrlController.text = initial.imageUrl;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _typeController.dispose();
    _imageUrlController.dispose();
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
      _uploadError = null;
    });
  }

  Future<StorageUploadResult?> _uploadCoverImage(
    StorageRepository storage,
    String collectionId,
  ) async {
    if (_pickedImageBytes == null) return null;
    setState(() => _isUploading = true);
    try {
      final result = await storage.uploadCollectionImage(
        collectionId: collectionId,
        bytes: _pickedImageBytes!,
      );
      return result;
    } catch (e) {
      _uploadError = 'Failed to upload image.';
      return null;
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<CollectionsProvider>();
    final storage = context.read<StorageRepository>();
    final isEditing = widget.initialCollection != null;
    _uploadError = null;
    final imageUrlValue = _imageUrlController.text.trim();
    final fallbackImageUrl = imageUrlValue.isEmpty
        ? 'https://images.unsplash.com/photo-1457369804613-52c61a468e7d?auto=format&fit=crop&w=400&q=80'
        : imageUrlValue;

    final baseCollection = UserCollection(
      id: widget.initialCollection?.id ?? '',
      title: _titleController.text.trim(),
      type: _typeController.text.trim(),
      imageUrl: isEditing ? widget.initialCollection!.imageUrl : fallbackImageUrl,
      imagePath: widget.initialCollection?.imagePath,
      itemsCount: widget.initialCollection?.itemsCount ?? 0,
      ownerId: widget.initialCollection?.ownerId,
      createdAt: widget.initialCollection?.createdAt,
      updatedAt: widget.initialCollection?.updatedAt,
    );

    if (isEditing) {
      if (_pickedImageBytes != null) {
        final upload = await _uploadCoverImage(storage, baseCollection.id);
        if (upload == null) {
          if (mounted && _uploadError != null) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(_uploadError!)));
          }
          return;
        }
        await provider.updateCollection(
          baseCollection.copyWith(
            imageUrl: upload.downloadUrl,
            imagePath: upload.path,
          ),
        );
        final previousPath = widget.initialCollection?.imagePath;
        if (previousPath != null && previousPath != upload.path) {
          try {
            await storage.deleteImage(previousPath);
          } catch (_) {}
        }
      } else {
        final effectiveUrl =
            imageUrlValue.isEmpty ? widget.initialCollection!.imageUrl : imageUrlValue;
        await provider.updateCollection(baseCollection.copyWith(imageUrl: effectiveUrl));
      }
    } else {
      final created = await provider.createCollection(baseCollection);
      if (created == null) return;
      if (_pickedImageBytes != null) {
        final upload = await _uploadCoverImage(storage, created.id);
        if (upload == null) {
          if (mounted && _uploadError != null) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(_uploadError!)));
          }
          return;
        }
        await provider.updateCollection(
          created.copyWith(imageUrl: upload.downloadUrl, imagePath: upload.path),
        );
      } else {
        await provider.updateCollection(created.copyWith(imageUrl: fallbackImageUrl));
      }
    }

    if (!mounted) return;
    if (_uploadError != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_uploadError!)));
      return;
    }
    if (provider.mutationStatus == MutationStatus.error) {
      final message = provider.mutationError ?? 'Failed to save collection.';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
      return;
    }

    provider.resetMutationStatus();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isSaving =
        context.watch<CollectionsProvider>().mutationStatus == MutationStatus.saving ||
            _isUploading;
    final isEditing = widget.initialCollection != null;

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: Text(isEditing ? 'Edit collection' : 'New collection'),
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
                              : (isEditing && widget.initialCollection!.imageUrl.isNotEmpty)
                                  ? Image.network(
                                      widget.initialCollection!.imageUrl,
                                      fit: BoxFit.cover,
                                      errorBuilder: (c, o, s) => _buildImagePlaceholder(),
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
                label: Text(_pickedImageFile == null ? 'Pick image' : 'Change image'),
              ),
              if (_isUploading)
                const Padding(
                  padding: EdgeInsets.only(top: 8.0),
                  child: LinearProgressIndicator(),
                ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                ),
                validator: (value) =>
                    value == null || value.trim().isEmpty ? 'Title is required.' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _typeController,
                decoration: const InputDecoration(
                  labelText: 'Type',
                ),
                validator: (value) =>
                    value == null || value.trim().isEmpty ? 'Type is required.' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _imageUrlController,
                decoration: const InputDecoration(
                  labelText: 'Image URL',
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
  }

  Widget _buildImagePlaceholder() {
    return Container(
      color: const Color(0xFF11161C),
      child: const Center(
        child: Icon(Icons.photo_camera_outlined, size: 32, color: Color(0xFF6C7B8F)),
      ),
    );
  }
}
