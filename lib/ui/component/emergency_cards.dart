import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import 'colors.dart';

class EmergencyCards extends StatelessWidget {
  const EmergencyCards({
    Key? key,
    required this.width,
    required this.height,
    required this.title,
    required this.image,
    required this.function,
  }) : super(key: key);

  final double width;
  final double height;
  final String title;
  final String image;
  final void Function() function;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 12, right: 12),
      width: width,
      height: height * 0.1,
      child: InkWell(
        onTap: function,
        overlayColor: const WidgetStatePropertyAll(Colors.white),
        child: Card(
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          elevation: 12,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: redColor,
                  child: SizedBox(
                    width: 18,
                    height: 18,
                    child: SvgPicture.asset(
                      image,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                SizedBox(
                  width: 200,
                  child: Text(
                    "  $title",
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w500),
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios_outlined,
                  color: redColor,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
