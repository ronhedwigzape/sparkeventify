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
      appBar: buildAppBar(),
      body: buildBody(),
    );
  }

  AppBar buildAppBar() {
    return AppBar(
      title: buildAppBarTitle(),
      elevation: 0.0,
      backgroundColor: tertiaryColor,
      actions: buildAppBarActions(),
    );
  }

  Row buildAppBarTitle() {
    return const Row(
      children: [
        CSPCLogo(
          height: 30.0,
        ),
        SizedBox(
          width: 10.0,
        ),
        Text(
          adminAppName,
          style: TextStyle(
            color: secondaryColor,
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  List<Widget> buildAppBarActions() {
    return [
      buildIconButton(Icons.dashboard, 0, 'Dashboard'),
      buildIconButton(Icons.add_circle_sharp, 1, 'Add Event'),
      buildIconButton(Icons.event_note, 2, 'Manage Events'),
      buildIconButton(Icons.supervised_user_circle_sharp, 3, 'Manage Users'),
      buildIconButton(Icons.settings, 4, 'Settings'),
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
    ];
  }

  IconButton buildIconButton(IconData iconData, int pageIndex, String tooltip) {
    return IconButton(
      onPressed: () => navigationTapped(pageIndex),
      icon: Icon(
        iconData,
        color: _page == pageIndex ? primaryColor : secondaryColor,
      ),
      tooltip: tooltip,
      padding: const EdgeInsets.symmetric(horizontal: 15.0),
    );
  }

  Container buildBody() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 30.0),
      child: PageView(
        controller: pageController,
        onPageChanged: onPageChanged,
        physics: const NeverScrollableScrollPhysics(),
        children: homeScreenItems,
      ),
    );
  }
}
