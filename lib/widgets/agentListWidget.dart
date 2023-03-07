import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AgentListWidget extends StatefulWidget {
  final String fullName, phone, email, id;

  const AgentListWidget({
    required this.fullName,
    required this.phone,
    required this.email,
    required this.id,
    Key? key,
  }) : super(key: key);

  @override
  State<AgentListWidget> createState() => _AgentListWidgetState();
}

class _AgentListWidgetState extends State<AgentListWidget> {
  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(Icons.person),
      title: Text(widget.fullName),
      subtitle: Text(widget.email),
    );
  }
}
