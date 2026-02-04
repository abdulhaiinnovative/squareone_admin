import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:squareone_admin/ui/views/forms/add_depart_member/add_depart_member_view.dart';
import 'package:squareone_admin/ui/views/forms/add_outlet/add_outlet_view.dart';
import 'package:squareone_admin/ui/views/home/home_controller.dart';
import 'package:squareone_admin/ui/views/tickets/view_ticekts.dart';
import '../../../component/buttons.dart';
import '../../../component/colors.dart';
import '../../../component/department_tile.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    log(context.height.toString());
    return SingleChildScrollView(
      child: Container(
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            Column(
              children: [
                Container(
                  width: width,
                  height: height / 7,
                  decoration: const BoxDecoration(
                      image: DecorationImage(
                          image: AssetImage('assets/home/DSC_8735.png'),
                          fit: BoxFit.cover)),
                  child: Container(
                    color: Colors.black.withOpacity(0.5),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Padding(
                          padding:
                              EdgeInsets.only(bottom: context.height * 0.03),
                          child: GetX<HomeController>(
                            init: Get.put<HomeController>(
                              HomeController(),
                            ),
                            builder: (HomeController controller) {
                              return Material(
                                color: Colors.transparent,
                                child: Text(
                                  'Hi ${controller.name.value}! Welcome to Square1 ',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: height < 1000 ? 15 : 22,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Column(
              children: [
                Container(
                  height: height,
                  margin: EdgeInsets.only(
                    top: height * 0.12,
                  ),
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(15),
                        topRight: Radius.circular(15)),
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            ListView(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              children: [
                SizedBox(
                  height: height * 0.08,
                ),
                GridView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 12),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        mainAxisSpacing: 0,
                        childAspectRatio: height < 700
                            ? 1.2
                            : height < 900
                                ? 1.1
                                : height < 1000
                                    ? 1.3
                                    : 1.5,
                        crossAxisSpacing: 10,
                        crossAxisCount: 2),
                    itemCount: homeCardTitle.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () => Get.to(() => ViewTickets(), arguments: [
                          homeCardTitle[index],
                          homeCardHeaders[index]
                        ]),
                        child: DepartmentTile(
                          width: width,
                          height: height,
                          title: homeCardTitle[index],
                          imgUrl: homeCardImages[index],
                          header: homeCardHeaders[index],
                        ),
                      );
                    }),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: Container(
                    height: height * 0.11,
                    child: GestureDetector(
                      onTap: () => Get.to(() => const AddOutletView()),
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        elevation: 12,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('   Add Outlet',
                                    style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.black,
                                        fontWeight: FontWeight.w500)),
                              ],
                            ),
                            AddButton(
                              height: height,
                              width: width,
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: Container(
                    height: height * 0.11,
                    child: GestureDetector(
                      onTap: () => Get.to(() => const AddDepartmentView()),
                      child: Card(
                        surfaceTintColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        elevation: 12,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('   Add Memeber',
                                    style: TextStyle(
                                        fontSize: 19,
                                        color: Colors.black,
                                        fontWeight: FontWeight.w500))
                              ],
                            ),
                            AddButton(height: height, width: width)
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
