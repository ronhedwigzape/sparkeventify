import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:student_event_calendar/utils/colors.dart';
import 'package:student_event_calendar/utils/global.dart';

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
    // model.User? user = Provider.of<UserProvider>(context).getUser;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryCOlor,
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.settings),
          ),
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
          backgroundColor: backgroundColor,
          items: [
            BottomNavigationBarItem(
                icon: Icon(
                  Icons.home,
                  color: _page == 0 ? primaryCOlor : secondaryColor,
                ),
                label: '',
                backgroundColor: whiteColor),
            BottomNavigationBarItem(
                icon: Icon(
                  Icons.calendar_month,
                  color: _page == 1 ? primaryCOlor : secondaryColor,
                ),
                label: '',
                backgroundColor: whiteColor),
            BottomNavigationBarItem(
                icon: Icon(
                  Icons.sticky_note_2_outlined,
                  color: _page == 2 ? primaryCOlor : secondaryColor,
                ),
                label: '',
                backgroundColor: whiteColor),
            BottomNavigationBarItem(
                icon: Icon(
                  Icons.favorite,
                  color: _page == 3 ? primaryCOlor : secondaryColor,
                ),
                label: '',
                backgroundColor: whiteColor),
            BottomNavigationBarItem(
                icon: Icon(
                  Icons.person,
                  color: _page == 4 ? primaryCOlor : secondaryColor,
                ),
                label: '',
                backgroundColor: whiteColor),
          ]),
    );
  }
}
