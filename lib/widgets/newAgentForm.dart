import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class NewAgentForm extends StatefulWidget {
  const NewAgentForm({
    Key? key,
  }) : super(key: key);

  @override
  State<NewAgentForm> createState() => _NewAgentFormState();
}

class _NewAgentFormState extends State<NewAgentForm> {
  final _wards = FirebaseFirestore.instance.collection('Wards').get();
  final _units = FirebaseFirestore.instance.collection('polling_units').get();
  final TextEditingController _mailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  String _ward = "";
  String _unit = "";
  bool _loading = false;
  String _error = "";

  @override
  void dispose() {
    _mailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      actions: [
        MaterialButton(
          onPressed: () => Navigator.of(context).pop(),
          color: Colors.grey,
          child: const Text("Cancel"),
        ),
        MaterialButton(
          onPressed: _loading
              ? null
              : () async {
                  setState(() {
                    _loading = true;
                    _error = "";
                  });
                  if (_ward.isNotEmpty &&
                      _unit.isNotEmpty &&
                      _mailController.text.isNotEmpty &&
                      _passwordController.text.isNotEmpty &&
                      _nameController.text.isNotEmpty &&
                      _phoneController.text.isNotEmpty) {
                    try {
                      var user = await FirebaseAuth.instance
                          .createUserWithEmailAndPassword(
                              email: _mailController.text,
                              password: _passwordController.text);
                      Map<String, dynamic> data = {
                        "isAdmin": false,
                        "isAgent": true,
                        "email": _mailController.text,
                        "full_name": _nameController.text,
                        "phone_number": _phoneController.text,
                        "assigned_polling_unit": _unit,
                        "assigned_ward": _ward,
                      };

                      await FirebaseFirestore.instance
                          .collection('Profile')
                          .add(data);
                      setState(() {
                        _loading = false;
                      });
                      Navigator.of(context).pop();
                    } catch (e) {
                      setState(() {
                        _loading = false;
                        _error = "An error has occured";
                      });
                    }
                  } else {
                    setState(() {
                      _loading = false;
                      _error = "All Fields must be provided";
                    });
                  }
                },
          color: Colors.green,
          child: _loading ? CircularProgressIndicator() : Text("Save"),
        ),
      ],
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            controller: _mailController,
            decoration: InputDecoration(label: Text("Email")),
          ),
          TextFormField(
            controller: _passwordController,
            decoration: InputDecoration(label: Text("Password")),
          ),
          Divider(
            color: Colors.blue,
          ),
          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(label: Text("Full name")),
          ),
          TextFormField(
            controller: _phoneController,
            decoration: InputDecoration(label: Text("Phone Number")),
          ),
          Divider(
            color: Colors.blue,
          ),
          FutureBuilder(
              future: _wards,
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
                return DropdownButtonFormField(
                  hint: const Text("Select Ward"),
                  items: snapshot.data!.docs
                      .map(
                        (e) => DropdownMenuItem(
                          value: e.id,
                          child: Text(e.data()['name']),
                        ),
                      )
                      .toList(),
                  onChanged: (value) => setState(() => _ward = value as String),
                );
              }),
          FutureBuilder(
              future: _units,
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
                return DropdownButtonFormField(
                  hint: const Text("Select Polling Unit"),
                  items: snapshot.data!.docs
                      .where((element) => element.data()['ward'] == _ward)
                      .map(
                        (e) => DropdownMenuItem(
                          value: e.id,
                          child: Text(e.data()['name']),
                        ),
                      )
                      .toList(),
                  onChanged: (value) => setState(() => _unit = value as String),
                );
              }),
          Text(
            _error,
            style: TextStyle(color: Colors.red),
          ),
        ],
      ),
    );
  }
}
