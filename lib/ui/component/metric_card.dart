// lib/ui/views/head/components/metric_card.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'colors.dart';

class MetricCard extends StatelessWidget {
  final String title;
  final RxInt count;
  final IconData icon;
  final Color color;
  final double width;
  final double height;
  final String subtitle;
  final VoidCallback? onTap;

  const MetricCard({
    super.key,
    required this.title,
    required this.count,
    required this.icon,
    required this.color,
    required this.width,
    required this.height,
    this.subtitle = 'Total Active', this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width / 2.22,
      height: height / 1,
      child: GestureDetector(
        onTap: onTap,
        child: Card(
          elevation: 5,
          shadowColor: Colors.black.withOpacity(0.65),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(''),

              /// 🔴 Top Row (Icon + Title)
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(width: 10),
                  CircleAvatar(
                    radius: height * 0.02,
                    backgroundColor: redColor,
                    child: Icon(
                      icon,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(left: 3),
                    width: width * 0.28,
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 7),

              /// 🔹 Subtitle (same as DepartmentTile)
              Padding(
                padding: const EdgeInsets.only(left: 12),
                child: Text(
                  subtitle,
                  style: const TextStyle(
                    color: greyTextColor,
                    fontSize: 12,
                  ),
                ),
              ),

              const SizedBox(height: 5),

              /// 🔢 Count
              Padding(
                padding: const EdgeInsets.only(left: 12, bottom: 6),
                child: Obx(
                      () => Text(
                    count.value.toString(),
                    style: TextStyle(
                      color: count.value == 0 ? Colors.black : Colors.red,
                      fontSize: 20,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
