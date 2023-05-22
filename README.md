# Neartuit-APP-Public-Art

The following App demonstrates using ODEN and a dart version of the Transmogrifier to displays public from around the world. This is made possible because the Transmogrifier fetches, converts, and filters public art data from ODEN and delivers it to the app as a json file. 

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

Following is a video tutorial in installing FLutter [Flutter Setup Tutorial](https://www.youtube.com/watch?v=ly0hAtV7EBg)

Following are instructions for installing Flutter for Windows without the tutorial video above:
- Install Flutter for your OS: [Flutter Setup](https://flutter.dev/docs/get-started/install).
- Git is required for installation: [Git Setup](https://git-scm.com/downloads).
- Download the latest release of the Flutter SDK.
- Extract the zip file and place the contained “flutter” folder in the desired installation location.
- Alternatively, you can run “git clone https://github.com/flutter/flutter.git -b stable” in the installation location using Windows powershell.
- From the Start search bar, enter “env” and select “Edit the system environment variables”. 
- Click on “Environment Variables...” and in "Path" under "User variables", click "Edit" and add new path (eg if Flutter file is in C:\src\flutter, add C:\src\flutter\bin).
- run `flutter doctor` in the terminal to check if flutter is installed correctly.

- **Setup**

### a. **Setup** your objectbox.g.dart

Following must be done for objectbox (in app database to function and whenever there is a change in the model)
- After setting up flutter, on the terminal: `flutter pub run build_runner watch --delete-conflicting-outputs`

## Map Page

The Map Page allows users to see all public art entries on a map with the following features:
- GPS visiting (when logged in).
- Grouping of markers when zooming out.
- Markers with name of public art.
- Tapping redirects to the Details page for more information. 
- Search by name of public art or location.
- Recommended public art when searching for item or location. 