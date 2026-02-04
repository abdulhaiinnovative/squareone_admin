import 'package:flutter/material.dart';

import 'buttons.dart';

class NotificationsTile extends StatelessWidget {
  const NotificationsTile({
    Key? key,
    required this.text,
    required this.width,
    required this.height,
    required this.date,
  }) : super(key: key);

  final double width;
  final double height;
  final String? text;
  final String? date;
  static const IconData time = IconData(0xee2d, fontFamily: 'MaterialIcons');

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: SizedBox(
        width: width / 1.1,
        height: height / 8.3,
        child: Card(
          surfaceTintColor: Colors.transparent,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 10,
          child: Padding(
            padding: const EdgeInsets.all(18.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  children: [
                    const NotificationsButton(),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: width * 0.6,
                          child: Text(
                            text!,
                            overflow: TextOverflow.fade,
                            softWrap: false,
                          ),
                        ),
                        Row(
                          children: [
                            const Icon(
                              time,
                              color: Color(0xFFB8B8D2),
                              size: 12,
                            ),
                            Text(
                              date!.toString(),
                              style: const TextStyle(color: Color(0xFFB8B8D2)),
                            )
                          ],
                        )
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
