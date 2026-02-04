import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'colors.dart';

// import 'package:squae1_admin/ui/constants/constants.dart';
class MyProfileCards extends StatelessWidget {
  const MyProfileCards(
      {Key? key,
      required this.text,
      required this.imgUrl,
      required this.function,
      required this.height,
      required this.width})
      : super(key: key);

  final double height;
  final double width;

  final String text;

  final String imgUrl;
  final VoidCallback function;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width / 1,
      height: height / 8.5,
      child: InkWell(
        onTap: function,
        child: Card(
          surfaceTintColor: Colors.transparent,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 10,
          child: Padding(
            padding: const EdgeInsets.all(14.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(right: 10),
                      decoration: BoxDecoration(
                          color: redColor,
                          borderRadius: BorderRadius.circular(12)),
                      width: 48,
                      height: 48,
                      child: Center(
                          child: SizedBox(
                        width: 22,
                        height: 22,
                        child: SvgPicture.asset(imgUrl,color: Colors.white,),
                      )),
                    ),
                    Text(
                      text,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                const SizedBox(
                  width: 30,
                  child: Icon(Icons.arrow_forward_ios_sharp),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}