import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:squareone_admin/ui/component/emergency_cards.dart';
import 'package:squareone_admin/ui/views/forms/gate_pass/gate_pass_outward._view.dart';

import '../views/forms/gate_pass/gate_pass_inward_view.dart';
import '../views/tickets/tickets_controller.dart';
import 'buttons.dart';
import 'colors.dart';

class FilterDrawer extends StatelessWidget {
  const FilterDrawer({
    super.key,
    required this.width,
    required this.height,
    this.urgentTicket = false,
  });

  final double width;
  final double height;
  final bool urgentTicket;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: GetBuilder(
          init: Get.put<TicketController>(TicketController()),
          builder: (controller) {
            return StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('Outlets')
                    .orderBy('Outlet Name', descending: false)
                    .snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) =>
                    !snapshot.hasData
                        ? const Center(
                            child: CircularProgressIndicator(color: redColor))
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              urgentTicket
                                  ? Container(
                                      margin: const EdgeInsets.only(
                                          top: 40, left: 12, right: 12),
                                      child: const Text(
                                        ' Grant Ticket',
                                        style: TextStyle(
                                            fontSize: 22,
                                            color: Colors.black,
                                            fontWeight: FontWeight.w500),
                                      ),
                                    )
                                  : const SizedBox(height: 0),
                              urgentTicket
                                  ? EmergencyCards(
                                      width: width,
                                      height: height,
                                      title: emergencyCard[0],
                                      image: emergencyCardImages[0],
                                      function: () =>
                                          Get.to(() => const GatePassInward()))
                                  : const SizedBox(height: 0),
                              urgentTicket
                                  ? EmergencyCards(
                                      width: width,
                                      height: height,
                                      title: emergencyCard[1],
                                      image: emergencyCardImages[1],
                                      function: () => Get.to(
                                          () => const GatePassOutwardView()))
                                  : const SizedBox(height: 0),
                              Container(
                                margin: urgentTicket
                                    ? const EdgeInsets.only(
                                        top: 12, left: 12, right: 12)
                                    : const EdgeInsets.only(
                                        top: 40, left: 12, right: 12),
                                child: Column(children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        ' Filter by Date',
                                        style: TextStyle(
                                            fontSize: 22,
                                            color: Colors.black,
                                            fontWeight: FontWeight.w500),
                                      ),
                                      controller.formattedDate == ""
                                          ? IconButton(
                                              onPressed: () => controller
                                                  .showPicker(context),
                                              icon: const Icon(
                                                  Icons.calendar_today),
                                            )
                                          : IconButton(
                                              onPressed: () {
                                                controller.formattedDate.value =
                                                    "";
                                              },
                                              icon: Icon(Icons.close))
                                    ],
                                  ),
                                ]),
                              ),
                              Container(
                                margin: urgentTicket
                                    ? const EdgeInsets.only(
                                        top: 12, left: 12, right: 12)
                                    : const EdgeInsets.only(
                                        top: 12, left: 12, right: 12),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      ' Outlets',
                                      style: TextStyle(
                                          fontSize: 22,
                                          color: Colors.black,
                                          fontWeight: FontWeight.w500),
                                    ),
                                    InkWell(
                                      onTap: () {
                                        controller.filter.value = "";
                                        Get.back();
                                      },
                                      child: const Text(
                                        ' Clear All  ',
                                        style: TextStyle(
                                            fontSize: 14,
                                            color: textRedColor,
                                            fontWeight: FontWeight.w500),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: ListView.builder(
                                    padding: EdgeInsets.zero,
                                    shrinkWrap: true,
                                    itemCount: snapshot.data!.docs.length,
                                    itemBuilder: (context, index) {
                                      return InkWell(
                                        onTap: () {
                                          controller.filter.value = snapshot
                                              .data!.docs[index]['Outlet Name'];
                                          Get.back();
                                        },
                                        child: Container(
                                          margin: const EdgeInsets.all(12),
                                          width: width * 0.9,
                                          height: height * 0.1,
                                          child: Card(
                                            surfaceTintColor:
                                                Colors.transparent,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(15.0),
                                            ),
                                            elevation: 12,
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceEvenly,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  const OutletButton(),
                                                  SizedBox(
                                                    width: 180,
                                                    child: Text(
                                                      "  ${snapshot.data!.docs[index]['Outlet Name']}",
                                                      style: const TextStyle(
                                                          fontSize: 15,
                                                          fontWeight:
                                                              FontWeight.w500),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    }),
                              ),
                            ],
                          ));
          }),
    );
  }
}
