import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class WardsPage extends StatefulWidget {
  const WardsPage({super.key});

  @override
  State<WardsPage> createState() => _WardsPageState();
}

class _WardsPageState extends State<WardsPage> {
  final TextStyle _tableHeadingStyle = const TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w600,
  );

  String filter_lge = "";

  final _wardStream =
      FirebaseFirestore.instance.collection('wards').snapshots();
  final _lgaStream =
      FirebaseFirestore.instance.collection("local_governments").snapshots();
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                    "List of Wards".toUpperCase(),
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                Text("Filter:"),
                SizedBox(
                  width: 200,
                ),
                StreamBuilder(
                    stream: _lgaStream,
                    builder: (context, snapshot) {
                      return Flexible(
                        child: DropdownButtonFormField(
                          hint: Text("Select Local Government"),
                          items: [
                            DropdownMenuItem(
                              child: Text("All"),
                              value: "",
                            ),
                            ...snapshot.data!.docs.map(
                              (e) => DropdownMenuItem(
                                child: Text(e.data()['name']),
                                value: e.id,
                              ),
                            ),
                          ],
                          onChanged: (val) => setState(() {
                            filter_lge = val as String;
                          }),
                        ),
                      );
                    }),
              ],
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
                    stream: _wardStream,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const Center(
                          child: Text("Error"),
                        );
                      }
                      var data = snapshot.data!.docs;
                      if (filter_lge.isNotEmpty) {
                        data = data
                            .where((element) =>
                                element.data()['officer_email'] == filter_lge)
                            .toList();
                      }
                      return DataTable(
                        columns: [
                          DataColumn(
                            label: Text(
                              "Ward Name",
                              style: _tableHeadingStyle,
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              "Local Government",
                              style: _tableHeadingStyle,
                            ),
                          ),
                        ],
                        rows: data.map(
                          (e) {
                            return DataRow(
                              cells: [
                                DataCell(
                                  Text(e.data()['ward_name']),
                                ),
                                DataCell(
                                  FutureBuilder(
                                    future: FirebaseFirestore.instance
                                        .collection("local_governments")
                                        .doc(e.data()['local_government_id'])
                                        .get(),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return Center(
                                            child: CircularProgressIndicator());
                                      }
                                      if (!snapshot.hasData ||
                                          !snapshot.data!.exists) {
                                        return Text("Not Found");
                                      }
                                      return Text(
                                          snapshot.data!.data()!['name']);
                                    },
                                  ),
                                ),
                              ],
                            );
                          },
                        ).toList(),
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
