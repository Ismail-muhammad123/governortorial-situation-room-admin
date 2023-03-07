import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../data/radialChartData.dart';
import '../widgets/progressBar.dart';
import '../widgets/raportTableHeader.dart';
import '../widgets/reportsListTile.dart';
import '../widgets/result_list_table.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final reportsRef =
      FirebaseFirestore.instance.collection("reports").snapshots();

  String _lga = "";

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SingleChildScrollView(
        child: Column(
          children: [
            Row(
              children: [
                Text(
                  "Results by Candidates".toUpperCase(),
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                  ),
                ),
                Text("Filter By LGA:"),
                SizedBox(
                  width: 50.0,
                ),
                FutureBuilder(
                  future: FirebaseFirestore.instance
                      .collection("local_governments")
                      .get(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator();
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return Container();
                    }
                    return Flexible(
                      child: DropdownButtonFormField(
                        // hint: Text("Select Local Government"),
                        value: _lga,
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
                        onChanged: (val) => setState(
                          () {
                            _lga = val as String;
                          },
                        ),
                      ),
                    );
                  },
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
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection("reports")
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  var data = snapshot.data!.docs;
                  if (_lga.isNotEmpty) {
                    data = data
                        .where((element) =>
                            element.data()['local_government'] == _lga)
                        .toList();
                  }
                  var acredated = data.fold(
                      0,
                      (previousValue, element) =>
                          previousValue +
                          (element.data()['accredited_votes'] as int));
                  var rejected = data.fold(
                      0,
                      (previousValue, element) =>
                          previousValue +
                          (element.data()['rejected_votes'] as int));
                  var casted = data.fold(
                      0,
                      (previousValue, element) =>
                          previousValue +
                          (element.data()['accredited_votes'] as int));

                  return Row(
                    children: [
                      Flexible(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            height: 150,
                            width: double.maxFinite,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.3),
                                  blurRadius: 12.0,
                                  offset: Offset(4, 4),
                                )
                              ],
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  NumberFormat('###,###,###,###')
                                      .format(acredated),
                                  style: TextStyle(
                                    fontSize: 24,
                                  ),
                                ),
                                Text("Total Accredated Votes"),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Flexible(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            width: double.maxFinite,
                            height: 150,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.3),
                                  blurRadius: 12.0,
                                  offset: Offset(4, 4),
                                )
                              ],
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  NumberFormat('###,###,###,###')
                                      .format(casted),
                                  style: TextStyle(
                                    fontSize: 24,
                                  ),
                                ),
                                Text("Total Casted Votes"),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Flexible(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            width: double.maxFinite,
                            height: 150,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.3),
                                  blurRadius: 12.0,
                                  offset: Offset(4, 4),
                                )
                              ],
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  NumberFormat('###,###,###,###')
                                      .format(rejected),
                                  style: TextStyle(
                                    fontSize: 24,
                                  ),
                                ),
                                Text("Total Rejected Votes"),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Flexible(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            height: 150,
                            width: double.maxFinite,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.3),
                                  blurRadius: 12.0,
                                  offset: Offset(4, 4),
                                )
                              ],
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  NumberFormat('###,###,###,###')
                                      .format(casted - rejected),
                                  style: TextStyle(
                                    fontSize: 24,
                                  ),
                                ),
                                Text("Total Valid Votes"),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    height: 300,
                    width: 800,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(18.0),
                      child: StreamBuilder(
                        stream: reportsRef,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          if (!snapshot.hasData) {
                            return Container();
                          }
                          var data = snapshot.data!.docs;
                          if (_lga.isNotEmpty) {
                            data = data
                                .where((element) =>
                                    element.data()['local_government'] == _lga)
                                .toList();
                          }
                          var pdp = data.fold<double>(
                              0,
                              (previousValue, element) =>
                                  previousValue + element.data()["pdp"]);
                          var apc = data.fold<double>(
                              0,
                              (previousValue, element) =>
                                  previousValue + element.data()["apc"]);
                          var nnpp = data.fold<double>(
                              0,
                              (previousValue, element) =>
                                  previousValue + element.data()["nnpp"]);
                          var others = data.fold<double>(
                              0,
                              (previousValue, element) =>
                                  previousValue +
                                  element.data()["other_parties"]);
                          var total = 5594193;
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              ProgressBarWidget(
                                label: "GAWUNA/GARO",
                                maxValue: total.toDouble(),
                                value: apc,
                                backgroundColor:
                                    const Color.fromARGB(255, 218, 218, 218),
                                progressColor: Colors.green,
                              ),
                              ProgressBarWidget(
                                label: "ABBA/ABDUSSALAM",
                                maxValue: total.toDouble(),
                                value: nnpp,
                                backgroundColor:
                                    const Color.fromARGB(255, 218, 218, 218),
                                progressColor: Colors.blue,
                              ),
                              ProgressBarWidget(
                                label: "SADIQ/DANBATTA",
                                maxValue: total.toDouble(),
                                value: pdp,
                                backgroundColor:
                                    const Color.fromARGB(255, 218, 218, 218),
                                progressColor: Colors.red,
                              ),
                              ProgressBarWidget(
                                label: "OTHER PARTIES",
                                maxValue: total.toDouble(),
                                value: others,
                                backgroundColor:
                                    const Color.fromARGB(255, 218, 218, 218),
                                progressColor: Colors.blue,
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                Flexible(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      height: 300,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.white,
                      ),
                      child: StreamBuilder(
                        stream: reportsRef,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
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
                          if (_lga.isNotEmpty) {
                            data = data
                                .where((element) =>
                                    element.data()['local_government'] == _lga)
                                .toList();
                          }
                          var pdp = data.fold<double>(
                              0,
                              (previousValue, element) =>
                                  previousValue + element.data()["pdp"]);
                          var apc = data.fold<double>(
                              0,
                              (previousValue, element) =>
                                  previousValue + element.data()["apc"]);
                          var nnpp = data.fold<double>(
                              0,
                              (previousValue, element) =>
                                  previousValue + element.data()["nnpp"]);
                          var others = data.fold<double>(
                              0,
                              (previousValue, element) =>
                                  previousValue +
                                  element.data()["other_parties"]);
                          var total = 334478;
                          return SfCircularChart(
                            title: ChartTitle(
                                text: 'TOTAL NUMBER OF VOTES CASTED'),
                            legend: Legend(isVisible: true),
                            series: <RadialBarSeries<PieData, String>>[
                              RadialBarSeries<PieData, String>(
                                trackBorderColor: Colors.white,
                                dataSource: [
                                  PieData(
                                    "APC",
                                    apc,
                                  ),
                                  PieData(
                                    "NNPP",
                                    nnpp,
                                  ),
                                  PieData(
                                    "PDP",
                                    pdp,
                                  ),
                                  PieData(
                                    "OTHERS",
                                    others,
                                  ),
                                ],
                                maximumValue: total.toDouble(),
                                trackOpacity: 0.1,
                                trackColor: Colors.grey,
                                strokeColor: Colors.blue,
                                xValueMapper: (PieData data, _) => data.xData,
                                yValueMapper: (PieData data, _) => data.yData,
                                dataLabelMapper: (PieData data, _) => data.text,
                                dataLabelSettings:
                                    const DataLabelSettings(isVisible: true),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                )
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Text(
                    "Collation updates".toUpperCase(),
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.78),
                child: StreamBuilder(
                  stream: reportsRef,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    }
                    if (!snapshot.hasData) {
                      return const Text("An error has occured");
                    }
                    var data = snapshot.data!.docs;
                    if (_lga.isNotEmpty) {
                      data = data
                          .where((element) =>
                              element.data()['local_government'] == _lga)
                          .toList();
                    }
                    return SingleChildScrollView(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: ResultsDataTable(
                          dataList: data.map((e) => e.data()).toList(),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
