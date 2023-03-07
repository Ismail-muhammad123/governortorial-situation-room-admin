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
  final reportsRef = FirebaseFirestore.instance
      .collection("reports")
      .orderBy("uploaded_at", descending: true)
      .snapshots();

  String filter_lga = "";
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
                const SizedBox(
                  width: 20,
                ),
                Text(
                  "Local Government: ".toUpperCase(),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(
                  width: 20,
                ),
                Flexible(
                  child: StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection('local_governments')
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Text("...");
                      }
                      return DropdownButtonFormField(
                        value: filter_lga,
                        items: [
                          const DropdownMenuItem(
                            value: "",
                            child: Text("All"),
                          ),
                          ...snapshot.data!.docs.map(
                            (e) => DropdownMenuItem(
                              value: e.id,
                              child: Text(
                                e.data()['name'],
                                style: TextStyle(
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          )
                        ],
                        onChanged: (val) => setState(
                          () {
                            filter_lga = val as String;
                          },
                        ),
                      );
                    },
                  ),
                ),
                MaterialButton(
                  onPressed: () => setState(
                    () {
                      filter_lga = "";
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
                  if (filter_lga.isNotEmpty) {
                    data = data
                        .where((element) =>
                            element.data()['local_government'] == filter_lga)
                        .toList();
                  }
                  var d = data.map((e) { 
                    var r = e.data();
                    r['id'] = e.id;
                    return r;
                    
                    }).toList();
                  return SingleChildScrollView(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: ResultsDataTable(
                        dataList: d,
                      ),
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
