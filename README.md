# ODEN-DEMO-APP-Public-Art

The following App demonstrates using ODEN and a dart version of the Transmogrifier to create a simple app that displays public art in from around the world.

## Directory Structure
The structure and intended contents of the directories in this project are shown in the diagram below:

```
project
│   README.md
│   pubspace.yaml  
│
└───assets
│   │   ajv.js
│   └── images
│         icon.png
│         logo.png      
│
└───lib
   │  firebase_options.dart
   │  main.dart
   │  objectbox.g.dart
   │  objectbox-model.json
   │  transmogrifier.dart
   └──components
   │       back_button_app_bar.dart
   │       only_back_button_app_bar.dart
   │       profile_button_app_bar.dart
   └── models
   │       auth.dart
   │       category.dart
   │       firebase_repo.dart
   │       geolocator.dart
   │       profile_public_art.dart
   │       public_art.dart
   │       store.dart
   └── screens
   │   │  collections.dart
   │   │  details.dart
   │   │  home_page.dart
   │   │  login.dart
   │   │  map_page.dart
   │   │  profile_page.dart
   │   │  sign_up.dart
   │   └──components
   │           favourites_list_view.dart
   │           markers.dart
   │           visits_list_view.dart  
   └── themes
           style.dart
```

## Installation:

Please see the appropriate guide for your environment of choice:

- **Setup**

### a. **Setup** your objectbox.g.dart

- To setup Flutter on your device: [Flutter Setup](https://www.youtube.com/watch?v=ly0hAtV7EBg)
- After setting up flutter, on the terminal: `flutter pub run build_runner watch --delete-conflicting-outputs`
-
