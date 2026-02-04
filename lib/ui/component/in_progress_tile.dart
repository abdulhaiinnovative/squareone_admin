import 'package:flutter/material.dart';
import 'buttons.dart';
import 'colors.dart';

class InProgressTicketTile extends StatelessWidget {
  const InProgressTicketTile({
    Key? key,
    required this.text,
    required this.width,
    required this.height,
    required this.header,
    required this.headerText,
    this.status = "Pending",
    required this.outletName,
  }) : super(key: key);

  final double width;
  final double height;
  final String text;
  final String header;
  final String headerText;
  final String outletName;
  final String status;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width / 1.1,
      height: height / 6.8,
      child: Card(
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 10,
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                children: [
                  const TicketButton(),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: width * 0.6,
                        child: Text(
                          text,
                          overflow: TextOverflow.fade,
                          softWrap: false,
                        ),
                      ),
                      Row(
                        children: [
                          Text(
                            "Outlet: ",
                            style: const TextStyle(color: Colors.black),
                          ),
                          Text(
                            outletName,
                            style: const TextStyle(color: Colors.black),
                          )
                        ],
                      )
                    ],
                  ),
                ],
              ),
              Container(
                width: 80,
                height: 20,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    color: status != "Approved" ? bgRedColor : greenColor,
                    borderRadius: BorderRadius.circular(5)),
                child: Text(
                  status,
                  style: TextStyle(
                      color:
                          status != "Approved" ? textRedColor : textGreenColor,
                      fontSize: 10),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class ClosedTickets extends StatelessWidget {
  const ClosedTickets({
    Key? key,
    required this.text,
    required this.width,
    required this.height,
    required this.header,
    required this.headerText,
    required this.head,
    required this.outletName,
  }) : super(key: key);

  final double width;
  final double height;
  final String text;
  final String header;
  final String head;
  final String outletName;
  final String headerText;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width / 1.1,
      height: height / 6.8,
      child: Card(
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 10,
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                children: [
                  const TicketButton(),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: width * 0.6,
                        child: Text(
                          text,
                          overflow: TextOverflow.fade,
                          softWrap: false,
                        ),
                      ),
                      Row(
                        children: [
                          Text(
                            "Outlet: ",
                            style: const TextStyle(
                              color: Colors.black,
                            ),
                          ),
                          Text(
                            outletName,
                            style: const TextStyle(
                              color: Colors.black,
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                ],
              ),
              Container(
                width: 80,
                height: 20,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    color: greenColor, borderRadius: BorderRadius.circular(5)),
                child: Text(
                  head,
                  style: const TextStyle(color: textGreenColor, fontSize: 10),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
