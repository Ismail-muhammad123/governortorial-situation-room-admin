import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class ResultsDataTable extends StatelessWidget {
  final List<Map<String, dynamic>> dataList;
  const ResultsDataTable({
    Key? key,
    required this.dataList,
  }) : super(key: key);

  final TextStyle _tableHeadingStyle = const TextStyle(
    fontWeight: FontWeight.w800,
    fontSize: 18,
  );
  @override
  Widget build(BuildContext context) {
    return DataTable(
      headingTextStyle: _tableHeadingStyle,
      columns: [
        DataColumn(label: Text("Agent Name")),
        DataColumn(label: Text("Ward")),
        DataColumn(label: Text("Polling Unit")),
        DataColumn(
            label: Text(
          "PDP",
          style: _tableHeadingStyle.copyWith(color: Colors.red),
        )),
        DataColumn(
            label: Text(
          "APC",
          style: _tableHeadingStyle.copyWith(color: Colors.green),
        )),
        DataColumn(
            label: Text(
          "NNPP",
          style: _tableHeadingStyle.copyWith(color: Colors.blue),
        )),
        DataColumn(label: Text("Time")),
        DataColumn(label: Text("No Violence")),
        DataColumn(label: Text("Image")),
      ],
      rows: dataList
          .map(
            (e) => DataRow(
              cells: [
                DataCell(
                  StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection('Profile')
                        .where("email", isEqualTo: e['agentEmail'])
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      }
                      if (!snapshot.hasData) {
                        return const Text("An error has occured");
                      }
                      if (snapshot.data!.docs.isEmpty) {
                        return const Text("Not Available");
                      }
                      return Text(
                        snapshot.data!.docs.first.data()['full_name'],
                        // style: _tableContentStyle,
                      );
                    },
                  ),
                ),
                DataCell(
                  e['ward'].isEmpty
                      ? const Text("-")
                      : FutureBuilder(
                          future: FirebaseFirestore.instance
                              .collection("Wards")
                              .doc(e['ward'])
                              .get(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
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
                              // style: _tableContentStyle,
                            );
                          },
                        ),
                ),
                DataCell(
                  e['polling_unit'].isEmpty
                      ? const Text("-")
                      : FutureBuilder(
                          future: FirebaseFirestore.instance
                              .collection("polling_units")
                              .doc(e['polling_unit'])
                              .get(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
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
                              // style: _tableContentStyle,
                            );
                          },
                        ),
                ),
                DataCell(
                  Text(
                    NumberFormat('###,###,###,###').format(e['pdp']),
                    // style: _tableContentStyle,
                  ),
                ),
                DataCell(
                  Text(
                    NumberFormat('###,###,###,###').format(e['apc']),
                    // style: _tableContentStyle,
                  ),
                ),
                DataCell(
                  Text(
                    NumberFormat('###,###,###,###').format(e['nnpp']),
                    // style: _tableContentStyle,
                  ),
                ),
                DataCell(
                  Text(
                    e['uploaded_at'] != null && e['uploaded_time'] != ""
                        ? DateFormat("dd/MM/yyyy hh:mm a").format(
                            (e['uploaded_at'] as Timestamp).toDate(),
                          )
                        : "-",
                  ),
                ),
                DataCell(
                  Icon(
                    e['violence'] ? Icons.cancel : Icons.check,
                    color: e['violence'] ? Colors.red : Colors.green,
                  ),
                ),
                DataCell(
                  GestureDetector(
                    onTap: e['image'].isEmpty
                        ? null
                        : () async {
                            var url = await FirebaseStorage.instance
                                .ref()
                                .child(e['image'])
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
                          color:
                              e['image'].isEmpty ? Colors.grey : Colors.black,
                        ),
                        Icon(
                          Icons.arrow_right,
                          size: 40,
                          color:
                              e['image'].isEmpty ? Colors.grey : Colors.black,
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          )
          .toList(),
    );
  }
}
