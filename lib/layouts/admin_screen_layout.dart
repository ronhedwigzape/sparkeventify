import 'package:flutter/material.dart';
import 'package:student_event_calendar/utils/colors.dart';
import 'package:student_event_calendar/utils/global.dart';
import 'package:student_event_calendar/widgets/cspc_logo.dart';

class AdminScreenLayout extends StatefulWidget {
  const AdminScreenLayout({super.key});

  @override
  State<AdminScreenLayout> createState() => _AdminScreenLayoutState();
}

class _AdminScreenLayoutState extends State<AdminScreenLayout> {
  int _page = 0;
  PageController pageController = PageController();

  @override
  void initState() {
    super.initState();
    pageController = PageController();
  }

  @override
  void dispose() {
    super.dispose();
    pageController.dispose();
  }

  void navigationTapped(int page) {
    setState(() {
      _page = page;
    });
    pageController.jumpToPage(page);
  }

  void onPageChanged(int page) {
    setState(() {
      _page = page;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            CSPCLogo(
              height: 30.0,
            ),
            SizedBox(
              width: 10.0,
            ),
            Text(
              'CSPC Event Calendar Administrator',
              style: TextStyle(
                color: secondaryColor,
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        elevation: 0.0,
        backgroundColor: tertiaryColor,
        actions: [
          IconButton(
            onPressed: () => navigationTapped(0),
            icon: Icon(
              Icons.dashboard,
              color: _page == 0 ? primaryColor : secondaryColor,
            ),
            tooltip: 'Dashboard',
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
          ),
          IconButton(
            onPressed: () => navigationTapped(1),
            icon: Icon(
              Icons.add_circle_sharp,
              color: _page == 1 ? primaryColor : secondaryColor,
            ),
            tooltip: 'Add Event',
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
          ),
          IconButton(
            onPressed: () => navigationTapped(2),
            icon: Icon(
              Icons.event_note,
              color: _page == 2 ? primaryColor : secondaryColor,
            ),
            tooltip: 'Manage Events',
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
          ),
          IconButton(
            onPressed: () => navigationTapped(3),
            icon: Icon(
              Icons.supervised_user_circle_sharp,
              color: _page == 3 ? primaryColor : secondaryColor,
            ),
            tooltip: 'Manage Users',
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
          ),
          IconButton(
            onPressed: () => navigationTapped(4),
            icon: Icon(
              Icons.settings,
              color: _page == 4 ? primaryColor : secondaryColor,
            ),
            tooltip: 'Settings',
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 40.0, vertical: 15.0),
            child: Text(
              'AdminName',
              style: TextStyle(
                color: secondaryColor,
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          )
        ],
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 30.0),
        child: PageView(
          controller: pageController,
          onPageChanged: onPageChanged,
          physics: const NeverScrollableScrollPhysics(),
          children: homeScreenItems,
        ),
      ),
    );
  }
}
