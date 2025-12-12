import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/prayer_times_model.dart';

class PrayerTimesDialog extends StatefulWidget {
  final PrayerTimesModel prayerTimes;

  const PrayerTimesDialog({super.key, required this.prayerTimes});

  @override
  State<PrayerTimesDialog> createState() => _PrayerTimesDialogState();
}

class _PrayerTimesDialogState extends State<PrayerTimesDialog>
    with TickerProviderStateMixin {
  bool isAdhanEnabled = true;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _loadAdhanSettings();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadAdhanSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isAdhanEnabled = prefs.getBool('adhan_enabled') ?? true;
    });
  }

  Future<void> _toggleAdhan() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isAdhanEnabled = !isAdhanEnabled;
    });
    await prefs.setBool('adhan_enabled', isAdhanEnabled);

    Get.snackbar(
      isAdhanEnabled ? 'تم التفعيل' : 'تم الإلغاء',
      isAdhanEnabled ? 'تم تفعيل الأذان للصلوات' : 'تم إلغاء الأذان للصلوات',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: isAdhanEnabled ? Colors.green : Colors.orange,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF2E7D32),
                    Color(0xFF4CAF50),
                    Color(0xFF66BB6A),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.access_time,
                            color: Colors.white, size: 28),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'أوقات الصلاة',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                widget.prayerTimes.location,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Prayer Times List
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        _buildPrayerTimeRow(
                          'الفجر',
                          widget.prayerTimes.fajr,
                          Icons.wb_twilight,
                        ),
                        _buildDivider(),
                        _buildPrayerTimeRow(
                          'الشروق',
                          widget.prayerTimes.sunrise,
                          Icons.wb_sunny,
                        ),
                        _buildDivider(),
                        _buildPrayerTimeRow(
                          'الظهر',
                          widget.prayerTimes.dhuhr,
                          Icons.wb_sunny_outlined,
                        ),
                        _buildDivider(),
                        _buildPrayerTimeRow(
                          'الغروب',
                          widget.prayerTimes.sunset,
                          Icons.wb_twilight_outlined,
                        ),
                        _buildDivider(),
                        _buildPrayerTimeRow(
                          'المغرب',
                          widget.prayerTimes.maghrib,
                          Icons.nights_stay,
                        ),
                        _buildDivider(),
                        _buildPrayerTimeRow(
                          'منتصف الليل',
                          widget.prayerTimes.midnight,
                          Icons.bedtime,
                        ),
                      ],
                    ),
                  ),

                  // Adhan Toggle Button
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.volume_up,
                            color: Colors.white, size: 24),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'الأذان للصلوات',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: _toggleAdhan,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            width: 60,
                            height: 30,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              color: isAdhanEnabled
                                  ? Colors.white
                                  : Colors.white.withOpacity(0.3),
                            ),
                            child: Stack(
                              children: [
                                AnimatedPositioned(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                  left: isAdhanEnabled ? 30 : 0,
                                  child: Container(
                                    width: 30,
                                    height: 30,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: isAdhanEnabled
                                          ? const Color(0xFF2E7D32)
                                          : Colors.grey,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.2),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Icon(
                                      isAdhanEnabled
                                          ? Icons.volume_up
                                          : Icons.volume_off,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Date
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      widget.prayerTimes.date,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPrayerTimeRow(String prayerName, String time, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              prayerName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              time,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                fontFamily: 'monospace',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      height: 1,
      color: Colors.white.withOpacity(0.1),
    );
  }
}

// دالة مساعدة لإظهار المنبثقة
void showPrayerTimesDialog(BuildContext context, PrayerTimesModel prayerTimes) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (context) => PrayerTimesDialog(prayerTimes: prayerTimes),
  );
}
