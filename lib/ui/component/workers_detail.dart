import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'buttons.dart';
import 'colors.dart';

class TicketWorkerTile extends StatelessWidget {
  const TicketWorkerTile({
    super.key,
    required this.workers,
    required this.width,
    required this.height,
    required this.email,
  });

  final List workers;
  final String email;

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '  Workers',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Container(
          margin: const EdgeInsets.only(top: 10),
          child: ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: workers.length,
              itemBuilder: (context, index) {
                return Container(
                    width: width,
                    height: height * .11,
                    decoration:
                        BoxDecoration(borderRadius: BorderRadius.circular(12)),
                    child: StreamBuilder(
                        stream: FirebaseFirestore.instance
                            .collection('Outlets/$email/workers')
                            .where('Name', isEqualTo: workers[index])
                            .snapshots(),
                        builder:
                            (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                          if (!snapshot.hasData) {
                            return const Center(
                                child:
                                    CircularProgressIndicator(color: redColor));
                          } else {
                            return Card(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              elevation: 10,
                              child: ListTile(
                                leading: const WorkerButton(),
                                title: Text(workers[index]),
                                subtitle:
                                    Text(snapshot.data!.docs[0]['CNIC Number']),
                                trailing:
                                    Text(snapshot.data!.docs[0]['Contact']),
                              ),
                            );
                          }
                        }));
              }),
        ),
      ],
    );
  }
}
