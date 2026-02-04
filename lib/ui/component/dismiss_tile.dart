import 'package:flutter/material.dart';

class DismissTile extends StatelessWidget {
  final String? title;
  const DismissTile({
    super.key,
    required this.width,
    required this.height,
    required this.dismiss, this.title = 'dismissal',
  });

  final double width;
  final double height;
  final String dismiss;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      constraints: BoxConstraints(minHeight: height * 0.1),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
      child: Card(
                      surfaceTintColor: Colors.transparent,

        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 10,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
               Text(
                'Reason of $title',
                style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 5),
              const Divider(
                height: 1,
                thickness: 2,
              ),
              const SizedBox(height: 10),
              Text(
                dismiss,
                style: const TextStyle(
                    fontSize: 16.0, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
