import 'package:flutter/material.dart';
import 'package:dotted_border/dotted_border.dart';

class DottedButton extends StatelessWidget {
  final String text;
  final bool loading;
  final VoidCallback onPressed;

  const DottedButton(
      {super.key,
      required this.text,
      required this.onPressed,
      required this.loading});

  @override
  Widget build(BuildContext context) {
    return DottedBorder(
      color: Color(0xFF858597),
      strokeWidth: 1,
      dashPattern: [3, 2],
      borderType: BorderType.RRect,
      radius: const Radius.circular(12),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          alignment: Alignment.center,
          width: 121,
          padding: const EdgeInsets.only(top: 8, bottom: 8, left: 6, right: 20),
          child: loading
              ? CircularProgressIndicator(
                  color: Theme.of(context).primaryColor,
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(
                      Icons.attach_file_rounded,
                      size: 20,
                    ),
                    Text(
                      text,
                      style: const TextStyle(color: Colors.black, fontSize: 14),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
