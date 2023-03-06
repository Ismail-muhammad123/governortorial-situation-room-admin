import 'package:admin/pages/agents.dart';
import 'package:admin/pages/dashboard.dart';
import 'package:admin/pages/results.dart';
import 'package:admin/pages/settings.dart';
import 'package:admin/pages/splashScreen.dart';
import 'package:admin/pages/units.dart';
import 'package:admin/pages/wards.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../widgets/homeCards.dart';
import '../widgets/menuItems.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  final List<Widget> _pages = const [
    HomeMainTab(),
    Dashboard(),
    ResultsPage(),
    AgentsPage(),
    WardsPage(),
    PolingUnitsPage(),
    // SettingsPage(),
  ];

  int _currentTabIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 240, 240, 240),
      body: Stack(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: double.maxFinite,
                width: 80,
              ),
              Flexible(
                child: Container(
                  width: double.maxFinite,
                  height: double.maxFinite,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      opacity: 0.2,
                      scale: 0.1,
                      image: AssetImage(
                        "images/assembly.png",
                      ),
                    ),
                  ),
                  child: _pages[_currentTabIndex],
                ),
              )
            ],
          ),
          Container(
            width: 80,
            height: MediaQuery.of(context).size.height,
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(15),
                bottomRight: Radius.circular(15),
              ),
              boxShadow: [
                BoxShadow(
                    color: Colors.grey.withOpacity(0.4),
                    offset: const Offset(2, 2),
                    blurRadius: 12.0),
              ],
            ),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: GestureDetector(
                      onTap: () => setState(() {
                        _currentTabIndex = 0;
                      }),
                      child: Image.asset(
                        "images/logo.png",
                        height: 50,
                        width: 50,
                      ),
                    ),
                  ),
                  const Divider(
                    color: Colors.green,
                    thickness: 3,
                  ),
                  GestureDetector(
                    onTap: () => setState(() {
                      _currentTabIndex = 1;
                    }),
                    child: SideMenuItem(
                      label: "Dashboard",
                      menuIconData: Icons.dashboard_rounded,
                      selected: _currentTabIndex == 1,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => setState(() {
                      _currentTabIndex = 2;
                    }),
                    child: SideMenuItem(
                      label: "Results",
                      menuIconData: Icons.upload_file,
                      selected: _currentTabIndex == 2,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => setState(() {
                      _currentTabIndex = 3;
                    }),
                    child: SideMenuItem(
                      selected: _currentTabIndex == 3,
                      label: "Agents",
                      menuIconData: Icons.person,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => setState(() {
                      _currentTabIndex = 4;
                    }),
                    child: SideMenuItem(
                      label: "Wards",
                      selected: _currentTabIndex == 4,
                      menuIconData: Icons.location_city,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => setState(() {
                      _currentTabIndex = 5;
                    }),
                    child: SideMenuItem(
                      label: "Polling Units",
                      selected: _currentTabIndex == 5,
                      menuIconData: Icons.location_pin,
                    ),
                  ),
                  // GestureDetector(
                  //   onTap: () => setState(() {
                  //     _currentTabIndex = 6;
                  //   }),
                  //   child: SideMenuItem(
                  //       label: "Settings",
                  //       selected: _currentTabIndex == 6,
                  //       menuIconData: Icons.settings),
                  // ),
                  SizedBox(
                    height: 20,
                  ),
                  GestureDetector(
                    onTap: () => showDialog(
                      barrierDismissible: false,
                      context: context,
                      builder: (context) => AlertDialog(
                        icon: const Icon(Icons.warning),
                        iconColor: Colors.red,
                        content: const Text("Are you sure you want to logout?"),
                        actions: [
                          MaterialButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            color: Colors.grey,
                            child: const Text("No"),
                          ),
                          MaterialButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            color: Colors.red,
                            child: const Text("Yes"),
                          ),
                        ],
                      ),
                    ).then(
                      (value) => value
                          ? FirebaseAuth.instance.signOut()
                          : setState(() {}),
                    ),
                    child: const SideMenuItem(
                      label: "Logout",
                      menuIconData: Icons.logout,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class HomeMainTab extends StatelessWidget {
  const HomeMainTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Spacer(),
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
                    child: Icon(Icons.person),
                  ),
                ),
                Text(FirebaseAuth.instance.currentUser?.email ?? ""),
              ],
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Flexible(
                child: HomePageCard(
                  party: "apc",
                  ref: "Muntari ishaq",
                  cardColor: const Color.fromARGB(255, 5, 92, 163),
                ),
              ),
              Flexible(
                child: HomePageCard(
                  party: "nnpp",
                  ref: "Engr. Sagir Koki",
                  cardColor: Colors.red,
                ),
              ),
              Flexible(
                child: HomePageCard(
                  party: "pdp",
                  ref: "Engr. Yusuf Abdullahi Da’awah",
                  cardColor: Colors.green,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
