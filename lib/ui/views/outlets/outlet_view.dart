import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:squareone_admin/ui/component/colors.dart';
import 'package:squareone_admin/ui/views/outlets/outlet_profile.dart';

import '../../component/buttons.dart';

class OutletView extends StatelessWidget {
  const OutletView({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: ButtonBack(height: height, width: width),
        title: const Text(
          ' Outlets',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500),
        ),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('Outlets').snapshots(),
        builder: (context, snapshot) {
          return !snapshot.hasData
              ? const Center(
                  child: CircularProgressIndicator(color: redColor),
                )
              : ListView.builder(
                  scrollDirection: Axis.vertical,
                  padding: const EdgeInsets.only(top: 10, left: 10, right: 10),
                  shrinkWrap: true,
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    return SizedBox(
                      width: width / 1.1,
                      height: height / 7,
                      child: InkWell(
                        onTap: () => Get.to(() => OutletProfileView(
                              email: snapshot.data!.docs[index]['Email'],
                              name: snapshot.data!.docs[index]['Outlet Name'],
                              depart: snapshot.data!.docs[index]['POC'],
                              token: snapshot.data!.docs[index]['token'],
                              password: snapshot.data!.docs[index]['Password'],
                              number: snapshot.data!.docs[index]
                                  ['Contact Number'],
                              status: snapshot.data!.docs[index]['status'] ==
                                      "Deleted"
                                  ? false
                                  : true,
                            )),
                        child: Card(
                          surfaceTintColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                          elevation: 10,
                          child: Padding(
                            padding: const EdgeInsets.all(18.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Row(
                                  children: [
                                    const OutletButton(),
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          width: width * 0.6,
                                          child: Text(
                                            snapshot.data!.docs[index]
                                                ['Outlet Name'],
                                            style: const TextStyle(
                                              fontSize: 16,
                                            ),
                                            overflow: TextOverflow.fade,
                                            softWrap: false,
                                          ),
                                        ),
                                        Text(
                                          snapshot.data!.docs[index]['Email'],
                                          style: const TextStyle(
                                              color: Color(0xFFB8B8D2)),
                                        )
                                      ],
                                    ),
                                  ],
                                ),
                                snapshot.data?.docs[index]['status'] ==
                                        "Deleted"
                                    ? Container(
                                        width: 80,
                                        height: 20,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                            color: bgRedColor,
                                            borderRadius:
                                                BorderRadius.circular(5)),
                                        child: const Text(
                                          'Deleted',
                                          style: TextStyle(
                                              color: textRedColor,
                                              fontSize: 10),
                                        ),
                                      )
                                    : const SizedBox(height: 0),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  });
        },
      ),
    );
  }
}
