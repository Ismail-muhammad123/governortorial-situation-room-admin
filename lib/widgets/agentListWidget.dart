import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AgentListWidget extends StatefulWidget {
  final String fullName, phone, assignedWard, assignedPollingUnit, email, id;

  const AgentListWidget({
    required this.fullName,
    required this.phone,
    required this.email,
    required this.id,
    required this.assignedWard,
    required this.assignedPollingUnit,
    Key? key,
  }) : super(key: key);

  @override
  State<AgentListWidget> createState() => _AgentListWidgetState();
}

class _AgentListWidgetState extends State<AgentListWidget> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  bool _dropDownEnabled = false;
  bool _fieldsEditEnabled = false;

  @override
  void initState() {
    _nameController.text = widget.fullName;
    _phoneNumberController.text = widget.phone;

    super.initState();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Flexible(
          flex: 2,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              padding: const EdgeInsets.all(20),
              height: 250,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.white,
              ),
              child: Column(
                children: [
                  Flexible(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      // mainAxisAlignment: MainAxisAlignment.,
                      children: [
                        Container(
                          height: 150,
                          width: 150,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(75),
                            color: Colors.grey.withOpacity(0.2),
                          ),
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.person,
                            size: 100,
                          ),
                        ),
                        const SizedBox(
                          width: 30,
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: 60,
                              width: 300,
                              child: TextFormField(
                                controller: _nameController,
                                enabled: _fieldsEditEnabled,
                                decoration: InputDecoration(
                                  border: _fieldsEditEnabled
                                      ? const OutlineInputBorder(
                                          borderSide: BorderSide(),
                                        )
                                      : InputBorder.none,
                                ),
                              ),
                            ),
                            Text(
                              "Email: ${widget.email}",
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontStyle: FontStyle.italic,
                                fontSize: 16,
                              ),
                            ),
                            SizedBox(
                              height: 60,
                              width: 300,
                              child: TextFormField(
                                controller: _phoneNumberController,
                                enabled: _fieldsEditEnabled,
                                decoration: InputDecoration(
                                  border: _fieldsEditEnabled
                                      ? const OutlineInputBorder(
                                          borderSide: BorderSide(),
                                        )
                                      : InputBorder.none,
                                ),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      MaterialButton(
                        onPressed: () async {
                          if (!_fieldsEditEnabled) {
                            setState(() => _fieldsEditEnabled = true);
                          } else {
                            if (_nameController.text.isNotEmpty &&
                                _phoneNumberController.text.isNotEmpty) {
                              await FirebaseFirestore.instance
                                  .collection("Profile")
                                  .doc(widget.id)
                                  .update({
                                "full_name": _nameController.text,
                                "phone_number": _phoneNumberController.text,
                              });
                            }
                            setState(() {
                              _fieldsEditEnabled = false;
                            });
                          }
                        },
                        child:
                            Icon(_fieldsEditEnabled ? Icons.check : Icons.edit),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        Flexible(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              height: 250,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.white,
              ),
              padding: EdgeInsets.all(30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Ward:",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(
                        width: 12,
                      ),
                      Flexible(
                        child: StreamBuilder(
                          stream: FirebaseFirestore.instance
                              .collection('Wards')
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }
                            if (!snapshot.hasData) {
                              return const Center(
                                child: Text("Error"),
                              );
                            }
                            if (snapshot.data!.docs.isEmpty) {
                              return const Center(
                                child: Text("Not Assigned"),
                              );
                            }
                            return DropdownButtonFormField(
                              value: widget.assignedWard.isNotEmpty
                                  ? widget.assignedWard
                                  : null,
                              hint: widget.assignedWard.isEmpty
                                  ? const Text("Select Ward")
                                  : null,
                              items: snapshot.data!.docs
                                  .map(
                                    (e) => DropdownMenuItem(
                                      value: e.id,
                                      child: Text(e.data()['name']),
                                    ),
                                  )
                                  .toList(),
                              onChanged: _dropDownEnabled
                                  ? (value) async {
                                      await FirebaseFirestore.instance
                                          .collection('Profile')
                                          .doc(widget.id)
                                          .update({
                                        "assigned_ward": value,
                                      });
                                    }
                                  : null,
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Poling Unit:",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(
                        width: 12,
                      ),
                      Flexible(
                        child: StreamBuilder(
                          stream: FirebaseFirestore.instance
                              .collection('polling_units')
                              .where('assigned_agent',
                                  isEqualTo:
                                      FirebaseAuth.instance.currentUser!.email)
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }
                            if (!snapshot.hasData) {
                              return const Center(
                                child: Text("Error"),
                              );
                            }
                            if (snapshot.data!.docs.isEmpty) {
                              return const Text("No Polling Assigned");
                            }
                            return SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ...snapshot.data!.docs.map(
                                    (e) => Text("*${e.data()['name']}"),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        Flexible(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              height: 250,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.white,
              ),
              padding: const EdgeInsets.all(30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        "Result Uploaded".toUpperCase(),
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  Flexible(
                    child: StreamBuilder(
                      stream: FirebaseFirestore.instance
                          .collection('reports')
                          .where('agentEmail', isEqualTo: widget.email)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        if (!snapshot.hasData) {
                          return const Center(
                            child: Text("Error"),
                          );
                        }
                        if (snapshot.data!.docs.isEmpty) {
                          return const Center(
                            child: Text("No result is Uploaded yet!"),
                          );
                        }
                        return SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              ...snapshot.data!.docs.map(
                                (e) => Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                      "APC: ${e.data()['apc']} | PDP: ${e.data()['pdp']} | NNPP: ${e.data()['nnpp']}"),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
