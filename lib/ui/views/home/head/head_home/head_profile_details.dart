import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:squareone_admin/ui/component/buttons.dart';

import '../../../../component/colors.dart';
import '../../../../component/profile_card.dart';

class HeadProfileDetails extends StatelessWidget {
  const HeadProfileDetails({super.key});

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: ButtonBack(height: height, width: width),
        title: const Text(
          'Profile Details',
          style: TextStyle(color: Colors.black),
        ),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          children: [
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

            SizedBox(height: height * 0.02),

            const Center(
              child: Text(
                'Personal Information',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            SizedBox(height: height * 0.02),

            /// 👇 Profile Cards (Static UI Only)

            FutureBuilder(
              future: FirebaseFirestore.instance
                  .collection('personnel')
                  .where(
                    'email',
                    isEqualTo: FirebaseAuth.instance.currentUser!.email,
                  )
                  .get(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) {
                  return const CircularProgressIndicator(
                    color: redColor,
                  );
                }

                if (snapshot.data!.docs.isEmpty) {
                  return const Text("User not found");
                }

                final data =
                    snapshot.data!.docs.first.data() as Map<String, dynamic>;

                return Column(
                  children: [
                    MyProfileCards(
                      height: height,
                      width: width,
                      text: data['name'] ?? '',
                      imgUrl: profileCardImages[0],
                      function: () {},
                    ),
                    MyProfileCards(
                      height: height,
                      width: width,
                      text: data['phone'] ?? '',
                      imgUrl: profileCardImages[1],
                      function: () {},
                    ),
                    MyProfileCards(
                      height: height,
                      width: width,
                      text: data['email'] ?? '',
                      imgUrl: profileCardImages[2],
                      function: () {},
                    ),
                  ],
                );
              },
            )
          ],
        ),
      ),
    );
  }
}
