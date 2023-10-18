import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:student_event_calendar/providers/darkmode_provider.dart';
import 'package:student_event_calendar/resources/auth_methods.dart';
import 'package:student_event_calendar/services/firebase_notifications.dart';
import 'package:student_event_calendar/utils/colors.dart';
import 'package:student_event_calendar/utils/global.dart';
import 'package:student_event_calendar/widgets/cspc_logo_white.dart';

class ClientScreenLayout extends StatefulWidget {
  const ClientScreenLayout({Key? key}) : super(key: key);

  @override
  State<ClientScreenLayout> createState() => _ClientScreenLayoutState();
}

class _ClientScreenLayoutState extends State<ClientScreenLayout> {
  int _page = 0;
  PageController pageController = PageController();
  final firestoreNotification = FirebaseNotificationService();
  late Stream<int> notificationCount;

  // Define app names for each user type
  final List<String> appNamesForStaff = ['Calendar of Events', 'Post Announcement', 'Manage Events', 'Profile', '', 'Notifications'];
  final List<String> appNamesForOfficer = ['Calendar of Events', 'Feedbacks', 'Post Announcement', 'Manage Events', 'Profile', 'Notifications'];
  final List<String> appNamesForStudent = ['Calendar of Events', 'Feedbacks', 'Personal Events', 'Profile', '', 'Notifications'];
  
  String currentAppName = 'Calendar of Events'; // Set initial app name
  
  Future<String> getUserType() async {
    return await AuthMethods().getCurrentUserType();
  }

  @override
  void initState() {
    super.initState();
    pageController = PageController();
    notificationCount = firestoreNotification.getUnreadNotificationCount(
      FirebaseAuth.instance.currentUser?.uid ?? '',
    );
  }

  @override
  void dispose() {
    super.dispose();
    pageController.dispose();
  }

  Future navigationTapped(int page) async {
    String userType = await getUserType();
    // Update current app name when navigation item is clicked
    setState(() {
      _page = page;
      if (userType == 'Staff') {
          currentAppName = appNamesForStaff[page];
      } else if (userType == 'Officer') {
          currentAppName = appNamesForOfficer[page];
      } else {
          currentAppName = appNamesForStudent[page];
      }
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
    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: darkModeOn ? darkModePrimaryColor : lightModePrimaryColor,
          elevation: 0.0,
          title: Row(
            children: [
              const CSPCLogoWhite(height: 30.0),
              const SizedBox(
                width: 10.0,
              ),
              Text(
                currentAppName,
                style: const TextStyle(
                  color: lightColor,
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              )
            ],
          ),
          actions: [
            IconButton(
              onPressed: () => navigationTapped(5),
              icon: Stack(
                children: <Widget>[
                  const Icon(
                    Icons.notifications,
                    color: lightColor,
                  ),
                 StreamBuilder<int>(
                  stream: notificationCount,
                  builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
                    if (!snapshot.hasData) {
                      return const SizedBox.shrink();
                    }
                    final int count = snapshot.data!;
                    return count == 0 ? const SizedBox.shrink() : 
                    Positioned(
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(1),
                        decoration: BoxDecoration(
                          color: red,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 12,
                          minHeight: 12,
                        ),
                        child: Text(
                          count.toString(),
                          style: const TextStyle(
                            color: white,
                            fontSize: 8,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  },
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
                return Center(child: CircularProgressIndicator(color: darkModeOn ? darkModePrimaryColor : lightModePrimaryColor));
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
          bottomNavigationBar: FutureBuilder<String>(
            future: AuthMethods().getCurrentUserType(),
            builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
              String userType = snapshot.data ?? '';
              return CupertinoTabBar(
                onTap: navigationTapped,
                backgroundColor: darkModeOn ? darkColor : lightColor,
                activeColor: darkModeOn ? lightColor : darkColor,
                items: userType == 'Staff' ? [
                  buildBottomNavigationBarItem(Icons.calendar_month, 0),
                  buildBottomNavigationBarItem(Icons.add_circle, 1),
                  buildBottomNavigationBarItem(Icons.note_alt, 2),
                  buildBottomNavigationBarItem(Icons.person, 3)
                ] : userType == 'Officer' ? [
                  buildBottomNavigationBarItem(Icons.calendar_month, 0),
                  buildBottomNavigationBarItem(Icons.feedback, 1),
                  buildBottomNavigationBarItem(Icons.add_circle, 2),
                  buildBottomNavigationBarItem(Icons.note_alt, 3),
                  buildBottomNavigationBarItem(Icons.person, 4)
                ] : [
                  buildBottomNavigationBarItem(Icons.calendar_month, 0),
                  buildBottomNavigationBarItem(Icons.feedback, 1),
                  buildBottomNavigationBarItem(Icons.note_alt, 2),
                  buildBottomNavigationBarItem(Icons.person, 3)
                ],
              );
            },
          ),
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
