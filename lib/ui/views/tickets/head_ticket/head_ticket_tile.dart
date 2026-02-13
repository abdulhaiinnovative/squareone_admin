import 'package:flutter/material.dart';
import 'package:squareone_admin/ui/component/buttons.dart';
import 'package:squareone_admin/ui/component/colors.dart';


class HeadTicketTile extends StatelessWidget {
  const HeadTicketTile({
    Key? key,
    required this.text,
    required this.width,
    required this.height,
    required this.employeeName,
    required this.status,
    this.onTap,
  }) : super(key: key);

  final VoidCallback? onTap;
  final double width;
  final double height;
  final String text;
  final String employeeName;
  final String status;

  @override
  Widget build(BuildContext context) {
    final String normalizedStatus = status.trim().toLowerCase();

    Color badgeBgColor;
    Color badgeTextColor;

    switch (normalizedStatus) {
      case 'assigned':
        badgeBgColor = Colors.orange.withOpacity(0.15);
        badgeTextColor = Colors.orange;
        break;
      case 'pending':
        badgeBgColor = redColor.withOpacity(0.15);
        badgeTextColor = redColor;
        break;
      case 'in progress':
        badgeBgColor = Colors.blue.withOpacity(0.15);
        badgeTextColor = Colors.blue;
        break;
      case 'completed':
        badgeBgColor = greenColor.withOpacity(0.15);
        badgeTextColor = greenColor;
        break;
      default:
        badgeBgColor = Colors.grey.withOpacity(0.15);
        badgeTextColor = Colors.grey;
    }

    final displayStatus = status.isNotEmpty
        ? status[0].toUpperCase() + status.substring(1)
        : 'Unknown';

    return GestureDetector(
      onTap: onTap,
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        elevation: 5,
        shadowColor: Colors.black.withOpacity(0.65),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// 🔹 TOP ROW (Title + Status)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const TicketButton(),
                  const SizedBox(width: 12),

                  /// Title + Assigned To
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          text,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "To: $employeeName",
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),

                  /// Status Badge
                  Container(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: badgeBgColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      displayStatus,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: badgeTextColor,
                      ),
                    ),
                  ),
                ],
              ),
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
