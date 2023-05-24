# Neartuit-APP-Public-Art

The following Flutter App demonstrates using ODEN and a dart version of the Transmogrifier to display open public art data from around the world. This is made possible because the Transmogrifier fetches, converts, and filters public art data from ODEN and delivers it to the app as a json file as a standardized version of all the collected data. 

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

You will need a emulalator API of 33 or higher to run this flutter project.

Following is a video tutorial in installing Flutter [Flutter Setup Tutorial](https://www.youtube.com/watch?v=ly0hAtV7EBg)

Following are instructions for installing Flutter for Windows without the tutorial video above:
- Install Flutter for your OS: [Flutter Setup](https://flutter.dev/docs/get-started/install).
- Git is required for installation: [Git Setup](https://git-scm.com/downloads).
- Download the latest release of the Flutter SDK.
- Extract the zip file and place the contained “flutter” folder in the desired installation location.
- Alternatively, you can run “git clone https://github.com/flutter/flutter.git -b stable” in the installation location using Windows powershell.
- From the Start search bar, enter “env” and select “Edit the system environment variables”. 
- Click on “Environment Variables...” and in "Path" under "User variables", click "Edit" and add new path (eg if Flutter file is in C:\src\flutter, add C:\src\flutter\bin).
- run `flutter doctor` in the terminal to check if flutter is installed correctly.

### **Setup** your objectbox.g.dart

Following must be done for objectbox (in app database to function and whenever there is a change in the model)
- After setting up flutter, on the terminal: `flutter pub run build_runner watch --delete-conflicting-outputs`

## Map Page

The Map Page allows users to see all public art entries on a map with the following features:
- GPS visiting (when logged in and within 100m of an unvisited art installation) when GPS is on.
- Grouping of markers when zooming out.
- Markers with name of public art.
- Tapping redirects to the Details page for more information. 
- Search by name of public art or location.
- Recommended public art when searching for item or location.
- Direction to public art if marker is tapped when GPS is on.

## Details Page

The Details Page allows users to see more information about a public art entry with the following features:
- Favorite the artpiece (if logged in).
- Display the name of the art pieces.
- Display how far away the art pieces is from the user if GPS is on.
- Display the country, region, and city of the art pieces.
- Provide directions to the art pieces if GPS is on.
- Display the description of the art pieces (if available).
- Display the artist name of the art pieces (if available).
- Display the year the art pieces was created (if available).
- Display the year the art pieces was installed (if available).
- Display the material of the art pieces (if available).

## Collections Page

The Details Page allows users to see more information about a public art entry with the following features:
- Filter art pieces by country, region, and city.
- Display total number of art pieces in the collection.
- Filter if description is available.
- Filter if artist name is available.
- Filter if year created is available.
- Filter if year installed is available.
- Filter if material is available.
- on tap, redirect to the Details page for more information.

## Profile Page

The Profile Page allows user personlize their experinece with the following features:
- Track favorite art pieces.
- Track visited art pieces.

## Update Using The Transmogrifier
Public art entries are updated dynamically by calling the Transmogrifier. This allows for the following:
- New public art entries are fetched by tapping "Update" on the Home Page through the Transmogrifier.
- Transmogrifier filters and converts new entry to the [ODEN Public Art Schema](https://github.com/OpendataDeveloperNetwork/ODEN-Transmogrifiers/blob/main/schemas/public-art.json).
- New entries are added to the internal database.
