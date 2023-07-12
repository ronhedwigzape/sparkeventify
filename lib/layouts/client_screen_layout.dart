import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:student_event_calendar/utils/colors.dart';
import 'package:student_event_calendar/utils/global.dart';
import 'package:student_event_calendar/widgets/cspc_logo.dart';

class ClientScreenLayout extends StatefulWidget {
  const ClientScreenLayout({Key? key}) : super(key: key);

  @override
  State<ClientScreenLayout> createState() => _ClientScreenLayoutState();
}

class _ClientScreenLayoutState extends State<ClientScreenLayout> {
  int _page = 0;
  PageController pageController = PageController();
  Stream<QuerySnapshot>? homeScreenItemsStream;

  @override
  void initState() {
    super.initState();
    pageController = PageController();
    homeScreenItemsStream =
        FirebaseFirestore.instance.collection('events').snapshots();
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
      appBar: buildAppBar(),
      body: buildBody(),
      bottomNavigationBar: buildBottomNavigationBar(),
    );
  }

  AppBar buildAppBar() {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: primaryColor,
      elevation: 0.0,
      title: buildAppBarTitle(),
      actions: buildAppBarActions(),
    );
  }

  Row buildAppBarTitle() {
    return const Row(
      children: [
        CSPCLogo(height: 30.0),
        SizedBox(
          width: 10.0,
        ),
        Text(
          appName,
          style: TextStyle(
            color: whiteColor,
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  List<Widget> buildAppBarActions() {
    return [
      IconButton(
        onPressed: () {},
        icon: const Icon(Icons.notifications),
      )
    ];
  }

 PageView buildBody() {
    return PageView(
      controller: pageController,
      onPageChanged: onPageChanged,
      physics: const NeverScrollableScrollPhysics(),
      children: homeScreenItems,
    );
  }


  CupertinoTabBar buildBottomNavigationBar() {
    return CupertinoTabBar(
      onTap: navigationTapped,
      backgroundColor: backgroundColor,
      items: buildBottomNavigationBarItems(),
    );
  }

  List<BottomNavigationBarItem> buildBottomNavigationBarItems() {
    return [
      buildBottomNavigationBarItem(Icons.home, 0),
      buildBottomNavigationBarItem(Icons.calendar_month, 1),
      buildBottomNavigationBarItem(Icons.announcement, 2),
      buildBottomNavigationBarItem(Icons.note_alt, 3),
      buildBottomNavigationBarItem(Icons.person, 4),
    ];
  }

  BottomNavigationBarItem buildBottomNavigationBarItem(
      IconData iconData, int pageIndex) {
    return BottomNavigationBarItem(
      icon: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0),
        child: Icon(
          iconData,
          color: _page == pageIndex ? primaryColor : secondaryColor,
        ),
      ),
      label: '',
      backgroundColor: whiteColor,
    );
  }
}
