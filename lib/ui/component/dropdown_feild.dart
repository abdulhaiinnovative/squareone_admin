import 'package:flutter/material.dart';

Container dropDown(
  String title, {
  Function(String?)? onChanged,
  String? selectedValuess,
  List<DropdownMenuItem<String>>? items,
}) {
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
          const SizedBox(height: 5),
          Form(
              autovalidateMode: AutovalidateMode.always,
              child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 9,
                          spreadRadius: 4,
                          offset: const Offset(3, 5))
                    ]),
                child: Form(
                  child: DropdownButtonFormField(
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
                          contentPadding:
                              const EdgeInsets.only(bottom: 10, left: 10),
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                  color: Colors.black.withOpacity(0.7),
                                  width: 0.8)),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                  color: Colors.black.withOpacity(0.7),
                                  width: 0.8)),
                          labelStyle: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                                color: Colors.black.withOpacity(0.7),
                                width: 0.8),
                          )),
                      validator: (value) => value == null ? title : null,
                      dropdownColor: Colors.white,
                      value: selectedValuess,
                      onChanged: onChanged ??
                          (String? value) {
                            selectedValuess = value;
                          },
                      items: items),
                ),
              ))
        ]),
  );
}
