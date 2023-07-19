import 'package:flutter/material.dart';

import '../models/profile.dart' as model;
import '../models/user.dart' as model;

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

    model.Profile currentProfile = widget.user.profile ?? model.Profile();

    return widget.user.userType != 'Admin' ? Card(
      child: Row(
        children: [
          Flexible(
              child:ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(currentProfile.profileImage ?? ''), // Display the profile image, if any
                  child: Text(currentProfile.year ?? ''), //In case there is no picture, display user initials
                ),
                title: Text(currentProfile.fullName ?? 'N/A'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Text>[
                    Text('Email: ${widget.user.email}'),
                    Text('Phone: ${currentProfile.phoneNumber ?? 'N/A'}'),
                    Text('Department: ${currentProfile.department ?? 'N/A'}'),
                    Text('Year: ${currentProfile.year ?? 'N/A'}'),
                    Text('Section: ${currentProfile.section ?? 'N/A'}'),
                  ],
                ),
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
    ) : const SizedBox.shrink();
  }
}
