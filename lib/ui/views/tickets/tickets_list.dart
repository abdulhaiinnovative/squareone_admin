import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:squareone_admin/ui/component/in_progress_tile.dart';
import 'package:squareone_admin/ui/views/tickets/tickets_controller.dart';
import '../../component/buttons.dart';
import '../../component/colors.dart';
import '../../component/dialog.dart';
import '../../component/drawer_filter.dart';
import 'details/gate_pass_detail.dart';
import 'details/non_retail_activity.dart';
import 'details/security.dart';

class OpenTicketsView extends StatelessWidget {
  const OpenTicketsView({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return GetX<TicketController>(
      init: Get.put<TicketController>(TicketController()),
      builder: (controller) {
        return Scaffold(
          backgroundColor: Colors.white,
          endDrawer:
              FilterDrawer(width: width, urgentTicket: false, height: height),
          appBar: AppBar(
            actions: [
              controller.selectionMode.value
                  ? Row(
                      children: [
                        IconButton(
                            icon: Icon(
                              Icons.delete,
                              color: Color(0xFFB71C1C),
                            ),
                            onPressed: () {
                              getDialog(
                                title: 'Delete',
                                desc: 'Are you sure?',
                                icon: Icons.delete,
                                actions: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      ElevatedButton(
                                        style: ButtonStyle(
                                          backgroundColor:
                                              MaterialStateProperty.all<Color>(
                                                  Colors.grey.shade400),
                                        ),
                                        onPressed: () {
                                          debugPrint(controller.selectedItems
                                              .toString());
                                          Get.back();
                                        },
                                        child: Text('Cancel'),
                                      ),
                                      ElevatedButton(
                                        style: ButtonStyle(
                                          backgroundColor:
                                              MaterialStateProperty.all<Color>(
                                                  Theme.of(context)
                                                      .primaryColor),
                                        ),
                                        onPressed: () async {
                                          try {
                                            // Iterate over selectedItems and update the Firestore document
                                            for (var item
                                                in controller.selectedItems) {
                                              debugPrint(item.toString());
                                              // Using await to ensure Firestore operation completes before continuing
                                              await FirebaseFirestore.instance
                                                  .collection('Tickets')
                                                  .doc(item)
                                                  .update({
                                                'Status': 'Deleted',
                                                'Reason':
                                                    'Unable to View Ticket. Please Regenerate with correct data.'
                                              });
                                              debugPrint(
                                                  'Document successfully updated!');
                                            }

                                            // Clear selection and close the dialog after all operations have completed
                                            controller.clearSelection();
                                            Get.back();
                                          } catch (error) {
                                            debugPrint(
                                                'Failed to update document: $error');
                                          }
                                        },
                                        child: Text('Delete'),
                                      ),
                                    ],
                                  ),
                                ],
                              );
                            }),
                        IconButton(
                          icon: Icon(
                            Icons.clear,
                            color: Color(0xFFB71C1C),
                          ),
                          onPressed: () {
                            controller.clearSelection();
                          },
                        ),
                      ],
                    )
                  : SizedBox.shrink(),
            ],
            automaticallyImplyLeading: true,
            backgroundColor: Colors.white,
            iconTheme: const IconThemeData(color: redColor),
            elevation: 0,
            leading: ButtonBack(
              height: height,
              width: width,
            ),
            title: Text(
              controller.selectionMode.value
                  ? "${controller.selectedItems.length} items selected"
                  : controller.filter.value == '' &&
                          controller.formattedDate.value == ''
                      ? "In Progress Tickets"
                      : controller.filter.value != '' &&
                              controller.formattedDate.value == ''
                          ? "${controller.filter.value}\'s Tickets"
                          : controller.filter.value == '' &&
                                  controller.formattedDate.value != ''
                              ? "${controller.formattedDate.value}\'s Tickets"
                              : controller.filter.value != '' &&
                                      controller.formattedDate.value != ''
                                  ? "${controller.filter.value}(${controller.formattedDate.value})"
                                  : "",
              style: const TextStyle(
                  color: Colors.black, fontWeight: FontWeight.w500),
            ),
          ),
          body: StreamBuilder(
            stream: controller.depart.value == 'Admin'
                ? controller.filter.value == '' &&
                        controller.formattedDate.value == ''
                    ? FirebaseFirestore.instance
                        .collection('Tickets')
                        .where('Status', isEqualTo: 'Open')
                        .where('Status', isNotEqualTo: 'Deleted')
                        .snapshots()
                    : controller.filter.value == '' &&
                            controller.formattedDate.value != ''
                        ? FirebaseFirestore.instance
                            .collection('Tickets')
                            .where('Status', isEqualTo: 'Open')
                            .where('Date',
                                isEqualTo: controller.formattedDate.value)
                            .where('Status', isNotEqualTo: 'Deleted')
                            .snapshots()
                        : controller.filter.value != '' &&
                                controller.formattedDate.value == ''
                            ? FirebaseFirestore.instance
                                .collection('Tickets')
                                .where('Status', isEqualTo: 'Open')
                                .where('Outlet',
                                    isEqualTo: controller.filter.value)
                                .where('Status', isNotEqualTo: 'Deleted')
                                .snapshots()
                            : controller.filter.value != "" &&
                                    controller.formattedDate.value != ""
                                ? FirebaseFirestore.instance
                                    .collection('Tickets')
                                    .where('Status', isEqualTo: 'Open')
                                    .where('Outlet',
                                        isEqualTo: controller.filter.value)
                                    .where('Date',
                                        isEqualTo:
                                            controller.formattedDate.value)
                                    .where('Status', isNotEqualTo: 'Deleted')
                                    .snapshots()
                                : FirebaseFirestore.instance
                                    .collection('Tickets')
                                    .where('Status', isEqualTo: 'Open')
                                    .where('Status', isNotEqualTo: 'Deleted')
                                    .snapshots()
                : controller.depart.value == 'Operations'
                    ? controller.filter.value == '' &&
                            controller.formattedDate.value == ''
                        ? FirebaseFirestore.instance
                            .collection('Tickets')
                            .where('Status', isEqualTo: 'Open')
                            .where('Status', isNotEqualTo: 'Deleted')
                            .snapshots()
                        : controller.filter.value == '' &&
                                controller.formattedDate.value != ''
                            ? FirebaseFirestore.instance
                                .collection('Tickets')
                                .where('Status', isEqualTo: 'Open')
                                .where('Date',
                                    isEqualTo: controller.formattedDate.value)
                                .where('Status', isNotEqualTo: 'Deleted')
                                .snapshots()
                            : controller.filter.value != '' &&
                                    controller.formattedDate.value == ''
                                ? FirebaseFirestore.instance
                                    .collection('Tickets')
                                    .where('Status', isEqualTo: 'Open')
                                    .where('Outlet',
                                        isEqualTo: controller.filter.value)
                                    .where('Status', isNotEqualTo: 'Deleted')
                                    .snapshots()
                                : controller.filter.value != "" &&
                                        controller.formattedDate.value != ""
                                    ? FirebaseFirestore.instance
                                        .collection('Tickets')
                                        .where('Status', isEqualTo: 'Open')
                                        .where('Outlet',
                                            isEqualTo: controller.filter.value)
                                        .where('Date',
                                            isEqualTo:
                                                controller.formattedDate.value)
                                        .where('Status',
                                            isNotEqualTo: 'Deleted')
                                        .snapshots()
                                    : FirebaseFirestore.instance
                                        .collection('Tickets')
                                        .where('Status', isEqualTo: 'Open')
                                        .where('Status',
                                            isNotEqualTo: 'Deleted')
                                        .snapshots()
                    : controller.depart.value == 'Food Court'
                        ? controller.filter.value == '' &&
                                controller.formattedDate.value == ''
                            ? FirebaseFirestore.instance
                                .collection('Tickets')
                                .where('Status', isEqualTo: 'Open')
                                .where("Ticket By",
                                    isEqualTo: "Food Court Outlet")
                                .where('Status', isNotEqualTo: 'Deleted')
                                .snapshots()
                            : controller.filter.value == '' &&
                                    controller.formattedDate.value != ''
                                ? FirebaseFirestore.instance
                                    .collection('Tickets')
                                    .where('Status', isEqualTo: 'Open')
                                    .where("Ticket By",
                                        isEqualTo: "Food Court Outlet")
                                    .where('Date',
                                        isEqualTo:
                                            controller.formattedDate.value)
                                    .where('Status', isNotEqualTo: 'Deleted')
                                    .snapshots()
                                : controller.filter.value != '' &&
                                        controller.formattedDate.value == ''
                                    ? FirebaseFirestore.instance
                                        .collection('Tickets')
                                        .where('Status', isEqualTo: 'Open')
                                        .where("Ticket By",
                                            isEqualTo: "Food Court Outlet")
                                        .where('Outlet',
                                            isEqualTo: controller.filter.value)
                                        .where('Status',
                                            isNotEqualTo: 'Deleted')
                                        .snapshots()
                                    : controller.filter.value != "" &&
                                            controller.formattedDate.value != ""
                                        ? FirebaseFirestore.instance
                                            .collection('Tickets')
                                            .where('Status', isEqualTo: 'Open')
                                            .where("Ticket By",
                                                isEqualTo: "Food Court Outlet")
                                            .where('Outlet',
                                                isEqualTo:
                                                    controller.filter.value)
                                            .where('Date',
                                                isEqualTo: controller
                                                    .formattedDate.value)
                                            .where('Status',
                                                isNotEqualTo: 'Deleted')
                                            .snapshots()
                                        : FirebaseFirestore.instance
                                            .collection('Tickets')
                                            .where('Status', isEqualTo: 'Open')
                                            .where("Ticket By",
                                                isEqualTo: "Food Court Outlet")
                                            .where('Status',
                                                isNotEqualTo: 'Deleted')
                                            .snapshots()
                        : FirebaseFirestore.instance
                            .collection('Tickets')
                            .where('Status', isEqualTo: 'Open')
                            .where("Ticket By", isEqualTo: "Food Court Outlet")
                            .where('Department',
                                isEqualTo: controller.depart.value)
                            .where('Status', isNotEqualTo: 'Deleted')
                            .snapshots(),
            builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
              return !snapshot.hasData
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: redColor,
                      ),
                    )
                  : ListView.builder(
                      scrollDirection: Axis.vertical,
                      itemCount: snapshot.data!.docs.length,
                      padding:
                          const EdgeInsets.only(top: 10, left: 10, right: 10),
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        var doc = snapshot.data!.docs[index];
                        var docId = doc.id;
                        log(docId);
                        var isSelected =
                            controller.selectedItems.contains(docId);
                        switch (snapshot.data!.docs[index]['header']) {
                          case 'Gate-Pass-Outwards(Retail Outlet)':
                          return GestureDetector(
                            onLongPress: () {
                            controller.enableSelectionMode(docId);
                            },
                            onTap: () {
                            if (controller.selectionMode.value) {
                              controller.toggleSelection(docId);
                            } else {
                              Get.to(() => GateInwardDetails(
                                ticketId: snapshot
                                  .data!.docs[index]['Ticket Number'],
                                inProgress: true,
                                ));
                            }
                            },
                            child: Stack(children: [
                            InProgressTicketTile(
                              outletName: snapshot.data!.docs[index]
                                ["Outlet"],
                              text: snapshot.data!.docs[index]
                                ['header'],
                              width: width,
                              height: height,
                              header: 'Quantity: ',
                              headerText:
                                '${snapshot.data!.docs[index]['Quantity']} PC'),
                            Container(
                              padding: EdgeInsets.all(18),
                              width: width / 1.1,
                              height: height / 6.8,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: isSelected
                                  ? Colors.red.withOpacity(0.25)
                                  : Colors.transparent,
                              )),
                            ]),
                          );
                          case 'Gate-Pass-Inward(Retail Outlet)':
                          return GestureDetector(
                            onLongPress: () {
                            controller.enableSelectionMode(docId);
                            },
                            onTap: () {
                            if (controller.selectionMode.value) {
                              controller.toggleSelection(docId);
                            } else {
                              Get.to(() => GateInwardDetails(
                                ticketId: snapshot
                                  .data!.docs[index]['Ticket Number'],
                                inProgress: true,
                                ));
                            }
                            },
                            child: Stack(
                            children: [
                              InProgressTicketTile(
                                outletName: snapshot
                                  .data!.docs[index]["Outlet"],
                                text: snapshot.data!.docs[index]
                                  ['header'],
                                width: width,
                                height: height,
                                header: 'Quantity: ',
                                headerText:
                                  '${snapshot.data!.docs[index]['Quantity']} PC'),
                              Container(
                                padding: EdgeInsets.all(18),
                                width: width / 1.1,
                                height: height / 6.8,
                                decoration: BoxDecoration(
                                  borderRadius:
                                    BorderRadius.circular(20),
                                  color: isSelected
                                    ? Colors.red.withOpacity(0.25)
                                    : Colors.transparent)),
                            ],
                            ),
                          );
                          case 'Non-Retail-Hour-Activity(Retail Outlet)':
                          return GestureDetector(
                            onLongPress: () {
                              controller.enableSelectionMode(docId);
                            },
                            onTap: () {
                              if (controller.selectionMode.value) {
                              controller.toggleSelection(docId);
                              } else {
                              Get.to(
                                () => NonRentalActivity(
                                ticketId: snapshot
                                  .data!.docs[index]['Ticket Number'],
                                inProgress: true,
                                ),
                              );
                              }
                            },
                            child: Stack(children: [
                              InProgressTicketTile(
                              outletName: snapshot.data!.docs[index]
                                ["Outlet"],
                              text: snapshot.data!.docs[index]
                                ['header'],
                              width: width,
                              height: height,
                              header: 'Activity: ',
                              headerText: snapshot.data!.docs[index]
                                ['Activity'],
                              ),
                              Container(
                                padding: EdgeInsets.all(18),
                                width: width / 1.1,
                                height: height / 6.8,
                                decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: isSelected
                                  ? Colors.red.withOpacity(0.25)
                                  : Colors.transparent,
                                )),
                            ]));
                          case 'Maintainance(Retail Outlet)':
                          return GestureDetector(
                            onLongPress: () {
                            controller.enableSelectionMode(docId);
                            },
                            onTap: () {
                            if (controller.selectionMode.value) {
                              controller.toggleSelection(docId);
                            } else {
                              Get.to(() => SecurityTicektDetails(
                                ticketId: snapshot
                                  .data!.docs[index]['Ticket Number'],
                                inProgress: true,
                                ));
                            }
                            },
                            child: Stack(
                            children: [
                              InProgressTicketTile(
                                outletName: snapshot
                                  .data!.docs[index]["Outlet"],
                                text: snapshot.data!.docs[index]
                                  ['header'],
                                width: width,
                                height: height,
                                header: 'Activity: ',
                                headerText: snapshot
                                  .data!.docs[index]['Activity']),
                              Container(
                                padding: EdgeInsets.all(18),
                                width: width / 1.1,
                                height: height / 6.8,
                                decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: isSelected
                                  ? Colors.red.withOpacity(0.25)
                                  : Colors.transparent,
                                )),
                            ],
                            ),
                          );
                          case 'Gate-Pass-Outwards(Food Court Outlet)':
                          return GestureDetector(
                            onLongPress: () {
                            controller.enableSelectionMode(docId);
                            },
                            onTap: () {
                            if (controller.selectionMode.value) {
                              controller.toggleSelection(docId);
                            } else {
                              Get.to(() => GateInwardDetails(
                                ticketId: snapshot
                                  .data!.docs[index]['Ticket Number'],
                                inProgress: true,
                                ));
                            }
                            },
                            child: Stack(
                            children: [
                              InProgressTicketTile(
                                outletName: snapshot
                                  .data!.docs[index]["Outlet"],
                                text: snapshot.data!.docs[index]
                                  ['header'],
                                width: width,
                                height: height,
                                header: 'Quantity: ',
                                headerText:
                                  '${snapshot.data!.docs[index]['Quantity']} PC'),
                              Container(
                                padding: EdgeInsets.all(18),
                                width: width / 1.1,
                                height: height / 6.8,
                                decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: isSelected
                                  ? Colors.red.withOpacity(0.25)
                                  : Colors.transparent,
                                )),
                            ],
                            ),
                          );
                          case 'Gate-Pass-Inward(Food Court Outlet)':
                          return GestureDetector(
                            onLongPress: () {
                            controller.enableSelectionMode(docId);
                            },
                            onTap: () {
                            if (controller.selectionMode.value) {
                              controller.toggleSelection(docId);
                            } else {
                              Get.to(() => GateInwardDetails(
                                ticketId: snapshot
                                  .data!.docs[index]['Ticket Number'],
                                inProgress: true,
                                ));
                            }
                            },
                            child: Stack(
                            children: [
                              InProgressTicketTile(
                                outletName: snapshot
                                  .data!.docs[index]["Outlet"],
                                text: snapshot.data!.docs[index]
                                  ['header'],
                                width: width,
                                height: height,
                                header: 'Quantity: ',
                                headerText:
                                  '${snapshot.data!.docs[index]['Quantity']} PC'),
                              Container(
                                padding: EdgeInsets.all(18),
                                width: width / 1.1,
                                height: height / 6.8,
                                decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: isSelected
                                  ? Colors.red.withOpacity(0.25)
                                  : Colors.transparent,
                                )),
                            ],
                            ),
                          );
                          case 'Non-Retail-Hour-Activity(Food Court Outlet)':
                          return GestureDetector(
                            onLongPress: () {
                            controller.enableSelectionMode(docId);
                            },
                            onTap: () {
                            if (controller.selectionMode.value) {
                              controller.toggleSelection(docId);
                            } else {
                              Get.to(
                              () => NonRentalActivity(
                                ticketId: snapshot.data!.docs[index]
                                  ['Ticket Number'],
                                inProgress: true,
                              ),
                              );
                            }
                            },
                            child: Stack(
                            children: [
                              InProgressTicketTile(
                              outletName: snapshot.data!.docs[index]
                                ["Outlet"],
                              text: snapshot.data!.docs[index]
                                ['header'],
                              width: width,
                              height: height,
                              header: 'Activity: ',
                              headerText: snapshot.data!.docs[index]
                                ['Activity'],
                              ),
                              Container(
                                padding: EdgeInsets.all(18),
                                width: width / 1.1,
                                height: height / 6.8,
                                decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: isSelected
                                  ? Colors.red.withOpacity(0.25)
                                  : Colors.transparent,
                                )),
                            ],
                            ),
                          );
                          case 'Maintainance(Food Court Outlet)':
                          return GestureDetector(
                            onLongPress: () {
                            controller.enableSelectionMode(docId);
                            },
                            onTap: () {
                            if (controller.selectionMode.value) {
                              controller.toggleSelection(docId);
                            } else {
                              Get.to(() => SecurityTicektDetails(
                                ticketId: snapshot
                                  .data!.docs[index]['Ticket Number'],
                                inProgress: true,
                                ));
                            }
                            },
                            child: Stack(
                            children: [
                              InProgressTicketTile(
                                outletName: snapshot
                                  .data!.docs[index]["Outlet"],
                                text: snapshot.data!.docs[index]
                                  ['header'],
                                width: width,
                                height: height,
                                header: 'Activity: ',
                                headerText: snapshot
                                  .data!.docs[index]['Activity']),
                              Container(
                                padding: EdgeInsets.all(18),
                                width: width / 1.1,
                                height: height / 6.8,
                                decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: isSelected
                                  ? Colors.red.withOpacity(0.25)
                                  : Colors.transparent,
                                )),
                            ],
                            ),
                          );
                          default:
                          return SizedBox();
                        }
                      },
                    );
            },
          ),
        );
      },
    );
  }
}



















