import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:student_event_calendar/providers/darkmode_provider.dart';
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
      appBar: buildAppBar(),
      body: buildBody(),
      bottomNavigationBar: buildBottomNavigationBar(),
    );
  }

  AppBar buildAppBar() {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: lightModePrimaryColor,
      elevation: 0.0,
      title: buildAppBarTitle(),
      actions: buildAppBarActions(5),
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
            color: lightColor,
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  List<Widget> buildAppBarActions(int pageIndex) {
    return [
      IconButton(
        onPressed: () => navigationTapped(pageIndex),
        icon: const Icon(
          Icons.notifications,
          color: lightColor,
        ),
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
    final darkModeOn = Provider.of<DarkModeProvider>(context).darkMode;
    return CupertinoTabBar(
      onTap: navigationTapped,
      backgroundColor: darkModeOn ? darkColor : lightColor,
      activeColor: darkModeOn ? lightColor : darkColor,
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

  BottomNavigationBarItem buildBottomNavigationBarItem(IconData iconData, int pageIndex) {
    final darkModeOn = Provider.of<DarkModeProvider>(context).darkMode;
    return BottomNavigationBarItem(
      icon: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0),
        child: Icon(
          iconData,
          color: _page == pageIndex ? 
          (darkModeOn ? darkModePrimaryColor :  lightModePrimaryColor ) : 
          (darkModeOn ? darkModeSecondaryColor : lightModeSecondaryColor),
        ),
      ),
      backgroundColor: lightColor,
    );
  }
}
