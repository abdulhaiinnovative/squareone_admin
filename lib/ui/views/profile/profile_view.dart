import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:squareone_admin/ui/component/colors.dart';
import 'package:squareone_admin/ui/views/department/department_view.dart';
import 'package:squareone_admin/ui/views/outlets/outlet_view.dart';
import 'package:squareone_admin/ui/views/profile/my_profile_view.dart';
import 'package:squareone_admin/ui/views/profile/profile_controller.dart';
import 'package:squareone_admin/ui/views/tickets/dismissed_tickets.dart';
import 'package:squareone_admin/ui/views/tickets/tickets_list.dart';
import '../../component/profile_card.dart';
import '../tickets/approved_tickets.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.white,
      body: GetBuilder<ProfileController>(
          init: Get.put<ProfileController>(ProfileController()),
          builder: (controller) {
            return SingleChildScrollView(
              child: Stack(children: [
                Column(
                  children: [
                    Container(
                      width: width,
                      height: height / 4,
                      decoration: const BoxDecoration(
                          image: DecorationImage(
                              image: AssetImage('assets/home/DSC_8735.png'),
                              fit: BoxFit.cover)),
                      child: Container(
                        color: Colors.black.withOpacity(0.6),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(
                                      left: width * 0.05, right: width * 0.025),
                                  child: const CircleAvatar(
                                    radius: 20,
                                    backgroundColor: Colors.transparent,
                                    backgroundImage: AssetImage('assets/1.png'),
                                  ),
                                ),
                                Obx(() => Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          controller.name.value,
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                              fontSize: 18,
                                              color: Colors.white),
                                        ),
                                        Text(
                                          controller.depart.value,
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                              fontSize: 14,
                                              color: Colors.white),
                                        )
                                      ],
                                    ))
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                Container(
                  margin: EdgeInsets.only(top: height * 0.17),
                  width: width,
                  constraints: BoxConstraints(minHeight: height / 1.13),
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(15),
                        topRight: Radius.circular(15)),
                    color: Colors.white,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.only(top: 20, left: 23),
                        child: const Text(
                          ' My Account',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                          ),
                        ),
                      ),
                      Obx(() {
                        return ListView.builder(
                            padding: const EdgeInsets.only(
                                top: 10, right: 12, left: 12),
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: controller.index.value,
                            itemBuilder: (context, index) {
                              return MyProfileCards(
                                  height: height,
                                  width: width,
                                  text: controller.depart.value == 'CR'
                                      ? securityProfileText[index]
                                      : controller.depart.value == 'Security'
                                          ? securityProfileText[index]
                                          : controller.depart.value ==
                                                  'Maintainance'
                                              ? securityProfileText[index]
                                              : profileText[index],
                                  imgUrl: profileImg[index],
                                  function: () {
                                    switch (controller.depart.value) {
                                      case "CR":
                                      case "Security":
                                      case "Maintainance":
                                        switch (index) {
                                          case 0:
                                            Get.to(() =>
                                                const ApproveTicketList());
                                            break;
                                          case 1:
                                            Get.to(() =>
                                                const DismissedTicketsList());
                                            break;
                                        }
                                        break;
                                      default:
                                        switch (index) {
                                          case 0:
                                            Get.to(
                                                () => const OpenTicketsView());
                                            break;
                                          case 1:
                                            Get.to(() =>
                                                const ApproveTicketList());
                                            break;
                                          case 2:
                                            Get.to(() =>
                                                const DismissedTicketsList());
                                            break;

                                          case 3:
                                            Get.to(() => const OutletView());

                                            break;
                                          case 4:
                                            Get.to(
                                                () => const DepartmentView());
                                            break;
                                        }
                                    }
                                  });
                            });
                      }),
                      Container(
                        padding: const EdgeInsets.only(top: 20, left: 23),
                        child: const Text(
                          ' My Account',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                          ),
                        ),
                      ),
                      Padding(
                        padding:
                            const EdgeInsets.only(top: 10, right: 12, left: 12),
                        child: MyProfileCards(
                          height: height,
                          width: width,
                          text: 'My Profile',
                          imgUrl: 'assets/profile/profile.svg',
                          function: () {
                            Get.to(() => const MyProfileView());
                          },
                        ),
                      ),
                      Padding(
                        padding:
                            const EdgeInsets.only(top: 10, right: 12, left: 12),
                        child: MyProfileCards(
                          height: height,
                          width: width,
                          text: 'Sign Out',
                          imgUrl: 'assets/profile/log.svg',
                          function: () => controller.signOut(),
                        ),
                      ),
                    ],
                  ),
                ),
              ]),
            );
          }),
    );
  }
}
