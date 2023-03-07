import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class LocalGovernments extends StatefulWidget {
  const LocalGovernments({super.key});

  @override
  State<LocalGovernments> createState() => _LocalGovernmentsState();
}

class _LocalGovernmentsState extends State<LocalGovernments> {
  final TextStyle _tableHeadingStyle = const TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w600,
  );

  final _localGovernmentsStream =
      FirebaseFirestore.instance.collection("local_governments").snapshots();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () async => await showDialog(
      //     context: context,
      //     builder: (context) {
      //       return const PollingUnitForm();
      //     },
      //   ),
      //   child: const Icon(Icons.add),
      // ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Container(
          width: double.maxFinite,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: SingleChildScrollView(
            child: StreamBuilder(
              stream: _localGovernmentsStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                if (!snapshot.hasData) {
                  print(snapshot.error);
                  print(snapshot.data);
                  return const Center(
                    child: Text("Not found"),
                  );
                }

                var data = snapshot.data!.docs;
                return DataTable(
                  columns: [
                    DataColumn(
                      label: Text(
                        "Local Government Name",
                        style: _tableHeadingStyle,
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        "Assigned Officer Name",
                        style: _tableHeadingStyle,
                      ),
                    ),
                  ],
                  rows: data
                      .map(
                        (e) => DataRow(
                          cells: [
                            DataCell(
                              Text(e.data()['name']),
                            ),
                            DataCell(
                              FutureBuilder(
                                future: FirebaseFirestore.instance
                                    .collection("profiles")
                                    .where(
                                      "email",
                                      isEqualTo: e.data()['officer_email'],
                                    )
                                    .get(),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  }
                                  if (!snapshot.hasData ||
                                      snapshot.data!.docs.isEmpty) {
                                    return Text('Not Found');
                                  }
                                  return Text(snapshot.data!.docs.first
                                      .data()['full_name']);
                                },
                              ),
                            ),
                          ],
                        ),
                      )
                      .toList(),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
