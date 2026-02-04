import 'package:flutter/material.dart';

Container ticektDetailText({String? head, String? text}) {
  return Container(
      padding: const EdgeInsets.only(top: 10),
      child: RichText(
        text: TextSpan(
            text: "$head : ",
            style: const TextStyle(
                color: Colors.black,
                fontSize: 18.0,
                fontWeight: FontWeight.w500),
            children: [
              TextSpan(
                text: text,
                style: const TextStyle(
                    color: Color(0xFF858597),
                    fontSize: 16.0,
                    fontWeight: FontWeight.w500),
              )
            ]),
      ));
}

Container showWorkers({String? head, List? text}) {
  return Container(
    padding: const EdgeInsets.only(top: 10),
    child: RichText(
      text: TextSpan(
          text: "$head : ",
          style: const TextStyle(
              color: Colors.black, fontSize: 18.0, fontWeight: FontWeight.w500),
          children: [
            for (var i in text!)
              TextSpan(
                text: "$i,",
                style: const TextStyle(
                    color: Color(0xFF858597),
                    fontSize: 16.0,
                    fontWeight: FontWeight.w500),
              )
          ]),
    ),
  );
}
