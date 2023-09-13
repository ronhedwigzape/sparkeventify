import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:student_event_calendar/widgets/edit_user_dialog.dart';

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
             padding: const EdgeInsets.all(20.0),
             child: Row(
               children: [
                 Flexible(
                   child: Row(
                     mainAxisAlignment: MainAxisAlignment.spaceAround,
                     children: [
                       Flexible(
                         flex: 3,
                         child: Column(
                           children: [
                             CircleAvatar(
                               radius: 30,
                               backgroundImage: NetworkImage(
                              (currentProfile.profileImage == null || currentProfile.profileImage!.isEmpty)
                                    ? 'https://upload.wikimedia.org/wikipedia/commons/thumb/b/b5/Windows_10_Default_Profile_Picture.svg/2048px-Windows_10_Default_Profile_Picture.svg.png'
                                    : currentProfile.profileImage!
                                ),
                               backgroundColor: darkColor,
                             ),
                             const SizedBox(height: 10.0),
                             RichText(
                              text: TextSpan(
                                style: DefaultTextStyle.of(context).style,
                                children: <TextSpan>[
                                  TextSpan(text: '${currentProfile.fullName ?? 'N/A'} - '),
                                  TextSpan(text: widget.user.userType, style: const TextStyle(fontWeight: FontWeight.bold)),
                                ],
                              ),
                            )
                           ],
                         ),
                       ),
                       Flexible(
                         flex: 4,
                         child: Row(
                           children: [
                             Expanded(
                               flex: 3,
                               child: Column(
                                 crossAxisAlignment: CrossAxisAlignment.start,
                                 children: [
                                   Row(
                                     children: [
                                       const Icon(Icons.email, size: 18,),
                                       const SizedBox(width: 10.0,),
                                       Text(widget.user.email ?? '', 
                                       style: TextStyle(
                                         height: 2,
                                         fontSize: 18,
                                         color: darkModeOn ? darkModeSecondaryColor : lightModeSecondaryColor
                                         ),
                                       ),
                                     ],
                                   ),
                                   Row(
                                     children: [
                                       const Icon(Icons.phone, size: 18,),
                                       const SizedBox(width: 10.0,),
                                       Text('+${currentProfile.phoneNumber ?? 'N/A'}', 
                                       style: TextStyle(
                                         height: 2,
                                         fontSize: 18,
                                         color: darkModeOn ? darkModeSecondaryColor : lightModeSecondaryColor
                                         )
                                       ),
                                     ],
                                   ),]
                               )
                             ),
                           Expanded(
                               flex: 2,
                               child: Column(
                                 crossAxisAlignment: CrossAxisAlignment.start,
                                 children: [
                                   if (widget.user.userType == 'Student' || widget.user.userType == 'Officer')
                                     ...[
                                       Row(
                                         children: [
                                           const Text('Department:'),
                                           const SizedBox(width: 10.0,),
                                           Text(currentProfile.department ?? 'N/A', 
                                           style: TextStyle(color: darkModeOn ? darkModeSecondaryColor : lightModeSecondaryColor)),
                                         ],
                                       ),
                                       Row(
                                         children: [
                                           const Text('Year:'),
                                           const SizedBox(width: 10.0,),
                                           Text(currentProfile.year ?? 'N/A', 
                                           style: TextStyle(color: darkModeOn ? darkModeSecondaryColor : lightModeSecondaryColor)),
                                         ],
                                       ),
                                       Row(
                                         children: [
                                           const Text('Section:'),
                                           const SizedBox(width: 10.0,),
                                           Text(currentProfile.section ?? 'N/A', 
                                           style: TextStyle(color: darkModeOn ? darkModeSecondaryColor : lightModeSecondaryColor)),
                                         ],
                                       ),
                                       Row(
                                         children: [
                                           const Text('Course:'),
                                           const SizedBox(width: 10.0,),
                                           Text(currentProfile.course ?? 'N/A', 
                                           style: TextStyle(color: darkModeOn ? darkModeSecondaryColor : lightModeSecondaryColor)),
                                         ],
                                       ),
                                     ],
                                   if (widget.user.userType == 'Staff')
                                     ...[
                                      Row(
                                         children: [
                                           const Text('Position:'),
                                           const SizedBox(width: 10.0,),
                                           Text(currentProfile.position ?? 'N/A', 
                                           style: TextStyle(color: darkModeOn ? darkModeSecondaryColor : lightModeSecondaryColor)),
                                         ],
                                       ),
                                     ],
                                   if (widget.user.userType != 'Student' && widget.user.userType != 'Officer' && widget.user.userType != 'Staff')
                                     const Text('User type not found!'),
                                 ],
                               ),
                             ),
                           ],
                         ),
                       ),
                       Flexible(
                        flex: 1,
                        fit: FlexFit.loose,
                        child: EditUserDialog(user: widget.user)
                       ),
                       Flexible(
                         flex: 1,
                         child: CheckboxListTile(
                           activeColor: darkModeOn ? darkModePrimaryColor : lightModePrimaryColor,
                           checkColor: darkModeOn ? darkColor : lightColor,
                           title: Text(widget.user.deviceTokens!.isNotEmpty ? 'User is signed in' : 'User not signed in',
                             style: TextStyle(
                               fontSize: 14,
                               color: widget.user.deviceTokens!.isNotEmpty ? darkModeGrassColor : darkModeSecondaryColor
                           )),
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
