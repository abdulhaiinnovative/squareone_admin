import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:squareone_admin/ui/component/colors.dart';
import 'package:squareone_admin/ui/views/auth/auth_controller.dart';
import 'package:squareone_admin/ui/views/department/department_view.dart';
import 'package:squareone_admin/ui/views/home/head/head_home/head_home_controller.dart';
import 'package:squareone_admin/ui/views/home/head/head_home/head_profile_details.dart';
import 'package:squareone_admin/ui/views/outlets/outlet_view.dart';
import 'package:squareone_admin/ui/views/profile/my_profile_view.dart';
import 'package:squareone_admin/ui/views/profile/profile_controller.dart';
import 'package:squareone_admin/ui/views/tickets/dismissed_tickets.dart';
import 'package:squareone_admin/ui/views/tickets/tickets_list.dart';
import '../../../../component/profile_card.dart';
import '../../../team_availability_dashboard.dart';
import '../../../tickets/head_ticket/head_view_tickets.dart';
import '../admin_home/cards/department_list_view.dart';
import '../admin_home/cards/heads_list_view.dart';

class HeadProfileView extends StatelessWidget {
  const HeadProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    final controller = Get.find<HeadHomeController>();
    final authController = Get.put(LoginController());

    return Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Stack(
            children: [
              Column(
                children: [
                  Container(
                    width: width,
                    height: height / 4,
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/home/DSC_8735.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: Obx(() => Container(
                      color: Colors.black.withOpacity(0.6),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
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
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [

                                  Text(controller.currentUserName.value,style: TextStyle(color: Colors.white),),
                                  Text(
                                    controller.currentUserRole.value,
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 14,
                                    ),
                                  ),


                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    )),
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 20, left: 23),
                      child: Text(
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
                        text: 'Active Tickets',
                        imgUrl: 'assets/profile/profile.svg',
                        function: () {
                          Get.to(() => HeadViewTickets(),
                              arguments: {'title': 'Active Tickets'});
                        },
                      ),
                    ),
                    Padding(
                      padding:
                          const EdgeInsets.only(top: 10, right: 12, left: 12),
                      child: MyProfileCards(
                        height: height,
                        width: width,
                        text: 'Pending Approvals',
                        imgUrl: 'assets/profile/profile.svg',
                        function: () {
                          Get.to(() => HeadViewTickets(),
                              arguments: {'title': 'Pending Approval'});
                        },
                      ),
                    ),
                    Padding(
                      padding:
                          const EdgeInsets.only(top: 10, right: 12, left: 12),
                      child: MyProfileCards(
                        height: height,
                        width: width,
                        text: 'OnShift Employees',
                        imgUrl: 'assets/profile/profile.svg',
                        function: () {
                          Get.to(() => TeamAvailabilityDashboard());
                        },
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(top: 20, left: 23),
                      child: Text(
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
                          Get.to(() => const HeadProfileDetails());
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
                        function: () {
                          authController.logout();
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ));
  }
}
