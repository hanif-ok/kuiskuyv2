# Firebase Setup Guide for Kuiskuy v2

This guide will help you set up Firebase for the Kuiskuy v2 application.

## Step 1: Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Add project"
3. Enter project name: "kuiskuy-v2" (or your preferred name)
4. Follow the setup wizard

## Step 2: Enable Firebase Services

### Authentication
1. In Firebase Console, go to Authentication
2. Click "Get Started"
3. Enable "Email/Password" sign-in method

### Cloud Firestore
1. Go to Firestore Database
2. Click "Create Database"
3. Start in production mode (we'll add rules later)
4. Choose your preferred location

### Cloud Storage
1. Go to Storage
2. Click "Get Started"
3. Start in production mode
4. Choose the same location as Firestore

## Step 3: Configure Flutter App

### Install Firebase CLI and FlutterFire CLI
```bash
# Install Firebase CLI
npm install -g firebase-tools

# Login to Firebase
firebase login

# Install FlutterFire CLI
dart pub global activate flutterfire_cli
```

### Configure Firebase for Flutter
```bash
# In your project directory
flutterfire configure

# Select your Firebase project
# Select platforms (Android, iOS, Web)
# This will create firebase_options.dart
```

## Step 4: Add Firebase Configuration Files

### For Android
1. Download `google-services.json` from Firebase Console
2. Place it in `android/app/` directory

### For iOS
1. Download `GoogleService-Info.plist` from Firebase Console
2. Place it in `ios/Runner/` directory

## Step 5: Update Firestore Security Rules

In Firebase Console > Firestore Database > Rules, replace with:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users collection
    match /users/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth.uid == userId;
    }
    
    // Classes collection
    match /classes/{classId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null && 
                     request.resource.data.teacherId == request.auth.uid;
      allow update: if request.auth != null && 
                     (resource.data.teacherId == request.auth.uid ||
                      request.resource.data.studentIds.hasAll([request.auth.uid]));
    }
    
    // Quizzes collection
    match /quizzes/{quizId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && 
                     request.resource.data.teacherId == request.auth.uid;
    }
    
    // Submissions collection
    match /submissions/{submissionId} {
      allow read: if request.auth != null && 
                    (request.auth.uid == resource.data.studentId ||
                     request.auth.uid == get(/databases/$(database)/documents/quizzes/$(resource.data.quizId)).data.teacherId);
      allow create: if request.auth != null && 
                      request.auth.uid == request.resource.data.studentId;
      allow update: if request.auth != null && 
                      request.auth.uid == get(/databases/$(database)/documents/quizzes/$(resource.data.quizId)).data.teacherId;
    }
  }
}
```

## Step 6: Update Storage Security Rules

In Firebase Console > Storage > Rules, replace with:

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    // Quiz images
    match /quiz_images/{allPaths=**} {
      allow read: if request.auth != null;
      allow write: if request.auth != null;
    }
    
    // Quiz audio files
    match /quiz_audio/{allPaths=**} {
      allow read: if request.auth != null;
      allow write: if request.auth != null;
    }
  }
}
```

## Step 7: Test Your Setup

1. Run `flutter pub get` to ensure all dependencies are installed
2. Run `flutter run` to test the app
3. Try creating a test account
4. Verify data appears in Firestore Console

## Troubleshooting

### "No Firebase App '[DEFAULT]' has been created"
- Ensure `Firebase.initializeApp()` is called in `main.dart`
- Check that firebase_options.dart is generated correctly

### Authentication Issues
- Verify Email/Password authentication is enabled in Firebase Console
- Check Firebase Authentication rules

### Firestore Permission Errors
- Verify security rules are properly configured
- Check user is authenticated before making requests

### Storage Upload Errors
- Verify Storage is enabled
- Check storage security rules
- Ensure user is authenticated

## Additional Resources

- [Firebase Documentation](https://firebase.google.com/docs)
- [FlutterFire Documentation](https://firebase.flutter.dev/)
- [Flutter Documentation](https://flutter.dev/docs)

## Support

If you encounter issues:
1. Check the troubleshooting section above
2. Review Firebase Console for errors
3. Check Flutter/Dart console output
4. Open an issue on GitHub with details
