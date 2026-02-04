import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import 'colors.dart';

class DepartmentTile extends StatelessWidget {
  const DepartmentTile(
      {super.key,
      required this.width,
      required this.height,
      required this.title,
      required this.imgUrl,
      required this.header,
      this.status = "Open"});

  final double width;
  final String title;
  final String imgUrl;
  final double height;
  final String header;
  final String status;

  @override
  Widget build(BuildContext context) {

    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('Tickets')
            .where('header', isEqualTo: header)
            .where('Status', isEqualTo: status)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          return !snapshot.hasData
              ? const Center(
                  child: CircularProgressIndicator(
                    color: Colors.red,
                  ),
                )
              : SizedBox(
                  width: width / 2.22,
                  height: height / 1,
                  child: Card(
                      
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 12,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(''),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const SizedBox(width: 10),
                              CircleAvatar(
                                radius: height * 0.02,
                                backgroundColor: redColor,
                                child: SizedBox(
                                  width: height * 0.02,
                                  height: height * 0.02,
                                  child: SvgPicture.asset(
                                    imgUrl,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                              Container(
                                margin: const EdgeInsets.only(left: 3),
                                width: width * 0.28,
                                child: Text(title,
                                    style: const TextStyle(
                                        fontSize: 13,
                                        color: Colors.black,
                                        fontWeight: FontWeight.w500)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 7),
                          const Text(
                            '    Total Active Tickets',
                            style: TextStyle(
                              color: greyTextColor,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Text(
                              '   ${snapshot.data!.docs.length}',
                              style: TextStyle(
                                  color: snapshot.data!.docs.isEmpty
                                      ? Colors.black
                                      : Colors.red,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w400),
                            ),
                          ),
                        ],
                      )),
                );
        });
  }
}
