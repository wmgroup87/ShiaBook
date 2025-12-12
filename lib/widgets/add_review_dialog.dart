import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shia_book/controllers/holy_places_controller.dart';
import 'package:shia_book/models/holy_place.dart';

class AddReviewDialog extends StatefulWidget {
  final HolyPlace place;
  const AddReviewDialog({super.key, required this.place});

  @override
  State<AddReviewDialog> createState() => _AddReviewDialogState();
}

class _AddReviewDialogState extends State<AddReviewDialog> {
  int _rating = 0;
  final _commentController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('إضافة تقييم جديد'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('التقييم:',
                style: TextStyle(fontWeight: FontWeight.bold)),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return IconButton(
                  icon: Icon(
                    Icons.star,
                    size: 30,
                    color: index < _rating ? Colors.amber : Colors.grey,
                  ),
                  onPressed: () => setState(() => _rating = index + 1),
                );
              }),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _commentController,
              decoration: const InputDecoration(
                labelText: 'تعليقك',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'يرجى إدخال تعليقك';
                }
                return null;
              },
            ),
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
            if (_formKey.currentState!.validate() && _rating > 0) {
              final controller = Get.find<HolyPlacesController>();
              controller.addReview(
                widget.place,
                _rating,
                _commentController.text,
              );
              Get.back();
              Get.snackbar(
                'تمت الإضافة',
                'شكراً لتقييمك!',
                backgroundColor: Colors.green,
                colorText: Colors.white,
              );
            } else if (_rating == 0) {
              Get.snackbar('تنبيه', 'يرجى اختيار تقييم من 1 إلى 5');
            }
          },
          child: const Text('حفظ'),
        ),
      ],
    );
  }
}
