import 'package:flutter/material.dart';
import 'package:student_event_calendar/models/user.dart';
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

  _signOut() async {
    return showDialog(
        context: context,
        builder: (context) {
          return SimpleDialog(
            title: Text(
              'Log Out Confirmation',
              style: TextStyle(
                color: Colors.red[900],
                fontWeight: FontWeight.bold,
              ),
            ),
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                child: Text('Are you sure you want to sign out?'),
              ),
              SimpleDialogOption(
                padding: const EdgeInsets.all(20),
                onPressed: () async {
                  await AuthMethods().signOut();
                  if (mounted) {
                    Navigator.of(context).pop();
                    Navigator.of(context).push(MaterialPageRoute(builder: (context) => const LoginScreen()));
                  }
                },
                child: const Text('Yes'),
                ),
              SimpleDialogOption(
                padding: const EdgeInsets.all(20),
                child: const Text('Go Back'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: currentUser,
      builder: (context, AsyncSnapshot<User> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          User? currentUser = snapshot.data;
          return currentUser?.userType == 'Admin' ?
           Scaffold(
            appBar: AppBar(
              title: buildAppBarTitle(),
              elevation: 0.0,
              backgroundColor: tertiaryColor,
              actions: [
                buildIconButton(Icons.dashboard, 0, 'Dashboard'),
                buildIconButton(Icons.add_circle_sharp, 1, 'Post'),
                buildIconButton(Icons.event_note, 2, 'Manage'),
                buildIconButton(Icons.supervised_user_circle_sharp, 3, 'Users'),
                buildIconButton(Icons.settings, 4, 'Settings'),
                IconButton(
                  onPressed: _signOut, 
                  icon: Icon(
                    Icons.logout,
                    color: Colors.red[900]
                  ),
                  tooltip: 'Log out',
                ),                  
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 15.0),
                  child: Text(
                    currentUser?.profile?.fullName ?? '',
                    style: const TextStyle(
                      color: secondaryColor,
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              ],
            ),
            body: buildBody(),
          )
        : const Center(child: CircularProgressIndicator());
        }
      });
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
          appName,
          style: TextStyle(
            color: secondaryColor,
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
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
