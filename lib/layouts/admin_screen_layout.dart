import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:student_event_calendar/models/user.dart';
import 'package:student_event_calendar/providers/darkmode_provider.dart';
import 'package:student_event_calendar/resources/auth_methods.dart';
import 'package:student_event_calendar/screens/login_screen.dart';
import 'package:student_event_calendar/utils/colors.dart';
import 'package:student_event_calendar/utils/global.dart';
import 'package:student_event_calendar/widgets/cspc_logo.dart';

class AdminScreenLayout extends StatefulWidget {
  const AdminScreenLayout({super.key});

  @override
  State<AdminScreenLayout> createState() => _AdminScreenLayoutState();
}

class _AdminScreenLayoutState extends State<AdminScreenLayout> {
  Future<User> currentUser = AuthMethods().getUserDetails();
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
    return FutureBuilder(
      future: currentUser,
      builder: (context, AsyncSnapshot<User> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          User? currentUser = snapshot.data;
          return currentUser?.userType == 'Admin'
            ? Scaffold(
              appBar: AppBar(
                automaticallyImplyLeading: false,
                title: buildAppBarTitle(),
                elevation: 0.0,
                backgroundColor: darkModeOn ? darkColor : lightColor,
                actions: [
                  buildIconButton(Icons.dashboard, 0, 'Dashboard'),
                  buildIconButton(Icons.add_circle_sharp, 1, 'Post'),
                  buildIconButton(
                      Icons.event_note, 2, 'Edit Events'),
                  buildIconButton(
                      Icons.supervised_user_circle_sharp, 3, 'Users'),
                  buildIconButton(Icons.settings, 4, 'Settings'),
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                            30.0, 7.5, 5.0, 7.5),
                        child: CircleAvatar(
                          radius: 13,
                          backgroundImage: NetworkImage(currentUser
                                  ?.profile?.profileImage ??
                              'https://upload.wikimedia.org/wikipedia/commons/thumb/b/b5/Windows_10_Default_Profile_Picture.svg/2048px-Windows_10_Default_Profile_Picture.svg.png'),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                            5.0, 7.5, 30.0, 7.5),
                        child: Text(
                          currentUser?.profile?.fullName ?? '',
                          style: const TextStyle(
                            color: lightModeSecondaryColor,
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
              body: buildBody(),
            )
          : const Center(child: CircularProgressIndicator());
        }
      }
    );
  }

  Padding buildAppBarTitle() {
    return const Padding(
      padding: EdgeInsets.fromLTRB(30.0, 0, 0, 0),
      child: Row(
        children: [
          CSPCLogo(
            height: 30.0,
          ),
          SizedBox(
            width: 10.0,
          ),
          Text(
            appName,
            style: TextStyle(
              color: lightModeSecondaryColor,
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  IconButton buildIconButton(IconData iconData, int pageIndex, String tooltip) {
    final darkModeOn = Provider.of<DarkModeProvider>(context).darkMode;
    return IconButton(
      onPressed: () => navigationTapped(pageIndex),
      icon: Icon(
        iconData,
        color: _page == pageIndex ?
           (darkModeOn ? darkModePrimaryColor :  lightModePrimaryColor ) : 
          (darkModeOn ? darkModeSecondaryColor : lightModeSecondaryColor),
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
        physics: const AlwaysScrollableScrollPhysics(),
        children: homeScreenItems,
      ),
    );
  }
}
