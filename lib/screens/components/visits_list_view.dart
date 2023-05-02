import 'package:flutter/material.dart';

///
/// This contains the list view for the visits.
///

class VisitsListView extends StatefulWidget {
  const VisitsListView({super.key});

  @override
  State<VisitsListView> createState() => _VisitsListViewState();
}

class _VisitsListViewState extends State<VisitsListView> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: 10,
        itemBuilder: (BuildContext context, int index) {
          return Card(
            child: Row(children: const [
              Expanded(child: ListTile(title: Text("Visits")))
            ]),
          );
        });
  }
}
