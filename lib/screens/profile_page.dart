import 'package:flutter/material.dart';
import 'package:oden_app/components/back_button_app_bar.dart';
import 'components/favourites_list_view.dart';
import 'components/visits_list_view.dart';
import '../models/auth.dart';
import '../models/profile_public_art.dart';
import '../models/firebase_user.dart';

// ------------------------ //
// ----- Profile Page ----- //
// ------------------------ //

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: backButtonAppBarWidget(context), body: const ProfileBody());
  }
}

const List<Widget> categories = <Widget>[
  Text('Favourites'),
  Text('Visits'),
];

class ProfileBody extends StatefulWidget {
  const ProfileBody({super.key});

  @override
  State<ProfileBody> createState() => _ProfileBodyState();
}

class _ProfileBodyState extends State<ProfileBody> {
  final _selectedCategories = [
    true,
    false
  ]; // This can be represented as [isFavouritesSelected, isVisitsSelected]
  final List<ProfilePublicArt> _favourites = [];
  final List<ProfilePublicArt> _visits = [];

  void _getFavourites() async {
    final userFavorites = await FirebaseUser().getFavourites(Auth().uid!);
    for (var doc in userFavorites.docs) {
      setState(() {
        ProfilePublicArt publicArt =
        ProfilePublicArt(doc["date"], doc["name"], doc["id"]);
        _favourites.add(publicArt);
      });
    }
  }

  void _getVisits() async {
    final userVists = await FirebaseUser().getVisits(Auth().uid!);
    for (var doc in userVists.docs) {
      setState(() {
        ProfilePublicArt publicArt =
        ProfilePublicArt(doc["date"], doc["name"], doc["id"]);
        _visits.add(publicArt);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _getFavourites();
    _getVisits();
  }

  ///
  /// This is the function that listens when user clicked on the toggle buttons.
  /// And changed the _selectedCategories list values accordingly. No values in
  /// the list can be true at the same time.
  ///
  void selectedCategory(int index) {
    setState(() => {
      for (int buttonIndex = 0;
      buttonIndex < _selectedCategories.length;
      buttonIndex++)
        {_selectedCategories[buttonIndex] = buttonIndex == index},
    });
  }

  ///
  /// This is the function that builds the toggle button.
  ///
  ToggleButtons _buildToggleButtons() {
    return ToggleButtons(
      onPressed: selectedCategory,
      borderRadius: const BorderRadius.all(Radius.circular(8)),
      selectedColor: Colors.white,
      selectedBorderColor: Colors.green[700],
      fillColor: const Color(0xFF77BF4B),
      color: Colors.grey[500],
      constraints: const BoxConstraints(minWidth: 120, minHeight: 35),
      direction: Axis.horizontal,
      isSelected: _selectedCategories,
      children: categories,
    );
  }

  void onSignOut() {
    Auth().signOut();
    Navigator.pop(context);
  }

  ///
  /// Builds the list view.
  ///
  Visibility _buildListView(Widget listView, bool listensTo) {
    return Visibility(
        visible: listensTo, // if true, show FavouritesListView
        child: Expanded(child: listView));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 0, 15),
          child: Text("Hey, ${Auth().name}!",
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              )),
        ),
        Align(alignment: Alignment.center, child: _buildToggleButtons()),
        const SizedBox(height: 15),
        /* Visibility of listviews are dynamic depending on which toggle button is selected */
        _buildListView(FavouritesListView(_favourites), _selectedCategories[0]),
        _buildListView(VisitsListView(_visits), _selectedCategories[1]),
        ElevatedButton(onPressed: onSignOut, child: const Text("Log Out"))
      ],
    );
  }
}
