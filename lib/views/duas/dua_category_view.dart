import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shia_book/constants/app_colors.dart';
import 'package:shia_book/models/dua_model.dart';
import 'package:shia_book/views/duas/dua_detail_view.dart';
import 'package:velocity_x/velocity_x.dart';

class DuaCategoryView extends StatelessWidget {
  final DuaCategory category;

  const DuaCategoryView({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: category.title.text.xl2.bold.make(),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black87,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: category.duas.length,
        itemBuilder: (context, index) {
          final dua = category.duas[index];
          return _buildDuaCard(dua);
        },
      ).box.color(Vx.gray50).make(),
    );
  }

  Widget _buildDuaCard(Dua dua) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Get.to(() => DuaDetailView(dua: dua));
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.menu_book,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: dua.title.text.lg.bold.color(Colors.black87).make(),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.grey.shade400,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                dua.arabicText.length > 100
                    ? '${dua.arabicText.substring(0, 100)}...'
                    : dua.arabicText,
                style: const TextStyle(
                  fontSize: 16,
                  height: 1.8,
                  color: Colors.black87,
                  fontFamily: 'Amiri',
                ),
                textAlign: TextAlign.right,
              ),
              if (dua.source != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.source, size: 14, color: Colors.grey.shade600),
                    const SizedBox(width: 4),
                    Text(
                      'المصدر: ${dua.source}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ],
              if (dua.benefits != null) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.star, size: 14, color: Colors.amber),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        dua.benefits!,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
