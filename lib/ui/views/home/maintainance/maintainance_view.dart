import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../component/colors.dart';
import '../../../component/department_tile.dart';
import '../../tickets/view_ticekts.dart';
import '../home_controller.dart';

class MaintainanceView extends StatelessWidget {
  const MaintainanceView({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
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
                  color: Colors.black.withOpacity(0.5),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GetX<HomeController>(
                          init: Get.put<HomeController>(
                            HomeController(),
                          ),
                          builder: (HomeController controller) {
                            return Text(
                              'Hi ${controller.name.value}! Welcome to Square1 ',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white),
                            );
                          }),
                      const SizedBox(
                        width: 280,
                        child: Text(
                          '"Where Technology Meets Convenience '
                          'One Call Away from All Your Problems."',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.white),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
          Align(
            alignment: const Alignment(0, 0.6),
            child: Container(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(15),
                    topRight: Radius.circular(15)),
                color: Colors.white,
              ),
              width: width,
              height: height / 1.4,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding:
                        EdgeInsets.only(top: height * 0.03, left: width * 0.06),
                    child: const Text(
                      'Total Departments',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                        fontSize: 22,
                      ),
                    ),
                  ),
                  Expanded(
                    child: GridView.builder(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 12),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                              mainAxisSpacing: 5,
                              crossAxisSpacing: 10,
                              crossAxisCount: 2),
                      itemCount: maintainanceCardTitle.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            Get.to(
                                () => ViewTickets(
                                      status: "Open",
                                    ),
                                arguments: [
                                  maintainanceCardTitle[index],
                                  maintainanceCardHeaders[index]
                                ]);
                          },
                          child: DepartmentTile(
                            width: width,
                            height: height,
                            title: maintainanceCardTitle[index],
                            imgUrl: maintainanceCardImages[index],
                            header: maintainanceCardHeaders[index],
                            status: "Open",
                          ),
                        );
                      },
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
