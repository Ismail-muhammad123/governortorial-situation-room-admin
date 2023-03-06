import 'package:admin/widgets/result_list_table.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../widgets/raportTableHeader.dart';
import '../widgets/reportsListTile.dart';

class ResultsPage extends StatefulWidget {
  const ResultsPage({super.key});

  @override
  State<ResultsPage> createState() => _ResultsPageState();
}

class _ResultsPageState extends State<ResultsPage> {
  final TextStyle _tableHeadingStyle = const TextStyle(
    fontWeight: FontWeight.w800,
    fontSize: 18,
  );

  final TextStyle _tableContentStyle = const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );
  final reportsRef = FirebaseFirestore.instance
      .collection("reports")
      .orderBy("uploaded_at", descending: true)
      .snapshots();

  String filter_agent_email = "";
  String filter_ward_id = "";
  String filter_unit_id = "";
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(6.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Results Uploaded".toUpperCase(),
            style: const TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(Icons.sort),
                // Text(
                //   "Filter: ".toUpperCase(),
                //   style: const TextStyle(
                //     fontWeight: FontWeight.w600,
                //   ),
                // ),
                const SizedBox(
                  width: 20,
                ),
                Text(
                  "Wards: ".toUpperCase(),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Flexible(
                  child: StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection('Wards')
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Text("...");
                      }
                      //   return Text(
                      //       snapshot.data!.data()!['name']);
                      // },
                      return DropdownButtonFormField(
                        // hint: const Text("Select Ward"),
                        value: filter_ward_id,
                        items: [
                          const DropdownMenuItem(
                            value: "",
                            child: Text("All"),
                          ),
                          ...snapshot.data!.docs.map(
                            (e) => DropdownMenuItem(
                              value: e.id,
                              child: Text(e.data()['name']),
                            ),
                          )
                        ],
                        onChanged: (val) => setState(
                          () {
                            filter_ward_id = val as String;
                          },
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(
                  width: 20,
                ),
                Text(
                  "Units: ".toUpperCase(),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Flexible(
                  child: StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection('polling_units')
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Text("...");
                      }
                      //   return Text(
                      //       snapshot.data!.data()!['name']);
                      // },
                      return DropdownButtonFormField(
                        // hint: const Text("Select Polling Unit"),
                        value: filter_ward_id,
                        items: [
                          const DropdownMenuItem(
                            child: Text("All"),
                            value: "",
                          ),
                          ...snapshot.data!.docs.map(
                            (e) => DropdownMenuItem(
                              value: e.id,
                              child: Text(e.data()['name']),
                            ),
                          )
                        ],
                        onChanged: (val) => setState(
                          () {
                            filter_unit_id = val as String;
                          },
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(
                  width: 20,
                ),
                Text(
                  "Agents: ".toUpperCase(),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Flexible(
                  child: StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection('Profile')
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Text("...");
                      }
                      return DropdownButtonFormField(
                        // hint: const Text("Select Agent"),
                        value: filter_agent_email,
                        items: [
                          const DropdownMenuItem(
                            value: "",
                            child: Text("All"),
                          ),
                          ...snapshot.data!.docs.map(
                            (e) => DropdownMenuItem(
                              value: e.data()['email'],
                              child: Text(
                                e.data()['email'],
                                style: TextStyle(
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          )
                        ],
                        onChanged: (val) => setState(
                          () {
                            filter_agent_email = val as String;
                          },
                        ),
                      );
                    },
                  ),
                ),
                MaterialButton(
                  onPressed: () => setState(
                    () {
                      filter_agent_email = "";
                      filter_ward_id = "";
                      filter_unit_id = "";
                    },
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: const [
                        Icon(Icons.clear),
                        SizedBox(
                          width: 12.0,
                        ),
                        Text("Clear"),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Flexible(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: StreamBuilder(
                stream: reportsRef,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  if (!snapshot.hasData) {
                    return const Center(
                      child: Text("An error has occured"),
                    );
                  }

                  var data = snapshot.data!.docs;
                  if (filter_agent_email.isNotEmpty) {
                    data = data
                        .where((element) =>
                            element.data()['agentEmail'] == filter_agent_email)
                        .toList();
                  }
                  if (filter_ward_id.isNotEmpty) {
                    data = data
                        .where((element) =>
                            element.data()['ward'] == filter_ward_id)
                        .toList();
                  }
                  if (filter_unit_id.isNotEmpty) {
                    data = data
                        .where((element) =>
                            element.data()['polling_unit'] == filter_ward_id)
                        .toList();
                  }

                  return SingleChildScrollView(
                    child: ResultsDataTable(
                      dataList: data.map((e) => e.data()).toList(),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
