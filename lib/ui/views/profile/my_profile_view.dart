import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:squareone_admin/ui/component/buttons.dart';

import '../../component/colors.dart';
import '../../component/profile_card.dart';

class MyProfileView extends StatelessWidget {
  const MyProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: ButtonBack(height: height, width: width),
        title: const Text(
          'My Profile',
          style: TextStyle(color: Colors.black),
        ),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(children: [
          Center(
            child: CircleAvatar(
              backgroundColor: Colors.black.withOpacity(0.1),
              radius: width * 0.18,
              child: CircleAvatar(
                backgroundColor: Colors.white.withOpacity(0.7),
                radius: width * 0.17,
                child: const Center(
                  child: Icon(
                    Icons.camera_alt_outlined,
                    color: Colors.black,
                    size: 30,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(
            height: height * 0.02,
          ),
          const Center(
            child: Text(
              'Personal Information',
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.w500),
            ),
          ),
          SizedBox(
            height: height * 0.01,
          ),
          FutureBuilder(
              future: FirebaseFirestore.instance
                  .collection('Depart Members')
                  .doc(FirebaseAuth.instance.currentUser!.email)
                  .get(),
              builder: (context, AsyncSnapshot snapshot) {
                return !snapshot.hasData
                    ? const CircularProgressIndicator(
                        color: redColor,
                      )
                    : Column(children: [
                        MyProfileCards(
                          height: height,
                          width: width,
                          text: snapshot.data['Name'],
                          imgUrl: profileCardImages[0],
                          function: () {},
                        ),
                        MyProfileCards(
                          height: height,
                          width: width,
                          text: snapshot.data['Contact Number'],
                          imgUrl: profileCardImages[1],
                          function: () {},
                        ),
                        MyProfileCards(
                          height: height,
                          width: width,
                          text: snapshot.data['Email'],
                          imgUrl: profileCardImages[2],
                          function: () {},
                        ),
                      ]);
              }),
        ]),
      ),
    );
  }
}
