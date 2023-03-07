import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../widgets/agentListWidget.dart';
import '../widgets/newAgentForm.dart';

class AgentsPage extends StatefulWidget {
  const AgentsPage({super.key});

  @override
  State<AgentsPage> createState() => _AgentsPageState();
}

class _AgentsPageState extends State<AgentsPage> {
  final _agentsStream = FirebaseFirestore.instance
      .collection('profiles')
      .where('isAgent', isEqualTo: true)
      .snapshots();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                Text(
                  "List Of Returning Officers".toUpperCase(),
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                  ),
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    height: 30,
                    width: 30,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Icon(Icons.person),
                  ),
                ),
                Text(FirebaseAuth.instance.currentUser?.email ?? ""),
              ],
            ),
            Flexible(
              child: StreamBuilder(
                stream: _agentsStream,
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
                  if (snapshot.data!.docs.isEmpty) {
                    return Center(
                      child: Text("Empty"),
                    );
                  }
                  print(snapshot.data!.docs.first.data());
                  return ListView(
                    children: snapshot.data!.docs
                        .map(
                          (e) => AgentListWidget(
                            id: e.id,
                            fullName: e.data()['full_name'],
                            email: e.data()['email'],
                            phone: e.data()['phone_number'],
                          ),
                        )
                        .toList(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
