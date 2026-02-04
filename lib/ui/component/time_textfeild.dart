import 'package:flutter/material.dart';

Container timefeild(var controller, BuildContext context, String title) {
  return Container(
      margin: const EdgeInsets.only(left: 24, right: 24, top: 10),
      child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 16, color: Color(0xFF858597)),
            ),
            Center(
                child: TextField(
              controller: controller
                  .timeInput.value, //editing controller of this TextField
              decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  errorStyle: const TextStyle(fontSize: 0.01),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Colors.black,
                      style: BorderStyle.solid,
                    ),
                  ),
                  contentPadding: const EdgeInsets.only(bottom: 10, left: 10),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                          color: Colors.black.withOpacity(0.7), width: 0.8)),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                          color: Colors.black.withOpacity(0.7), width: 0.8)),
                  labelStyle: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                        color: Colors.black.withOpacity(0.7), width: 0.8),
                  )),
              readOnly:
                  true, //set it true, so that user will not able to edit text
              onTap: () => controller.pickTime(context),
            )),
          ]));
}

Container nonRentalTimefeild(
    var controller, BuildContext context, String title) {
  return Container(
      margin: const EdgeInsets.only(left: 24, right: 24, top: 10),
      child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 16, color: Color(0xFF858597)),
            ),
            Center(
                child: TextField(
              controller: controller
                  .timeInput.value, //editing controller of this TextField
              decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  errorStyle: const TextStyle(fontSize: 0.01),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Colors.black,
                      style: BorderStyle.solid,
                    ),
                  ),
                  contentPadding: const EdgeInsets.only(bottom: 10, left: 10),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                          color: Colors.black.withOpacity(0.7), width: 0.8)),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                          color: Colors.black.withOpacity(0.7), width: 0.8)),
                  labelStyle: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                        color: Colors.black.withOpacity(0.7), width: 0.8),
                  )),
              readOnly:
                  true, //set it true, so that user will not able to edit text
              onTap: () => controller.pickNonRentalTime(context),
            )),
          ]));
}

Container datefeild(
    TextEditingController controller, String title, Function()? onTap) {
  return Container(
      margin: const EdgeInsets.only(left: 24, right: 24, top: 10),
      child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 16, color: Color(0xFF858597)),
            ),
            Center(
                child: TextField(
              controller: controller, //editing controller of this TextField
              decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  errorStyle: const TextStyle(fontSize: 0.01),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Colors.black,
                      style: BorderStyle.solid,
                    ),
                  ),
                  contentPadding: const EdgeInsets.only(bottom: 10, left: 10),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                          color: Colors.black.withOpacity(0.7), width: 0.8)),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                          color: Colors.black.withOpacity(0.7), width: 0.8)),
                  labelStyle: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                        color: Colors.black.withOpacity(0.7), width: 0.8),
                  )),
              readOnly:
                  true, //set it true, so that user will not able to edit text
              onTap: onTap,
            )),
          ]));
}
