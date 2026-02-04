import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../component/buttons.dart';
import '../../../component/colors.dart';
import '../../../component/dropdown_feild.dart';
import '../../../component/text_feilds.dart';
import '../../../component/time_textfeild.dart';
import 'gate_pass_inward_controller.dart';

class GatePassInward extends StatelessWidget {
  const GatePassInward({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.white,
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Stack(
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
                    color: Colors.black.withOpacity(0.6),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(width: 10),
                        Text(
                          '   Open Ticket',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.w500,
                              color: Colors.white),
                        ),
                        Text(
                          '       Resolving Issues in less Time.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(child: Container(color: Colors.white)),
              ],
            ),

            SingleChildScrollView(
              child: Container(
                width: width,
                margin: EdgeInsets.only(top: height * 0.2),
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(15),
                      topRight: Radius.circular(15)),
                  color: Colors.white,
                ),
                child: GetBuilder<GatePassInwardController>(
                    init: Get.put<GatePassInwardController>(
                        GatePassInwardController()),
                    builder: (controller) {
                      return SingleChildScrollView(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                              padding: EdgeInsets.all(18.0),
                              child: Text(
                                ' Gate Pass Inward',
                                style: TextStyle(
                                  fontSize: 23,
                                ),
                              ),
                            ),
                            StreamBuilder<QuerySnapshot>(
                                stream: FirebaseFirestore.instance
                                    .collection('Outlets')
                                    .where('status', isEqualTo: 'Active')
                                    .snapshots(),
                                builder: (context, snapshot) {
                                  if (!snapshot.hasData) {
                                    return const Center(
                                      child: CircularProgressIndicator(
                                        color: Colors.red,
                                      ),
                                    );
                                  }
                                  return dropDown(
                                    'Outlet Name',
                                    items: snapshot.data!.docs
                                        .map((DocumentSnapshot document) {
                                      return DropdownMenuItem<String>(
                                          value: document["Outlet Name"],
                                          child: Text(
                                            document["Outlet Name"],
                                          ));
                                    }).toList(),
                                    onChanged: (String? value) {
                                      controller.selectedOutlet.value = value!;
                                    },
                                  );
                                }),
                            dropDown(
                              'Particular',
                              items: controller.particularItems,
                              onChanged: (String? value) {
                                controller.selectedPartiular.value = value!;
                              },
                            ),
                            Obx(() {
                              return controller.selectedPartiular.value ==
                                      'Other'
                                  ? descFeild('Item', controller.itemController)
                                  : const SizedBox(height: 0);
                            }),
                            dropDown(
                              'Type',
                              items: controller.typeItems,
                              onChanged: (String? value) {
                                controller.selectedType = value;
                              },
                            ),
                            textField('Quantity', controller.quantityController,
                                isKeyboard: true),
                            textField('POC', controller.pocController),
                            countFeild('Contact Number',
                                controller.contactController, 11,
                                isKeyboard: true),
                            datefeild(controller.dateInput.value, 'Date',
                                () => controller.pickDate(context)),
                            timefeild(controller, context, 'Time'),
                            Obx(() => controller.isloading.value
                                ? const Center(
                                    child: CircularProgressIndicator(
                                    color: redColor,
                                  ))
                                : LoginButton(
                                    width: width,
                                    height: height,
                                    text: 'Submit',
                                    function: () => controller.createTicket(),
                                  )),
                          ],
                        ),
                      );
                    }),
              ),
            ),
            // ),
          ],
        ),
      ),
    );
  }
}
