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
    final darkModeOn = Provider.of<DarkModeProvider>(context).darkMode;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: darkModeOn ? darkModePrimaryColor : lightModePrimaryColor,
        elevation: 0.0,
        title: Row(
          children: [
            const CSPCLogo(height: 30.0),
            const SizedBox(
              width: 10.0,
            ),
            Text(
              appName,
              style: TextStyle(
                color: lightColor,
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
                shadows: darkModeOn ? <Shadow>[
                  const Shadow(
                    offset: Offset(1.0, 1.0),
                    blurRadius: 1.0,
                    color: darkModePrimaryColor,
                  ),
                  const Shadow(
                    offset: Offset(1.0, 1.0),
                    blurRadius: 8.0,
                    color: lightModeBlueColor,
                  ),
                ] : null,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () => navigationTapped(4),
            icon: const Icon(
              Icons.notifications,
              color: lightColor,
            ),
          )
        ],
      ),
      body: PageView(
        controller: pageController,
        onPageChanged: onPageChanged,
        physics: const NeverScrollableScrollPhysics(),
        children: homeScreenItems,
      ),
      bottomNavigationBar: CupertinoTabBar(
        onTap: navigationTapped,
        backgroundColor: darkModeOn ? darkColor : lightColor,
        activeColor: darkModeOn ? lightColor : darkColor,
        items: [
          buildBottomNavigationBarItem(Icons.calendar_month, 0),
          buildBottomNavigationBarItem(Icons.feedback, 1),
          buildBottomNavigationBarItem(Icons.note_alt, 2),
          buildBottomNavigationBarItem(Icons.person, 3),
        ],
      ),
    );
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
