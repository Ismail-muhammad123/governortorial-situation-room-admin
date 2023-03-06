import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:url_launcher/url_launcher.dart';

class ReportListTile extends StatelessWidget {
  final String agentEmail, ward, pollingUnit, image;
  final double pdp, apc, nnpp;
  final bool violence;

  final TextStyle tableContentStyle = const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );

  const ReportListTile({
    // required this.agentId,
    // required this.agentName,
    required this.agentEmail,
    // required this.agentNumber,
    this.violence = false,
    required this.ward,
    required this.pollingUnit,
    required this.image,
    required this.apc,
    required this.pdp,
    required this.nnpp,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Container(
        height: 70,
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
        alignment: Alignment.center,
        width: double.maxFinite,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              width: 240,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    height: 30,
                    width: 30,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: Colors.grey.withOpacity(0.4),
                    ),
                    alignment: Alignment.center,
                    child: const Icon(Icons.person),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  StreamBuilder(
                      stream: FirebaseFirestore.instance
                          .collection('Profile')
                          .where("email", isEqualTo: agentEmail)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        }
                        if (!snapshot.hasData) {
                          return const Text("An error has occured");
                        }
                        if (snapshot.data!.docs.isEmpty) {
                          return const Text("Not Available");
                        }
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              snapshot.data!.docs.first.data()['full_name'],
                              style: tableContentStyle,
                            ),
                            Text(
                              snapshot.data!.docs.first.data()['phone_number'],
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey.withOpacity(0.5),
                              ),
                            ),
                          ],
                        );
                      }),
                ],
              ),
            ),
            ward.isEmpty? Text("-") : FutureBuilder(
              future: FirebaseFirestore.instance
                  .collection("Wards")
                  .doc(ward)
                  .get(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }
                if (!snapshot.hasData) {
                  return const Text("An error has occured");
                }
                if (!snapshot.data!.exists) {
                  return const Text("Invalid Ward");
                }
                return Text(
                  snapshot.data!.data()!['name'],
                  style: tableContentStyle,
                );
              },
            ),
            pollingUnit.isEmpty? Text("-"):
            FutureBuilder(
              future: FirebaseFirestore.instance
                  .collection("polling_units")
                  .doc(pollingUnit)
                  .get(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }
                if (!snapshot.hasData) {
                  return const Text("An error has occured");
                }
                if (!snapshot.data!.exists) {
                  return const Text("Invalid Polling Unit");
                }
                return Text(
                  snapshot.data!.data()!['name'],
                  style: tableContentStyle,
                );
              },
            ),
            SizedBox(
              width: 300,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    NumberFormat('###,###,###,###').format(pdp),
                    style: tableContentStyle,
                  ),
                  Text(
                    NumberFormat('###,###,###,###').format(apc),
                    style: tableContentStyle,
                  ),
                  Text(
                    NumberFormat('###,###,###,###').format(nnpp),
                    style: tableContentStyle,
                  ),
                ],
              ),
            ),
            Icon(
              violence ? Icons.cancel : Icons.check,
              color: violence ? Colors.red : Colors.green,
            ),
            SizedBox(
              width: 150,
              child: GestureDetector(
                onTap: image.isEmpty
                    ? null
                    : () async {
                        var url = await FirebaseStorage.instance
                            .ref()
                            .child(image)
                            .getDownloadURL();
                        // print(url);
                        if (!await launchUrl(Uri.parse(url))) {
                          throw Exception('Could not launch $url');
                        }
                      },
                child: Row(
                  children: [
                    Icon(
                      Icons.image,
                      color: image.isEmpty ? Colors.grey : Colors.black,
                    ),
                    Icon(
                      Icons.arrow_right,
                      size: 40,
                      color: image.isEmpty ? Colors.grey : Colors.black,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
