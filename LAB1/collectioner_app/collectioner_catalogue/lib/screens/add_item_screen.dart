import 'package:flutter/material.dart';
import 'package:trezo/models/collection_item.dart';

class AddItemScreen extends StatefulWidget {
  const AddItemScreen({super.key});

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

  final List<String> _conditions = ['Відмінний', 'Добрий', 'Задовільний', 'Поганий'];
  String _selectedCondition = 'Відмінний';
  ItemStatus _selectedStatus = ItemStatus.collectionOnly;

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final imageUrl = _imageUrlController.text.trim().isEmpty
        ? 'https://media.istockphoto.com/id/1308330049/vector/prohibition-sign-no-video-recording.jpg?s=612x612&w=0&k=20&c=p907qk9TZjC9gUYy_Ou8UbGuLB23-HdfCl-QK_bZ7gM='
        : _imageUrlController.text.trim();

    final newItem = CollectionItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text.trim(),
      year: int.tryParse(_yearController.text.trim()) ?? DateTime.now().year,
      price: int.parse(_priceController.text.trim()),
      status: _selectedStatus,
      condition: _selectedCondition,
      imageUrl: imageUrl,
      description: _descriptionController.text.trim().isEmpty
          ? 'Новий предмет колекції. Деталі додаються пізніше.'
          : _descriptionController.text.trim(),
    );

    Navigator.of(context).pop(newItem);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Додати предмет'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                height: 180,
                decoration: BoxDecoration(
                  color: const Color(0xFF11161C),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF1F2A33)),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.photo_camera_outlined, size: 32, color: Color(0xFF6C7B8F)),
                      SizedBox(height: 8),
                      Text('Додати фото', style: TextStyle(color: Color(0xFF6C7B8F))),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _imageUrlController,
                decoration: const InputDecoration(
                  hintText: 'Посилання на зображення (опційно)',
                  prefixIcon: Icon(Icons.link_outlined),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  hintText: 'Введіть назву...',
                  labelText: 'Назва предмета',
                ),
                validator: (value) =>
                    value == null || value.trim().isEmpty ? 'Вкажіть назву' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _yearController,
                decoration: const InputDecoration(
                  hintText: 'Наприклад: 1904',
                  labelText: 'Рік',
                ),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value == null || value.trim().isEmpty ? 'Вкажіть рік' : null,
              ),
              const SizedBox(height: 16),
              const Text('Стан', style: TextStyle(fontWeight: FontWeight.w700)),
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
                  hintText: '₴0',
                  labelText: 'Вартість (оцінкова)',
                ),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value == null || value.trim().isEmpty ? 'Вкажіть вартість' : null,
              ),
              const SizedBox(height: 16),
              const Text('Статус', style: TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _statusButton('Тільки в колекції', ItemStatus.collectionOnly),
                  _statusButton('Пропоную на обмін', ItemStatus.exchange),
                  _statusButton('Пропоную на продаж', ItemStatus.sale),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: 'Додайте опис, історію або особливості...',
                  labelText: 'Опис (необовʼязково)',
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submit,
                  child: const Text('Додати предмет'),
                ),
              ),
            ],
          ),
        ),
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
