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

  @override
  Widget build(BuildContext context) {
    return DataTable(
      columns: [
        DataColumn(label: Text("Official")),
        DataColumn(label: Text("L.G.A")),
        DataColumn(label: Text("Ward")),
        DataColumn(label: Text("Accredited")),
        DataColumn(label: Text("Rejected")),
        DataColumn(label: Text("Valid")),
        DataColumn(label: Text("APC")),
        DataColumn(label: Text("NNPP")),
        DataColumn(label: Text("PDP")),
        DataColumn(label: Text("OHERS")),
        DataColumn(label: Text("Time")),
        DataColumn(label: Text("No Violence")),
        DataColumn(label: Text("Images")),
      ],
      rows: dataList
          .map(
            (e) => DataRow(
              cells: [
                DataCell(
                  StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection('profiles')
                        .where("email", isEqualTo: e['officer_email'])
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
                  e['local_government'].isEmpty
                      ? const Text("-")
                      : FutureBuilder(
                          future: FirebaseFirestore.instance
                              .collection("local_governments")
                              .doc(e['local_government'])
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
                  e['ward'].isEmpty
                      ? const Text("-")
                      : FutureBuilder(
                          future: FirebaseFirestore.instance
                              .collection("wards")
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
                              return const Text("Invalid Polling Unit");
                            }
                            return Text(
                              snapshot.data!.data()!['ward_name'],
                              // style: _tableContentStyle,
                            );
                          },
                        ),
                ),
                DataCell(
                  Text(
                    NumberFormat('###,###,###,###')
                        .format(e['accredited_votes']),
                    // style: _tableContentStyle,
                  ),
                ),
                DataCell(
                  Text(
                    NumberFormat('###,###,###,###').format(e['rejected_votes']),
                    // style: _tableContentStyle,
                  ),
                ),
                DataCell(
                  Text(
                    NumberFormat('###,###,###,###')
                        .format(e['accredited_votes'] - e['rejected_votes']),
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
                    NumberFormat('###,###,###,###').format(e['pdp']),
                    // style: _tableContentStyle,
                  ),
                ),
                DataCell(
                  Text(
                    NumberFormat('###,###,###,###').format(e['other_parties']),
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
                  FutureBuilder(
                    future: FirebaseFirestore.instance
                        .collection('images')
                        .where('report_id', isEqualTo: e['id'])
                        .get(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator();
                      }

                      var images = snapshot.data!.docs;
                      return GestureDetector(
                        onTap: images.isEmpty
                            ? null
                            : () async {
                                for (var i in images) {
                                  if (i.data()['image_object'] != null) {
                                    var url = await FirebaseStorage.instance
                                        .ref()
                                        .child(i.data()['image_object'])
                                        .getDownloadURL();
                                    if (!await launchUrl(Uri.parse(url))) {
                                      print('Could not launch $url');
                                    }
                                  }
                                }
                              },
                        child: Row(
                          children: [
                            Icon(
                              Icons.image,
                              color:
                                  images.isEmpty ? Colors.grey : Colors.black,
                            ),
                            Icon(
                              Icons.arrow_right,
                              size: 40,
                              color:
                                  images.isEmpty ? Colors.grey : Colors.black,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                )
              ],
            ),
          )
          .toList(),
    );
  }
}

class ResultTableTotal extends StatelessWidget {
  final List<Map<String, dynamic>> dataList;
  ResultTableTotal({
    super.key,
    required this.dataList,
  });

  final TextStyle _style = TextStyle(fontWeight: FontWeight.bold);

  @override
  Widget build(BuildContext context) {
    var totalAggredited = dataList.fold(
        0,
        (previousValue, element) =>
            previousValue + element['accredited_votes'] as int);
    var totalRejected = dataList.fold(
        0,
        (previousValue, element) =>
            previousValue + element['rejected_votes'] as int);
    var totalValid = totalAggredited - totalRejected;
    var totalApc = dataList.fold(
        0, (previousValue, element) => previousValue + element['apc'] as int);
    var totalNnpp = dataList.fold(
        0, (previousValue, element) => previousValue + element['nnpp'] as int);
    var totalPdp = dataList.fold(
        0, (previousValue, element) => previousValue + element['pdp'] as int);
    var totalOthers = dataList.fold(
        0,
        (previousValue, element) =>
            previousValue + element['other_parties'] as int);

    return Container(
      padding: EdgeInsets.all(18.0),
      width: double.maxFinite,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            blurRadius: 12.0,
            offset: Offset(4, 4),
            color: Colors.grey.withOpacity(0.6),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Total".toUpperCase(),
            style: _style,
          ),
          Text(
            "Accredited: ${NumberFormat('###,###,###,###').format(totalAggredited)}",
            style: _style,
          ),
          Text(
            "Rejected: ${NumberFormat('###,###,###,###').format(totalRejected)}",
            style: _style,
          ),
          Text(
            "Valid: ${NumberFormat('###,###,###,###').format(totalValid)}",
            style: _style,
          ),
          Text(
            "APC: ${NumberFormat('###,###,###,###').format(totalApc)}",
            style: _style,
          ),
          Text(
            "NNPP: ${NumberFormat('###,###,###,###').format(totalNnpp)}",
            style: _style,
          ),
          Text(
            "PDP: ${NumberFormat('###,###,###,###').format(totalPdp)}",
            style: _style,
          ),
          Text(
            "OTHER PARTIES: ${NumberFormat('###,###,###,###').format(totalOthers)}",
            style: _style,
          ),
        ],
      ),
    );
  }
}
