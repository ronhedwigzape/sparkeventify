import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/profile.dart' as model;
import '../models/user.dart' as model;
import '../providers/darkmode_provider.dart';
import '../utils/colors.dart';

class UsersCard extends StatefulWidget {
  final model.User user;
  final List<String> selectedUsers;
  final ValueChanged<String> onSelectedChanged;

  const UsersCard({
    super.key,
    required this.user,
    required this.selectedUsers,
    required this.onSelectedChanged
  });

  @override
  State<UsersCard> createState() => _UsersCardState();
}

class _UsersCardState extends State<UsersCard> {
  @override
  Widget build(BuildContext context) {
    final darkModeOn = Provider.of<DarkModeProvider>(context).darkMode;
    model.Profile currentProfile = widget.user.profile ?? model.Profile();

    return widget.user.userType != 'Admin' ?
    Column(
      children: <Widget>[
         Card(
           color: darkModeOn ? darkColor : lightColor,
           child: Padding(
             padding: const EdgeInsets.all(10.0),
             child: Row(
                children: [
                  Flexible(
                    child:Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Flexible(
                          child: Column(
                            children: [
                              CircleAvatar(
                                backgroundImage: NetworkImage(currentProfile.profileImage ?? 'https://upload.wikimedia.org/wikipedia/commons/thumb/b/b5/Windows_10_Default_Profile_Picture.svg/2048px-Windows_10_Default_Profile_Picture.svg.png'),
                                backgroundColor: darkColor,
                              ),
                              Text(currentProfile.fullName ?? 'N/A'),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Row(
                            children: [
                              Flexible(
                                  child: Column(
                                    children: [
                                      Text('Email: ${widget.user.email}'),
                                      Text('Phone: ${currentProfile.phoneNumber ?? 'N/A'}'),]
                                  )

                              ),
                             Flexible(
                                 child: Column(
                                   children: [
                                     Text('Department: ${currentProfile.department ?? 'N/A'}'),
                                     Text('Year: ${currentProfile.year ?? 'N/A'}'),
                                     Text('Section: ${currentProfile.section ?? 'N/A'}'),
                                     Text('Course: ${currentProfile.course ?? 'N/A'}'),
                                   ],
                                 )
                             )
                            ],
                          ),
                        ),
                        Flexible(
                          child: CheckboxListTile(
                            title: Text(widget.user.email),
                            value: widget.selectedUsers.contains(widget.user.uid),
                            onChanged: (bool? value) {
                              widget.onSelectedChanged(widget.user.uid);
                            },
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
           ),
         ),
      ],
    ) : const SizedBox.shrink();
  }
}
