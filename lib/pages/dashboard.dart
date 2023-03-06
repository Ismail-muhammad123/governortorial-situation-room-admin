import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
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
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    height: 250,
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
                          var pdp = snapshot.data!.docs.fold<double>(
                              0,
                              (previousValue, element) =>
                                  previousValue + element.data()["pdp"]);
                          var apc = snapshot.data!.docs.fold<double>(
                              0,
                              (previousValue, element) =>
                                  previousValue + element.data()["apc"]);
                          var nnpp = snapshot.data!.docs.fold<double>(
                              0,
                              (previousValue, element) =>
                                  previousValue + element.data()["nnpp"]);
                          var total = 334478;
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              ProgressBarWidget(
                                label: "ENGR. YUSUF ABDULLAHI AHMAD",
                                maxValue: total.toDouble(),
                                value: pdp,
                                backgroundColor:
                                    const Color.fromARGB(255, 218, 218, 218),
                                progressColor: Colors.red,
                              ),
                              ProgressBarWidget(
                                label: "MUNTARI ISHAQ",
                                maxValue: total.toDouble(),
                                value: apc,
                                backgroundColor:
                                    const Color.fromARGB(255, 218, 218, 218),
                                progressColor: Colors.green,
                              ),
                              ProgressBarWidget(
                                label: "ENGR. SAGIR KOKI",
                                maxValue: total.toDouble(),
                                value: nnpp,
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
                      height: 250,
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
                          var pdp = snapshot.data!.docs.fold<double>(
                              0,
                              (previousValue, element) =>
                                  previousValue + element.data()["pdp"]);
                          var apc = snapshot.data!.docs.fold<double>(
                              0,
                              (previousValue, element) =>
                                  previousValue + element.data()["apc"]);
                          var nnpp = snapshot.data!.docs.fold<double>(
                              0,
                              (previousValue, element) =>
                                  previousValue + element.data()["nnpp"]);
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
                                    "PDP",
                                    pdp,
                                  ),
                                  PieData(
                                    "APC",
                                    apc,
                                  ),
                                  PieData(
                                    "NNPP",
                                    nnpp,
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
                    return SingleChildScrollView(
                      child: ResultsDataTable(
                        dataList:
                            snapshot.data!.docs.map((e) => e.data()).toList(),
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
