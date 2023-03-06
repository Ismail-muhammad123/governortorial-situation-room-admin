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

  final _wardStream =
      FirebaseFirestore.instance.collection('Wards').snapshots();
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        label: Text("Ward Name"),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    MaterialButton(
                      onPressed: () {
                        _controller.text.isNotEmpty
                            ? FirebaseFirestore.instance
                                .collection('Wards')
                                .add({
                                "name": _controller.text,
                                "added_at": DateTime.now().toUtc().toString()
                              }).then(
                                (value) => Navigator.of(context).pop(),
                              )
                            : setState(() {});
                      },
                      color: Colors.green,
                      child: const Text("Save"),
                    ),
                  ],
                ),
              );
            },
          );
        },
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
                    "List of Wards".toUpperCase(),
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
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
                    stream: _wardStream,
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
                              "Action",
                              style: _tableHeadingStyle,
                            ),
                          ),
                        ],
                        rows: snapshot.data!.docs.map(
                          (e) {
                            return DataRow(
                              cells: [
                                DataCell(
                                  Text(e.data()['name']),
                                ),
                                DataCell(
                                  IconButton(
                                    onPressed: () {
                                      _controller.text = e.data()['name'];
                                      showDialog(
                                        context: context,
                                        builder: (context) {
                                          return AlertDialog(
                                            content: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                TextFormField(
                                                  controller: _controller,
                                                  decoration:
                                                      const InputDecoration(
                                                    label: Text("Ward Name"),
                                                  ),
                                                ),
                                                const SizedBox(
                                                  height: 20,
                                                ),
                                                MaterialButton(
                                                  onPressed: () {
                                                    _controller.text.isNotEmpty
                                                        ? FirebaseFirestore
                                                            .instance
                                                            .collection('Wards')
                                                            .doc(e.id)
                                                            .set({
                                                            "name": _controller
                                                                .text,
                                                            "added_at":
                                                                DateTime.now()
                                                                    .toUtc()
                                                                    .toString()
                                                          }).then(
                                                            (value) =>
                                                                Navigator.of(
                                                                        context)
                                                                    .pop(),
                                                          )
                                                        : setState(() {});
                                                  },
                                                  color: Colors.green,
                                                  child: const Text("Save"),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      );
                                    },
                                    icon: const Icon(Icons.edit),
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
