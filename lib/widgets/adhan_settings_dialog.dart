import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/adhan_service.dart';

class AdhanSettingsDialog extends StatefulWidget {
  const AdhanSettingsDialog({super.key});

  @override
  State<AdhanSettingsDialog> createState() => _AdhanSettingsDialogState();
}

class _AdhanSettingsDialogState extends State<AdhanSettingsDialog> {
  bool adhanEnabled = true;
  bool fajrEnabled = true;
  bool dhuhrEnabled = true;
  bool maghribEnabled = true;
  double volume = 0.8;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final settings = await AdhanService.getAdhanSettings();
    setState(() {
      adhanEnabled = settings['enabled'];
      volume = settings['volume'];
      fajrEnabled = settings['fajr'];
      dhuhrEnabled = settings['dhuhr'];
      maghribEnabled = settings['maghrib'];
      isLoading = false;
    });
  }

  Future<void> _saveSettings() async {
    await AdhanService.updateAdhanSettings(
      enabled: adhanEnabled,
      volume: volume,
      fajrEnabled: fajrEnabled,
      dhuhrEnabled: dhuhrEnabled,
      maghribEnabled: maghribEnabled,
    );

    Get.snackbar(
      'تم الحفظ',
      'تم حفظ إعدادات الأذان بنجاح',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final maxHeight = screenHeight * 0.85; // 85% من ارتفاع الشاشة

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: maxHeight,
          maxWidth: 400,
        ),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF2E7D32), Color(0xFF4CAF50)],
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
            // Header - ثابت
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.volume_up, color: Colors.white, size: 24),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'إعدادات الأذان - المذهب الجعفري',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon:
                        const Icon(Icons.close, color: Colors.white, size: 20),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),

            // المحتوى القابل للتمرير
            Flexible(
              child: isLoading
                  ? const Padding(
                      padding: EdgeInsets.all(40),
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          // تفعيل الأذان العام
                          _buildSettingTile(
                            'تفعيل الأذان',
                            'تشغيل الأذان في أوقات الصلاة',
                            Icons.notifications_active,
                            Switch(
                              value: adhanEnabled,
                              onChanged: (value) {
                                setState(() {
                                  adhanEnabled = value;
                                });
                              },
                              activeColor: Colors.white,
                              activeTrackColor: Colors.white.withOpacity(0.3),
                            ),
                          ),

                          if (adhanEnabled) ...[
                            const SizedBox(height: 12),

                            // مستوى الصوت
                            _buildVolumeControl(),

                            const SizedBox(height: 12),

                            // أذان الفجر
                            _buildSettingTile(
                              'أذان الفجر',
                              'تشغيل الأذان عند صلاة الفجر',
                              Icons.wb_sunny_outlined,
                              Switch(
                                value: fajrEnabled,
                                onChanged: (value) {
                                  setState(() {
                                    fajrEnabled = value;
                                  });
                                },
                                activeColor: Colors.white,
                                activeTrackColor: Colors.white.withOpacity(0.3),
                              ),
                            ),

                            const SizedBox(height: 8),

                            // أذان الظهر
                            _buildSettingTile(
                              'أذان الظهر',
                              'تشغيل الأذان عند صلاة الظهر',
                              Icons.wb_sunny,
                              Switch(
                                value: dhuhrEnabled,
                                onChanged: (value) {
                                  setState(() {
                                    dhuhrEnabled = value;
                                  });
                                },
                                activeColor: Colors.white,
                                activeTrackColor: Colors.white.withOpacity(0.3),
                              ),
                            ),

                            const SizedBox(height: 8),

                            // أذان المغرب
                            _buildSettingTile(
                              'أذان المغرب',
                              'تشغيل الأذان عند صلاة المغرب',
                              Icons.nights_stay,
                              Switch(
                                value: maghribEnabled,
                                onChanged: (value) {
                                  setState(() {
                                    maghribEnabled = value;
                                  });
                                },
                                activeColor: Colors.white,
                                activeTrackColor: Colors.white.withOpacity(0.3),
                              ),
                            ),

                            const SizedBox(height: 12),

                            // أزرار التجربة
                            Row(
                              children: [
                                Expanded(child: _buildTestButton()),
                                const SizedBox(width: 8),
                                Expanded(child: _buildTestNotificationButton()),
                              ],
                            ),
                          ],

                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
            ),

            // أزرار الحفظ والإلغاء - ثابتة في الأسفل
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius:
                    const BorderRadius.vertical(bottom: Radius.circular(20)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white.withOpacity(0.2),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                      ),
                      child: const Text('إلغاء'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        await _saveSettings();
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF2E7D32),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 2,
                      ),
                      child: const Text('حفظ'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingTile(
    String title,
    String subtitle,
    IconData icon,
    Widget trailing,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          trailing,
        ],
      ),
    );
  }

  Widget _buildVolumeControl() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.volume_up, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              const Text(
                'مستوى الصوت',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Text(
                '${(volume * 100).round()}%',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: Colors.white,
              inactiveTrackColor: Colors.white.withOpacity(0.3),
              thumbColor: Colors.white,
              overlayColor: Colors.white.withOpacity(0.2),
              trackHeight: 3,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
            ),
            child: Slider(
              value: volume,
              min: 0.0,
              max: 1.0,
              divisions: 10,
              onChanged: (value) {
                setState(() {
                  volume = value;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTestButton() {
    return ElevatedButton.icon(
      onPressed: () async {
        Get.dialog(
          const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          barrierDismissible: false,
        );

        try {
          await AdhanService.testAdhan();
          Get.back();

          Get.snackbar(
            'تجربة الأذان',
            'تم تشغيل الأذان بنجاح',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white,
            duration: const Duration(seconds: 2),
          );
        } catch (e) {
          Get.back();

          Get.snackbar(
            'خطأ',
            'فشل في تشغيل الأذان',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      },
      icon: const Icon(Icons.play_arrow, size: 16),
      label: const Text('تجربة الأذان', style: TextStyle(fontSize: 12)),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white.withOpacity(0.2),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        elevation: 0,
      ),
    );
  }

  Widget _buildTestNotificationButton() {
    return ElevatedButton.icon(
      onPressed: () async {
        try {
          await AdhanService.scheduleTestNotification();

          Get.snackbar(
            'تجربة الإشعار',
            'تم إرسال إشعار تجريبي',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.blue,
            colorText: Colors.white,
            duration: const Duration(seconds: 2),
          );
        } catch (e) {
          Get.snackbar(
            'خطأ',
            'فشل في إرسال الإشعار',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      },
      icon: const Icon(Icons.notifications, size: 16),
      label: const Text('تجربة الإشعار', style: TextStyle(fontSize: 12)),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue.withOpacity(0.3),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        elevation: 0,
      ),
    );
  }
}

// دالة لإظهار المنبثقة
void showAdhanSettingsDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (context) => const AdhanSettingsDialog(),
  );
}
