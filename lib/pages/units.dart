import 'package:admin/widgets/pollingUnitsForm.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class PolingUnitsPage extends StatefulWidget {
  const PolingUnitsPage({super.key});

  @override
  State<PolingUnitsPage> createState() => _PolingUnitsPageState();
}

class _PolingUnitsPageState extends State<PolingUnitsPage> {
  final TextStyle _tableHeadingStyle = const TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w600,
  );

  final _pollingUnitsStream =
      FirebaseFirestore.instance.collection("polling_units").snapshots();

  String filter_agent_email = "";
  String filter_ward_id = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () async => await showDialog(
          context: context,
          builder: (context) {
            return const PollingUnitForm();
          },
        ),
        child: const Icon(Icons.add),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    "List of Poling Units".toUpperCase(),
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  // Spacer(),
                  SizedBox(
                    width: 100,
                  ),
                  Text(
                    "Filter: ".toUpperCase(),
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(
                    width: 50,
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
                              child: Text("All Wards"),
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
                    width: 100,
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
                              child: Text("All Agents"),
                            ),
                            ...snapshot.data!.docs.map(
                              (e) => DropdownMenuItem(
                                value: e.data()['email'],
                                child: Text(e.data()['email']),
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
                      },
                    ),
                    color: Colors.grey,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: const [
                          Icon(Icons.clear),
                          SizedBox(
                            width: 12.0,
                          ),
                          Text("Clear Filter"),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Flexible(
              child: Container(
                width: double.maxFinite,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: SingleChildScrollView(
                  child: StreamBuilder(
                    stream: _pollingUnitsStream,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                      if (!snapshot.hasData) {
                        return const Center(
                          child: Text("Error"),
                        );
                      }

                      var data = snapshot.data!.docs;
                      if (filter_agent_email.isNotEmpty) {
                        data = data
                            .where((element) =>
                                element.data()['assigned_agent'] ==
                                filter_agent_email)
                            .toList();
                      }
                      if (filter_ward_id.isNotEmpty) {
                        data = data
                            .where((element) =>
                                element.data()['ward'] == filter_ward_id)
                            .toList();
                      }
                      return DataTable(
                        columns: [
                          DataColumn(
                            label: Text(
                              "Polling Unit Name",
                              style: _tableHeadingStyle,
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              "Ward",
                              style: _tableHeadingStyle,
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              "Assigned Agent Name",
                              style: _tableHeadingStyle,
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              "Action",
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
                                    e.data()['ward'] != null &&
                                            e.data()['ward'] != ""
                                        ? StreamBuilder(
                                            stream: FirebaseFirestore.instance
                                                .collection('Wards')
                                                .doc(e.data()['ward'])
                                                .snapshots(),
                                            builder: (context, snapshot) {
                                              if (!snapshot.hasData) {
                                                return const Text("...");
                                              }
                                              return Text(snapshot.data!
                                                  .data()!['name']);
                                            },
                                          )
                                        : const Text("not found"),
                                  ),
                                  DataCell(
                                    Text(e.data()['assigned_agent'] ??
                                        "Not assigned"),
                                  ),
                                  DataCell(
                                    IconButton(
                                      onPressed: () async => await showDialog(
                                        context: context,
                                        builder: (context) {
                                          return PollingUnitForm(
                                            pollingUnitName: e.data()['name'],
                                            pollingUnitId: e.id,
                                            ward: e.data()['ward'],
                                          );
                                        },
                                      ),
                                      icon: const Icon(Icons.edit),
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
          ],
        ),
      ),
    );
  }
}
