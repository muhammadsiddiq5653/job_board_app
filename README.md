# Flutter Job Board App

A simple job board mobile application built with Flutter where users can view available jobs, see job details, and add new jobs (if they're recruiters).

## Features

- View a list of available jobs
- View job details
- Add a new job (for recruiters only)
- Basic authentication for recruiters and job seekers
- Firebase integration for real-time data and authentication

## Project Setup

### Prerequisites

- Flutter SDK (latest stable version)
- Dart SDK
- Android Studio or VS Code with Flutter extensions
- Firebase account

### Firebase Setup

1. Create a new Firebase project in the [Firebase Console](https://console.firebase.google.com/)

2. Install the Firebase CLI:
```bash
npm install -g firebase-tools
```

3. Login to Firebase from the CLI:
```bash
firebase login
```

4. Initialize Firebase in your Flutter project:
```bash
# Navigate to your project directory
cd job_board_app

# Initialize Firebase
firebase init
```
- Select the services you need (Firestore, Authentication, Hosting if needed)
- Choose your Firebase project
- Accept the default file locations

5. Add Flutter Firebase configuration:
```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Configure your Flutter app with Firebase
flutterfire configure --project=your-firebase-project-id
```

6. Add Android and iOS apps to your Firebase project through the CLI or Console
   - For CLI: Follow the prompts during `flutterfire configure`
   - For Console: Add apps manually and download configuration files

7. Enable Firebase Authentication
   - In the Firebase Console, go to Authentication > Sign-in method
   - Enable Email/Password authentication

8. Set up Cloud Firestore
   - In the Firebase Console, go to Firestore Database
   - Create a new database in production mode
   - Choose a location closest to your users

### Installation

1. Clone this repository
```bash
git clone https://github.com/yourusername/job_board_app.git
cd job_board_app
```

2. Install dependencies
```bash
flutter pub get
```

3. Run the app
```bash
flutter run
```

## Demo Credentials

The app automatically creates these demo accounts in Firebase Authentication:

- **Recruiter**: recruiter@test.com / password123
- **Job Seeker**: jobseeker@test.com / password123

## Firebase Security Rules

Add these security rules to your Firestore database for proper access control:

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Allow any authenticated user to read jobs
    match /jobs/{jobId} {
      allow read: if request.auth != null;
      // Only recruiters can create, update, or delete jobs
      allow write: if request.auth != null && 
                     get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'recruiter';
    }
    
    // Users can only read and write their own data
    match /users/{userId} {
      allow read: if request.auth != null && request.auth.uid == userId;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

## Project Structure

- **lib/models/** - Data models (Job, User)
- **lib/providers/** - State management using Provider (UserProvider, JobProvider)
- **lib/screens/** - UI screens
- **lib/services/** - Business logic and API calls

## Implementation Details

### State Management

This project uses Provider for state management due to its simplicity and efficiency for small to medium-sized applications.

### Backend

For this demo, we use a mock backend with hardcoded data. In a real-world scenario, Firebase or a custom REST API would be integrated.

### Authentication

Basic authentication is implemented with hardcoded credentials. In a production app, you would use Firebase Authentication or a secure authentication service.

## Enhanced Features

1. **Country Picker**:
   - Integrated the `country_picker` package for a better user experience when selecting job locations
   - Users can browse or search for countries with visual flags and proper names

2. **Splash Screen**:
   - Added an animated splash screen that appears on app startup
   - Provides visual feedback while the app initializes
   - Smooth transitions between screens

3. **Animations**:
   - Job listings use fade-in and slide animations for a more polished UI
   - Animated card components for a modern look and feel
   - Transition animations between screens

4. **Firebase Integration**:
   - Real-time data updates with Firestore
   - Secure user authentication
   - Role-based access control

5. **Job Application System**:
   - Users can apply for jobs with a single tap
   - Application status tracking (pending, reviewed, interviewed, accepted, rejected)
   - Prevention of duplicate applications for the same job
   - "My Applications" screen to view all submitted applications
   - Different UI states for apply button (normal, loading, already applied)
   - Role-based restrictions (recruiters cannot apply for jobs)

## Deployment Instructions

### Building APK for Android

To build an APK for distribution:

```bash
# Generate a release build
flutter build apk --release

# The APK will be available at:
# build/app/outputs/flutter-apk/app-release.apk
```

### Deploying to Firebase Hosting (for Web)

If you want to deploy the web version to Firebase Hosting:

1. Build the web version:
```bash
flutter build web
```

2. Install Firebase CLI (if not already installed):
```bash
npm install -g firebase-tools
```

3. Login to Firebase:
```bash
firebase login
```

4. Initialize Firebase in your project:
```bash
firebase init hosting
```

5. Deploy to Firebase:
```bash
firebase deploy --only hosting
```

## Assumptions

- Users will primarily use the app on mobile devices
- Authentication needs are basic (email/password)
- Job posts don't need advanced filtering in this MVP
- Real-time updates are important for job listings
- Demo data helps users understand the app quickly

## Trade-offs and Constraints

Due to the 4-hour time constraint:

- Used mock authentication instead of a full user registration system
- Simplified job application process (just a button)
- Limited to core features without advanced search/filter
- Focused on core functionality over extensive UI polish
- Limited test coverage to essential components
- Used simple animations for performance

## Testing

To run the unit tests:

```bash
flutter test
```