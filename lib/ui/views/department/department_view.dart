import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../component/buttons.dart';
import '../../component/colors.dart';
import '../profile/depart_profile.dart';

class DepartmentView extends StatelessWidget {
  const DepartmentView({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: ButtonBack(height: height, width: width),
        title: const Text(
          ' Department Members',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500),
        ),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
      ),
      body: StreamBuilder(
        stream:
            FirebaseFirestore.instance.collection('Depart Members').snapshots(),
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
                      child: InkWell(
                        onTap: () => Get.to(() => DepartProfileView(
                              email: snapshot.data!.docs[index]['Email'],
                              name: snapshot.data!.docs[index]['Name'],
                              depart: snapshot.data!.docs[index]['Department'],
                              number: snapshot.data!.docs[index]
                                  ['Contact Number'],
                            )),
                        child: Card(
                      surfaceTintColor: Colors.transparent,

                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                          elevation: 10,
                          child: Padding(
                            padding: const EdgeInsets.all(18.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const DepartButton(),
                                Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      width: width * 0.57,
                                      child: Text(
                                        snapshot.data!.docs[index]['Name'],
                                        style: const TextStyle(
                                          fontSize: 16,
                                        ),
                                        overflow: TextOverflow.fade,
                                        softWrap: false,
                                      ),
                                    ),
                                    Text(
                                      snapshot.data!.docs[index]['Department'],
                                      style: const TextStyle(
                                          color: Color(0xFFB8B8D2)),
                                    ),
                                  ],
                                ),
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
