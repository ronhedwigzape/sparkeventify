import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:student_event_calendar/widgets/cspc_logo_white.dart';
import 'package:student_event_calendar/widgets/custom_spinner.dart';
import '../models/user.dart' as model;
import '../providers/darkmode_provider.dart';
import '../resources/auth_methods.dart';
import '../utils/colors.dart';
import '../utils/global.dart';

class AdminScreenLayout extends StatefulWidget {
  const AdminScreenLayout({super.key});

  @override
  State<AdminScreenLayout> createState() => _AdminScreenLayoutState();
}

class _AdminScreenLayoutState extends State<AdminScreenLayout> {
  Future<model.User?> currentUser = AuthMethods().getCurrentUserDetails();
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
        builder: (context, AsyncSnapshot<model.User?> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CustomSpinner());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            model.User? currentUser = snapshot.data;
            return currentUser?.userType == 'Admin'
                ? Scaffold(
              appBar: AppBar(
                automaticallyImplyLeading: false,
                title: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10.0),
                  child: Row(
                    children: [
                      CSPCLogoWhite(
                        height: 30.0,
                      ),
                      SizedBox(
                        width: 20.0,
                      ),
                      Expanded(
                        child: Text(
                          appName,
                          style: TextStyle(
                            color: lightModeSecondaryColor,
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                elevation: 0.0,
                backgroundColor: darkModeOn ? darkColor : lightColor,
                actions: [
                  buildAppBarButton(icon: Icons.dashboard, label: "Dashboard", pageIndex: 0, onTap: () => navigationTapped(0)),
                  const SizedBox(width: 10.0),
                  buildAppBarButton(icon: Icons.add_circle, label: "Post", pageIndex: 1, onTap: () => navigationTapped(1)),
                  const SizedBox(width: 10.0),
                  buildAppBarButton(icon: Icons.event, label: "Events", pageIndex: 2, onTap: () => navigationTapped(2)),
                  const SizedBox(width: 10.0),
                  buildAppBarButton(icon: Icons.group, label: "Users", pageIndex: 3, onTap: () => navigationTapped(3)),
                  const SizedBox(width: 10.0),
                  buildAppBarButton(icon: Icons.feedback, label: "Feedbacks", pageIndex: 4, onTap: () => navigationTapped(4)),
                  const SizedBox(width: 10.0),
                  buildAppBarButton(icon: Icons.settings, label: "Settings", pageIndex: 5, onTap: () => navigationTapped(5)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30.0),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: darkModeOn ? lightColor : darkColor,
                          radius: 8.0,
                          child: Icon(Icons.person, color: darkModeOn ? darkColor : lightColor, size: 14,)
                        ),
                        const SizedBox(width: 10.0),
                        Text(
                          currentUser?.profile?.fullName ?? '',
                          style: TextStyle(
                            color: darkModeOn ? lightColor : darkColor,
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 10.0),
                        CircleAvatar(
                          radius: 13,
                          backgroundImage: NetworkImage(currentUser?.profile?.profileImage ?? 'https://upload.wikimedia.org/wikipedia/commons/thumb/b/b5/Windows_10_Default_Profile_Picture.svg/2048px-Windows_10_Default_Profile_Picture.svg.png'),
                          backgroundColor: transparent,
                        ),
                      ],
                    ),
                  )
                ],
              ),
              body: FutureBuilder<List<Widget>>(
                future: homeScreenItems(),
                builder: (BuildContext context, AsyncSnapshot<List<Widget>> snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CustomSpinner());
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
                : const Center(child: CustomSpinner());
          }
        }
    );
  }
  // appBarButton Builder
  Widget buildAppBarButton({required IconData icon, required String label, required int pageIndex, VoidCallback? onTap}){
    final darkModeOn = Provider.of<DarkModeProvider>(context).darkMode;
    final color = _page == pageIndex
                ? darkModeOn
                ? darkModePrimaryColor
                :  lightModePrimaryColor
                : darkModeOn
                ? darkModeSecondaryColor
                : lightModeSecondaryColor;

    return TextButton.icon(
      onPressed: onTap,
      icon: Icon(icon, color: color),
      label: Text(
        label,
        style: TextStyle(color: color),
      ),
    );
  }
}


