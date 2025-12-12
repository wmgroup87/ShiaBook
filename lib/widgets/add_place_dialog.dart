import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:shia_book/controllers/holy_places_controller.dart';

class AddPlaceDialog extends StatefulWidget {
  final LatLng? location;
  const AddPlaceDialog({super.key, this.location});

  @override
  State<AddPlaceDialog> createState() => _AddPlaceDialogState();
}

class _AddPlaceDialogState extends State<AddPlaceDialog> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('إضافة مكان جديد'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'اسم المكان',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'يرجى إدخال اسم المكان';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'وصف المكان',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'يرجى إدخال وصف المكان';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            if (widget.location != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Text(
                      'الإحداثيات:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                        'خط العرض: ${widget.location!.latitude.toStringAsFixed(6)}'),
                    Text(
                        'خط الطول: ${widget.location!.longitude.toStringAsFixed(6)}'),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: const Text('إلغاء'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate() && widget.location != null) {
              final controller = Get.find<HolyPlacesController>();
              controller.addCustomPlace(
                _nameController.text,
                _descriptionController.text,
                widget.location!.latitude,
                widget.location!.longitude,
              );
              Get.back();
              Get.snackbar(
                'تم الإضافة',
                'تم إضافة المكان بنجاح',
                backgroundColor: Colors.green,
                colorText: Colors.white,
              );
            }
          },
          child: const Text('إضافة'),
        ),
      ],
    );
  }
}
