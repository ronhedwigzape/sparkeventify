import 'package:flutter/material.dart';
import 'package:student_event_calendar/models/user.dart' as model;

class SearchUserDelegate extends SearchDelegate<model.User> {
  final List<model.User> users; // This should be the list of all users

  SearchUserDelegate(this.users);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
          showSuggestions(context);
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        model.User defaultUser = model.User(); // Add necessary parameters if the User constructor requires them
        close(context, defaultUser);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return Container();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final List<model.User> suggestionList = query.isEmpty
        ? []
        : users.where((user) => user.profile?.fullName?.toLowerCase().contains(query.toLowerCase()) ?? false).toList();

    return ListView.builder(
      itemCount: suggestionList.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(suggestionList[index].profile!.fullName!),
          onTap: () {
            close(context, suggestionList[index]);
          },
        );
      },
    );
  }
}
