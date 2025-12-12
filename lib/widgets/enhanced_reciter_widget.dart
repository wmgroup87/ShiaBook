import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shia_book/constants/app_colors.dart';
import 'package:shia_book/controllers/audio_controller.dart';
import 'package:shia_book/services/reciter_availability_service.dart';

class EnhancedReciterWidget extends StatefulWidget {
  const EnhancedReciterWidget({super.key});

  @override
  State<EnhancedReciterWidget> createState() => _EnhancedReciterWidgetState();
}

class _EnhancedReciterWidgetState extends State<EnhancedReciterWidget> {
  final Map<String, bool> _reciterAvailability = {};
  final Map<String, bool> _checkingAvailability = {};

  @override
  void initState() {
    super.initState();
    _checkRecitersAvailability();
  }

  Future<void> _checkRecitersAvailability() async {
    final audioController = Get.find<AudioController>();

    for (final reciter in audioController.availableReciters) {
      setState(() {
        _checkingAvailability[reciter] = true;
      });

      // فحص توفر القارئ مع سورة الفاتحة
      final isAvailable =
          await ReciterAvailabilityService.isReciterAvailable(reciter, 1);

      setState(() {
        _reciterAvailability[reciter] = isAvailable;
        _checkingAvailability[reciter] = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final audioController = Get.find<AudioController>();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.record_voice_over, color: AppColors.primary, size: 24),
              const SizedBox(width: 8),
              Text(
                'اختيار القارئ',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _checkRecitersAvailability,
                tooltip: 'إعادة فحص التوفر',
              ),
            ],
          ),
          const SizedBox(height: 16),

          // القراء الشيعة
          _buildReciterSection(
            'القراء الشيعة',
            [
              'كريم منصوري',
              'ميثم التمار',
              'باسم الكربلائي',
            ],
            Colors.green,
            audioController,
          ),

          const SizedBox(height: 16),

          // القراء التقليديون
          _buildReciterSection(
            'القراء التقليديون',
            [
              'محمد صديق المنشاوي',
              'محمود خليل الحصري',
            ],
            Colors.blue,
            audioController,
          ),
        ],
      ),
    );
  }

  Widget _buildReciterSection(
    String title,
    List<String> reciters,
    Color color,
    AudioController audioController,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 8),
        ...reciters.map((reciter) => Obx(() => Container(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: color.withOpacity(0.1),
                  child: _buildReciterIcon(reciter, color),
                ),
                title: Row(
                  children: [
                    Expanded(
                      child: Text(
                        reciter,
                        style: TextStyle(
                          fontWeight:
                              audioController.selectedReciter.value == reciter
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                        ),
                      ),
                    ),
                    _buildAvailabilityIndicator(reciter),
                  ],
                ),
                subtitle: _buildReciterSubtitle(reciter),
                trailing: audioController.selectedReciter.value == reciter
                    ? Icon(Icons.check_circle, color: color)
                    : null,
                selected: audioController.selectedReciter.value == reciter,
                selectedTileColor: color.withOpacity(0.1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                onTap: _reciterAvailability[reciter] == true
                    ? () => audioController.changeReciter(reciter)
                    : null,
                enabled: _reciterAvailability[reciter] == true,
              ),
            ))),
      ],
    );
  }

  Widget _buildReciterIcon(String reciter, Color color) {
    if (_checkingAvailability[reciter] == true) {
      return SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
      );
    }

    final isAvailable = _reciterAvailability[reciter] == true;
    return Icon(
      isAvailable ? Icons.person : Icons.person_off,
      color: isAvailable ? color : Colors.grey,
      size: 20,
    );
  }

  Widget _buildAvailabilityIndicator(String reciter) {
    if (_checkingAvailability[reciter] == true) {
      return const SizedBox(
        width: 16,
        height: 16,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }

    final isAvailable = _reciterAvailability[reciter];
    if (isAvailable == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: isAvailable ? Colors.green : Colors.red,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        isAvailable ? 'متاح' : 'غير متاح',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget? _buildReciterSubtitle(String reciter) {
    final isAvailable = _reciterAvailability[reciter];

    if (_checkingAvailability[reciter] == true) {
      return const Text(
        'جاري فحص التوفر...',
        style: TextStyle(fontSize: 12, color: Colors.orange),
      );
    }

    if (isAvailable == false) {
      return const Text(
        'غير متاح حالياً - تحقق من الاتصال',
        style: TextStyle(fontSize: 12, color: Colors.red),
      );
    }

    if (isAvailable == true) {
      return Text(
        _getReciterDescription(reciter),
        style: const TextStyle(fontSize: 12, color: Colors.green),
      );
    }

    return null;
  }

  String _getReciterDescription(String reciter) {
    switch (reciter) {
      case 'كريم منصوري':
        return 'قارئ شيعي مشهور - صوت جميل';
      case 'ميثم التمار':
        return 'قارئ شيعي معروف - تلاوة مؤثرة';
      case 'باسم الكربلائي':
        return 'قارئ شيعي - أسلوب مميز';
      case 'محمد صديق المنشاوي':
        return 'قارئ مصري مشهور - تلاوة كلاسيكية';
      case 'محمود خليل الحصري':
        return 'قارئ مصري معروف - صوت واضح';
      default:
        return 'قارئ متاح';
    }
  }
}
