// lib/ui/views/head/components/assign_new_task_card.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:squareone_admin/ui/component/buttons.dart';

import '../views/home/head/head_home/head_home_controller.dart';



class AssignNewTaskCard extends StatelessWidget {
  final HeadHomeController controller;
  final double height;
  final double width;
  final String title;
  final String? subTitle;
  final VoidCallback function;
  const AssignNewTaskCard({
    super.key,
    required this.controller,
    required this.height,
    required this.width, required this.title, this.subTitle, required this.function,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: SizedBox(
        height: height * 0.11,
        child: GestureDetector(
          onTap: function,
          child: Card(
            surfaceTintColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 5,
            shadowColor: Colors.black.withOpacity(0.65),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        this.title,
                        style: const TextStyle(
                          fontSize: 15,
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if(subTitle != null)...[
                      const SizedBox(height: 4),
                      Text(
                        subTitle!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      ],
                    ],
                  ),
                ),

                AddButton(height: height, width: width)
              ],
            ),
          ),
        ),
      ),
    );
  }
}

