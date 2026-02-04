import 'package:flutter/material.dart';

import 'colors.dart';

class NotificationInfo extends StatelessWidget {
  const NotificationInfo({
    Key? key,
    required this.size,
    required this.accessTimeOutlined,
    required this.text,
    required this.desc,
    required this.date,
    required this.onTap,
    required this.file,
  }) : super(key: key);

  final Size size;
  final String text;
  final String desc;
  final String date;
  final Map? file;
  final VoidCallback onTap;

  final IconData accessTimeOutlined;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size.width / 1,
      child: Card(
        surfaceTintColor: Colors.transparent,
        elevation: 10,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Column(
            children: [
              Column(
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
                          child: const Center(
                            child: Icon(
                              Icons.notifications_none,
                              color: Colors.white,
                              size: 25,
                            ),
                          )),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: size.width * 0.57,
                            child: Text(
                              text,
                              style: const TextStyle(fontSize: 15),
                              overflow: TextOverflow.visible,
                            ),
                          ),
                          Row(
                            children: [
                              Icon(
                                accessTimeOutlined,
                                color: const Color(0xFFB8B8D2),
                                size: 12,
                              ),
                              Text(
                                date.toString(),
                                style:
                                    const TextStyle(color: Color(0xFFB8B8D2)),
                              )
                            ],
                          ),
                        ],
                      ),
                      file != null
                          ? GestureDetector(
                              onTap: onTap,
                              child: Icon(
                                Icons.download,
                                size: 30,
                                color: Theme.of(context).primaryColor,
                              ),
                            )
                          : SizedBox()
                    ],
                  ),
                ],
              ),
              Container(
                margin: const EdgeInsets.only(top: 10),
                width: size.width / 1.2,
                child: Text(desc, style: const TextStyle(fontSize: 13.5)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
