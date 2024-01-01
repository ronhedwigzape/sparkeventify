import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:student_event_calendar/resources/firestore_event_methods.dart';
import 'package:student_event_calendar/services/firebase_notifications.dart';
import 'package:student_event_calendar/widgets/cspc_logo_white.dart';
import 'package:student_event_calendar/widgets/cspc_spinner.dart';
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
  final firestoreNotification = FirebaseNotificationService();
  final firestoreEventMethods = FireStoreEventMethods();
  late Stream<int> notificationCount;
  int _page = 0;
  PageController pageController = PageController();
  late var _refreshKey = UniqueKey();
  late Stream<int> pendingCount;

  @override
  void initState() {
    super.initState();
    pageController = PageController();
    notificationCount = firestoreNotification.getUnreadNotificationCount(
      FirebaseAuth.instance.currentUser?.uid ?? '',
    );
    pendingCount = firestoreEventMethods.getPendingEventsCount();
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
            return const Center(child: CSPCFadeLoader());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            model.User? currentUser = snapshot.data;
            String? userType = currentUser?.userType;
            return Scaffold(
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
                  IconButton(
                    onPressed: () => setState(() {
                    _refreshKey = UniqueKey();
                    navigationTapped(0);
                  }),
                  tooltip: 'Refresh', 
                  icon: Icon(
                    Icons.refresh, 
                    color: darkModeOn ? lightColor : darkColor),
                  ),
                  const SizedBox(width: 10.0),
                  userType == 'Admin' || userType == 'SuperAdmin'
                    ? buildAppBarButton(
                        icon: Icons.dashboard, 
                        label: "Dashboard", 
                        pageIndex: 0, 
                        onTap: () => navigationTapped(0)
                      )
                    : const SizedBox.shrink(),
                  userType == 'Admin' 
                    ? const SizedBox(width: 10.0) 
                    : const SizedBox.shrink(),
                  userType == 'Admin' 
                    ? buildAppBarButton(
                        icon: Icons.add_circle, 
                        label: "Post", 
                        pageIndex: 1, 
                        onTap: () => navigationTapped(1)
                      )
                    : const SizedBox.shrink(),
                  userType == 'Admin' 
                    ? const SizedBox(width: 10.0) 
                    : const SizedBox.shrink(),
                  userType == 'Admin' 
                    ? buildAppBarButton(
                        icon: Icons.event, 
                        label: "Events", 
                        pageIndex: 2, 
                        onTap: () => navigationTapped(2)
                      )
                    : const SizedBox.shrink(),
                  userType == 'Admin' 
                    ? const SizedBox(width: 10.0)
                    : const SizedBox.shrink(),
                  userType == 'Admin' 
                    ? buildAppBarButton(
                        icon: Icons.group, 
                        label: "Users", 
                        pageIndex: 3, 
                        onTap: () => navigationTapped(3)
                      )
                    : const SizedBox.shrink(),
                  userType == 'Admin' 
                    ? const SizedBox(width: 10.0) 
                    : const SizedBox.shrink(),
                  userType == 'Admin' 
                    ? buildAppBarButton(
                        icon: Icons.feedback, 
                        label: "Feedbacks", 
                        pageIndex: 4, 
                        onTap: () => navigationTapped(4)
                      )
                    : const SizedBox.shrink(),
                  const SizedBox(width: 10.0),
                  userType == 'Admin' || userType == 'SuperAdmin'
                    ? buildAppBarButton(
                        icon: Icons.settings, 
                        label: "Settings",
                        pageIndex: 5, 
                        onTap: () => navigationTapped(5)
                      )
                    : const SizedBox.shrink(),
                    const SizedBox(width: 10.0),
                  userType == 'Admin' 
                    ? IconButton(
                        onPressed: () => navigationTapped(6),
                        icon: Stack(
                          children: <Widget>[
                            Icon(
                              Icons.event_busy,
                              color: darkModeOn ? darkModeSecondaryColor : lightModeSecondaryColor,
                            ),
                            StreamBuilder<int>(
                              stream: pendingCount,
                              builder:
                                  (BuildContext context, AsyncSnapshot<int> snapshot) {
                                if (!snapshot.hasData) {
                                  return const SizedBox.shrink();
                                }
                                final int count = snapshot.data!;
                                return count == 0
                                    ? const SizedBox.shrink()
                                    : Positioned(
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
                      ) : const SizedBox.shrink(),
                  userType == 'Admin' 
                  ? const SizedBox(width: 10.0)
                  : const SizedBox.shrink(),
                  userType == 'Admin' || userType == 'SuperAdmin'
                  ? IconButton(
                    onPressed: () => navigationTapped(7),
                    icon: Stack(
                      children: <Widget>[
                        Icon(
                          Icons.notifications,
                          color: darkModeOn ? darkModeSecondaryColor : lightModeSecondaryColor,
                        ),
                        StreamBuilder<int>(
                          stream: notificationCount,
                          builder:
                              (BuildContext context, AsyncSnapshot<int> snapshot) {
                            if (!snapshot.hasData) {
                              return const SizedBox.shrink();
                            }
                            final int count = snapshot.data!;
                            return count == 0
                                ? const SizedBox.shrink()
                                : Positioned(
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
                    ) : const SizedBox.shrink(),

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
                key: _refreshKey,
                future: homeScreenItems(),
                builder: (BuildContext context, AsyncSnapshot<List<Widget>> snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CSPCFadeLoader());
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
            );
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


