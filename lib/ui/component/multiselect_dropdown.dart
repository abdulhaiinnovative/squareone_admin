import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:multiselect/multiselect.dart';

Container multiSelectDropDown(
  var controller,
  double height,
) {
  return Container(
      constraints: BoxConstraints(minHeight: height),
      margin: const EdgeInsets.only(left: 24, right: 24, top: 10),
      child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Add Worker',
              style: TextStyle(
                  fontSize: height / 5, color: const Color(0xFF858597)),
            ),
            const SizedBox(height: 5),
            Obx(
              () => controller.workerName.value.isNotEmpty
                  ? Form(
                      autovalidateMode: AutovalidateMode.always,
                      child: Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.black.withOpacity(0.008),
                                    blurRadius: 9,
                                    spreadRadius: 4,
                                    offset: const Offset(3, 5))
                              ]),
                          child: Scrollbar(
                            child: Obx(() {
                              return DropDownMultiSelect(
                                decoration: InputDecoration(
                                    errorStyle: const TextStyle(fontSize: 0.01),
                                    errorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(
                                        color: Colors.black,
                                        style: BorderStyle.solid,
                                      ),
                                    ),
                                    contentPadding: const EdgeInsets.only(
                                        bottom: 10, left: 10),
                                    focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                            color:
                                                Colors.black.withOpacity(0.7),
                                            width: 0.8)),
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                            color:
                                                Colors.black.withOpacity(0.7),
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
                                options: controller.workerName.value,
                                whenEmpty: 'Select Workers',
                                onChanged: (value) {
                                  controller.selectedOptionList.value = value;
                                  controller.selectedOption.value = "";
                                  for (var element
                                      in controller.selectedOptionList.value) {
                                    controller.selectedOption.value =
                                        "${controller.selectedOption.value} $element";
                                  }
                                },
                                selectedValues:
                                    controller.selectedOptionList.value,
                              );
                            }),
                          )))
                  : const SizedBox(
                      height: 0,
                    ),
            )
          ]));
}
