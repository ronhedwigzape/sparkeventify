import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/user.dart' as model;
import '../providers/darkmode_provider.dart';
import '../resources/auth_methods.dart';
import '../utils/colors.dart';
import '../utils/global.dart';
import '../widgets/cspc_logo.dart';

class AdminScreenLayout extends StatefulWidget {
  const AdminScreenLayout({super.key});

  @override
  State<AdminScreenLayout> createState() => _AdminScreenLayoutState();
}

class _AdminScreenLayoutState extends State<AdminScreenLayout> {
  Future<model.User> currentUser = AuthMethods().getUserDetails();
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
        builder: (context, AsyncSnapshot<model.User> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            model.User? currentUser = snapshot.data;
            return currentUser?.userType == 'Admin'
                ? Scaffold(
              appBar: AppBar(
                automaticallyImplyLeading: false,
                title: const Padding(
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
                ),
                elevation: 0.0,
                backgroundColor: darkModeOn ? darkColor : lightColor,
                actions: [
                  IconButton(
                    onPressed: () => navigationTapped(0),
                    icon: Icon(Icons.dashboard,
                        color: _page == 0
                            ? darkModeOn
                            ? darkModePrimaryColor
                            :  lightModePrimaryColor
                            : darkModeOn
                            ? darkModeSecondaryColor
                            : lightModeSecondaryColor),
                    tooltip: 'Dashboard',
                    padding: const EdgeInsets.symmetric(horizontal: 15.0),
                  ),
                  IconButton(
                    onPressed: () => navigationTapped(1),
                    icon: Icon(Icons.add_circle_sharp,
                        color: _page == 1
                            ? darkModeOn
                            ? darkModePrimaryColor
                            : lightModePrimaryColor
                            : darkModeOn
                            ? darkModeSecondaryColor
                            : lightModeSecondaryColor),
                    tooltip: 'Post',
                    padding: const EdgeInsets.symmetric(horizontal: 15.0),
                  ),
                  IconButton(
                    onPressed: () => navigationTapped(2),
                    icon: Icon(Icons.feed,
                        color: _page == 2
                            ? darkModeOn
                            ? darkModePrimaryColor
                            : lightModePrimaryColor
                            : darkModeOn
                            ? darkModeSecondaryColor
                            : lightModeSecondaryColor),
                    tooltip: 'Edit Events',
                    padding: const EdgeInsets.symmetric(horizontal: 15.0),
                  ),
                  IconButton(
                    onPressed: () => navigationTapped(3),
                    icon: Icon(Icons.supervised_user_circle_sharp,
                        color: _page == 3
                            ? darkModeOn
                            ? darkModePrimaryColor
                            : lightModePrimaryColor
                            : darkModeOn
                            ? darkModeSecondaryColor
                            : lightModeSecondaryColor),
                    tooltip: 'Users',
                    padding: const EdgeInsets.symmetric(horizontal: 15.0),
                  ),
                  IconButton(
                    onPressed: () => navigationTapped(4),
                    icon: Icon(Icons.settings,
                        color: _page == 4
                            ? darkModeOn
                            ? darkModePrimaryColor
                            : lightModePrimaryColor
                            : darkModeOn
                            ? darkModeSecondaryColor
                            : lightModeSecondaryColor),
                    tooltip: 'Settings',
                    padding: const EdgeInsets.symmetric(horizontal: 15.0),
                  ),
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                            40.0, 7.5, 5.0, 7.5),
                        child: CircleAvatar(
                          radius: 13,
                          backgroundImage: NetworkImage(currentUser?.profile?.profileImage ?? 'https://upload.wikimedia.org/wikipedia/commons/thumb/b/b5/Windows_10_Default_Profile_Picture.svg/2048px-Windows_10_Default_Profile_Picture.svg.png'),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                            5.0, 7.5, 50.0, 7.5),
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
              body: FutureBuilder<List<Widget>>(
                future: homeScreenItems(),
                builder: (BuildContext context, AsyncSnapshot<List<Widget>> snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final List<Widget> homeScreenItems = snapshot.data!;
                  return PageView(
                    controller: pageController,
                    onPageChanged: onPageChanged,
                    physics: const NeverScrollableScrollPhysics(),
                    children: homeScreenItems,
                  );
                },
              ),
            )
                : const Center(child: CircularProgressIndicator());
          }
        }
    );
  }
}
