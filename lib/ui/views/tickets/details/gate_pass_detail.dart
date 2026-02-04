// ignore_for_file: deprecated_member_use

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:squareone_admin/ui/component/dismiss_tile.dart';
import 'package:squareone_admin/ui/component/text_feilds.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../component/buttons.dart';
import '../../../component/colors.dart';
import '../../../component/details_function.dart';
import '../tickets_controller.dart';

class GateInwardDetails extends StatefulWidget {
  final String ticketId;
  final bool? inProgress;
  const GateInwardDetails({
    super.key,
    required this.ticketId,
    this.inProgress,
  });

  @override
  State<GateInwardDetails> createState() => _GateInwardDetailsState();
}

class _GateInwardDetailsState extends State<GateInwardDetails> {
  TextEditingController reasonController = TextEditingController();

  @override
  void dispose() {
    reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        leading: ButtonBack(
          height: height,
          width: width,
        ),
        title: const Text(
          'Ticket Details',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500),
        ),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
      ),
      body: GetBuilder<TicketController>(
        init: Get.put<TicketController>(TicketController()),

        builder: (controller) {
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('Tickets')
                    .doc(widget.ticketId)
                    .snapshots(),
                builder: (context, AsyncSnapshot snapshot) {
                  return !snapshot.hasData
                      ? CircularProgressIndicator(color: redColor)
                      : Column(
                          children: [
                            Container(
                              width: width,
                              constraints: BoxConstraints(minHeight: height * 0.2),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12)),
                              child: Card(
                                surfaceTintColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                                elevation: 10,
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Container(
                                            width: width * 0.8,
                                            child: Text(
                                              'Ticket\n${snapshot.data!.data()['header']}',
                                              style: const TextStyle(
                                                  fontSize: 15.5,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                          CircleAvatar(
                                              backgroundColor: snapshot.data!
                                                          .data()['Status'] ==
                                                      "Open"
                                                  ? const Color(0xFFFE0D0D)
                                                  : snapshot
                                                              .data!
                                                              .data()['Status'] ==
                                                          "Closed"
                                                      ? const Color(0xFFFE0D0D)
                                                      : snapshot.data!.data()[
                                                                  'Status'] ==
                                                              'Approved'
                                                          ? const Color(0xFF12CA37)
                                                          : snapshot.data!.data()[
                                                                      'Status'] ==
                                                                  "Dissmissed"
                                                              ? const Color
                                                                  .fromARGB(
                                                                  255, 41, 96, 179)
                                                              : snapshot.data!.data()[
                                                                          'Status'] ==
                                                                      "Urgent Approved"
                                                                  ? const Color(
                                                                      0xFF12CA37)
                                                                  : const Color(
                                                                      0xFFFE0D0D),
                                              radius: width * 0.028,
                                              child: CircleAvatar(
                                                  backgroundColor: Colors.white,
                                                  radius: width * 0.021,
                                                  child: CircleAvatar(
                                                    backgroundColor: snapshot.data!
                                                                .data()['Status'] ==
                                                            "Open"
                                                        ? const Color(0xFFFE0D0D)
                                                        : snapshot.data!.data()[
                                                                    'Status'] ==
                                                                "Closed"
                                                            ? const Color(
                                                                0xFFFE0D0D)
                                                            : snapshot.data!.data()[
                                                                        'Status'] ==
                                                                    'Approved'
                                                                ? const Color(
                                                                    0xFF12CA37)
                                                                : snapshot.data!.data()[
                                                                            'Status'] ==
                                                                        "Dissmissed"
                                                                    ? const Color
                                                                        .fromARGB(
                                                                        255,
                                                                        41,
                                                                        96,
                                                                        179)
                                                                    : snapshot.data!.data()['Status'] ==
                                                                            "Urgent Approved"
                                                                        ? const Color(
                                                                            0xFF12CA37)
                                                                        : const Color(
                                                                            0xFFFE0D0D),
                                                    radius: width * 0.017,
                                                  )))
                                        ],
                                      ),
                                      ticektDetailText(
                                          head: 'Outlet Name',
                                          text: snapshot.data!.data()['Outlet']),
                                      ticektDetailText(
                                          head: 'POC',
                                          text: snapshot.data!.data()['POC']),
                                      InkWell(
                                          onTap: () => launch(
                                              "tel:${snapshot.data!.data()['Contact']}"),
                                          child: ticektDetailText(
                                              head: 'Contact',
                                              text: snapshot.data!
                                                  .data()['Contact'])),
                                      ticektDetailText(
                                          head: 'Particular',
                                          text: snapshot.data!.data()['Partiular']),
                                      snapshot.data!.data()['Partiular'] != 'Stock'
                                          ? InkWell(
                                              onTap: () {
                                                print(snapshot.data!
                                                    .data()['Partiular']);
                                              },
                                              child: ticektDetailText(
                                                  head: 'Item',
                                                  text: snapshot.data!
                                                      .data()['Item']),
                                            )
                                          : const SizedBox(height: 0),
                                      ticektDetailText(
                                          head: 'Type',
                                          text: snapshot.data!.data()['Type']),
                                      ticektDetailText(
                                          head: 'Quantity',
                                          text: snapshot.data!.data()['Quantity']),
                                      ticektDetailText(
                                          head: 'Date',
                                          text: snapshot.data!.data()['Date']),
                                      ticektDetailText(
                                          head: 'Time',
                                          text: snapshot.data!.data()['Time']),
                                      snapshot.data!.data()['Status'] == "Approved"
                                          ? ticektDetailText(
                                              head: 'Approved By',
                                              text: snapshot.data!
                                                  .data()['Approved By'])
                                          : snapshot.data!.data()['Status'] ==
                                                  "Dissmissed"
                                              ? ticektDetailText(
                                                  head: 'Dismissed By',
                                                  text: snapshot.data!
                                                      .data()['Dismissed By'])
                                              : snapshot.data!.data()['Status'] ==
                                                      "Closed"
                                                  ? Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment.start,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment.start,
                                                      children: [
                                                        ticektDetailText(
                                                            head: 'Approved By',
                                                            text: snapshot.data!
                                                                    .data()[
                                                                'Approved By']),
                                                        ticektDetailText(
                                                            head: 'Closed By',
                                                            text: snapshot.data!
                                                                    .data()[
                                                                'Closed By']),
                                                      ],
                                                    )
                                                  : snapshot
                                                              .data!
                                                              .data()['Status'] ==
                                                          "Urgent Approved"
                                                      ? ticektDetailText(
                                                          head:
                                                              'Created and Approved By',
                                                          text:
                                                              snapshot.data!.data()[
                                                                  'Approved By'])
                                                      : const SizedBox(height: 0),
                                      ticektDetailText(
                                        head: 'Creation Time',
                                        text: snapshot.data!
                                            .data()['Creation Time']
                                            .toDate()
                                            .toString()
                                            .substring(11, 16),
                                      ),
                                      snapshot.data!.data()['Status'] == "Approved"
                                          ? ticektDetailText(
                                              head: 'Approval Time',
                                              text: snapshot.data!
                                                  .data()['Approval Time']
                                                  .toDate()
                                                  .toString()
                                                  .substring(11, 16),
                                            )
                                          : const SizedBox(height: 0),
                                      snapshot.data!.data()['Status'] ==
                                              'Dissmissed'
                                          ? ticektDetailText(
                                              head: 'Dismissal Time',
                                              text: snapshot.data!
                                                  .data()['Dissmissal Time']
                                                  .toDate()
                                                  .toString()
                                                  .substring(11, 16),
                                            )
                                          : const SizedBox(height: 0),
                                      snapshot.data!.data()['Status'] == 'Closed'
                                          ? ticektDetailText(
                                              head: 'Closure Time',
                                              text: snapshot.data!
                                                  .data()['Closing Time']
                                                  .toDate()
                                                  .toString()
                                                  .substring(11, 16),
                                            )
                                          : const SizedBox(height: 0),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            widget.inProgress ?? false
                                ? textField(
                                    left: 0,
                                    right: 0,
                                    'Approval Comment (Optional)',
                                    reasonController,
                                  )
                                : const SizedBox(),
                            snapshot.data!.data()['Status'] == 'Dissmissed'
                                ? Column(
                                    children: [
                                      DismissTile(
                                          width: width,
                                          height: height,
                                          dismiss:
                                              snapshot.data!.data()['Dismiss']),
                                      LoginButton(
                                        width: width,
                                        height: height,
                                        function: () {
                                         controller.getApproveDialog(
                                            width: width,
                                            header: snapshot.data!.data()['header'],
                                            ticketId: widget.ticketId,
                                            height: height,
                                            uid: snapshot.data!.data()['User ID'],
                                            ticketNoti: "TicketG ${widget.ticketId}",
                                          );
                                        },
                                        text: 'Approve Ticket',
                                      ),
                                    ],
                                  )
                                : const SizedBox(height: 20),
                            controller.isLoading.value
                                  ? Padding(
                                      padding: EdgeInsets.only(top: width / 20),
                                      child: const Center(
                                        child: CircularProgressIndicator(
                                          color: redColor,
                                        ),
                                      ),
                                    )
                                  : snapshot.data!.data()['Status'] == 'Open' &&
                                          (controller.depart.value == "Admin" ||
                                              controller.depart.value ==
                                                  "Operations" ||
                                              controller.depart.value ==
                                                  "Food Court")
                                      ? Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            LoginButton(
                                              color: const Color.fromARGB(
                                                  255, 41, 96, 179),
                                              width: width,
                                              height: height,
                                              function: () =>
                                                  controller.getDismissDialog(
                                                      width: width,
                                                      header: snapshot.data!
                                                          .data()['header'],
                                                      ticketId: widget.ticketId,
                                                      height: height,
                                                      uid: snapshot.data!
                                                          .data()['User ID'],
                                                      ticketNoti:
                                                          "TicketG ${widget.ticketId}"),
                                              text: 'Dismiss Ticket',
                                            ),
                                            LoginButton(
                                              padding: 200,
                                              color: const Color(0xFF12CA37),
                                              width: width,
                                              height: height,
                                              function: () =>
                                                  controller.approveTicket(
                                                      snapshot.data!
                                                          .data()['User ID'],
                                                      widget.ticketId,
                                                      snapshot.data!
                                                          .data()['header'],
                                                      snapshot.data!
                                                          .data()['Outlet'],
                                                      "TicketG ${widget.ticketId}",
                                                      reasonController.text),
                                              text: 'Approve Ticket',
                                            ),
                                          ],
                                        )
                                      : controller.showCloseButton.value &&
                                              snapshot.data!.data()['Status'] ==
                                                  'Approved'
                                          ? Column(
                                              children: [
                                                snapshot.data!
                                                                .data()['Reason'] ==
                                                            null ||
                                                        snapshot.data!
                                                                .data()['Reason'] ==
                                                            '' ||
                                                        snapshot.data!
                                                                .data()['Reason'] ==
                                                            'Not specified'
                                                    ? SizedBox()
                                                    : DismissTile(
                                                        width: width,
                                                        height: height,
                                                        dismiss: snapshot.data!
                                                            .data()['Reason'],
                                                        title: 'Approval',
                                                      ),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.spaceEvenly,
                                                  children: [
                                                    LoginButton(
                                                      color: const Color.fromARGB(
                                                          255, 41, 96, 179),
                                                      width: width,
                                                      height: height,
                                                      function: () => controller
                                                          .getDismissDialog(
                                                              reason:
                                                                  reasonController
                                                                      .text,
                                                              width: width,
                                                              header: snapshot.data!
                                                                  .data()['header'],
                                                              ticketId:
                                                                  widget.ticketId,
                                                              height: height,
                                                              uid: snapshot.data!
                                                                      .data()[
                                                                  'User ID'],
                                                              ticketNoti:
                                                                  "TicketG ${widget.ticketId}"),
                                                      text: 'Dismiss Ticket',
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            )
                                          : SizedBox(height: 0),
                          
                          ],
                        );
                },
              ),
            ),
          );
        }
      ),
    );
  }
}
