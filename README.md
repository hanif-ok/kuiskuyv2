# Kuiskuy v2

A comprehensive Flutter/Firebase quiz platform for teachers and students.

## Features

### For Teachers
- **Class Management**: Create classes with randomly generated 6-character join codes
- **Quiz Creation**: Build quizzes with multimedia questions supporting:
  - Text-based questions
  - Image attachments
  - Audio files
  - Multiple Choice Questions (MCQ)
  - Essay questions
- **Flexible Grading**:
  - Automatic grading for MCQ questions
  - Manual grading for essay questions with feedback
  - Auto-grading system for essays (can be enhanced with AI)
- **Visibility Controls**: Toggle post-test visibility of scores and corrections
- **Student Management**: View all students enrolled in classes

### For Students
- **Easy Joining**: Join classes using join code and password
- **Quiz Taking**: Take quizzes with:
  - Intuitive interface
  - Progress tracking
  - Support for multimedia content (images, audio)
  - MCQ and essay answers
- **Results**: View scores and corrections (when enabled by teacher)

## Project Structure

```
lib/
├── models/           # Data models (User, Class, Quiz, Submission)
├── services/         # Firebase services (Auth, Class, Quiz, Submission)
├── screens/          # UI screens
│   ├── auth/        # Login and signup screens
│   ├── teacher/     # Teacher dashboard and features
│   └── student/     # Student dashboard and features
└── main.dart        # App entry point
```

## Setup Instructions

### Prerequisites
- Flutter SDK (>=3.0.0)
- Firebase account
- Android Studio / VS Code with Flutter extensions

### Firebase Setup

1. **Create a Firebase Project**:
   - Go to [Firebase Console](https://console.firebase.google.com/)
   - Create a new project
   - Enable Authentication (Email/Password)
   - Enable Cloud Firestore
   - Enable Cloud Storage

2. **Configure Firebase for Flutter**:
   ```bash
   # Install Firebase CLI
   npm install -g firebase-tools
   
   # Login to Firebase
   firebase login
   
   # Install FlutterFire CLI
   dart pub global activate flutterfire_cli
   
   # Configure Firebase for your Flutter project
   flutterfire configure
   ```

3. **Firestore Security Rules**:
   ```javascript
   rules_version = '2';
   service cloud.firestore {
     match /databases/{database}/documents {
       match /users/{userId} {
         allow read: if request.auth != null;
         allow write: if request.auth.uid == userId;
       }
       
       match /classes/{classId} {
         allow read: if request.auth != null;
         allow create: if request.auth != null && 
                        request.resource.data.teacherId == request.auth.uid;
         allow update: if request.auth != null && 
                        (resource.data.teacherId == request.auth.uid ||
                         request.resource.data.studentIds.hasAll([request.auth.uid]));
       }
       
       match /quizzes/{quizId} {
         allow read: if request.auth != null;
         allow write: if request.auth != null && 
                        request.resource.data.teacherId == request.auth.uid;
       }
       
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

4. **Storage Security Rules**:
   ```javascript
   rules_version = '2';
   service firebase.storage {
     match /b/{bucket}/o {
       match /quiz_images/{allPaths=**} {
         allow read: if request.auth != null;
         allow write: if request.auth != null;
       }
       
       match /quiz_audio/{allPaths=**} {
         allow read: if request.auth != null;
         allow write: if request.auth != null;
       }
     }
   }
   ```

### Installation

1. **Clone the repository**:
   ```bash
   git clone https://github.com/hanif-ok/kuiskuyv2.git
   cd kuiskuyv2
   ```

2. **Install dependencies**:
   ```bash
   flutter pub get
   ```

3. **Run the app**:
   ```bash
   # For Android
   flutter run
   
   # For iOS
   flutter run
   
   # For Web
   flutter run -d chrome
   ```

## Usage

### Teacher Workflow
1. Sign up as a Teacher
2. Create a class (receives a join code and sets a password)
3. Create quizzes with various question types
4. Toggle visibility settings for scores and corrections
5. Grade essay submissions and provide feedback
6. Share join code and password with students

### Student Workflow
1. Sign up as a Student
2. Join a class using the join code and password
3. Take available quizzes
4. Submit answers (MCQ auto-graded, essays pending teacher review)
5. View results (when enabled by teacher)

## Key Technologies

- **Frontend**: Flutter
- **Backend**: Firebase
  - Authentication
  - Cloud Firestore
  - Cloud Storage
- **State Management**: Provider
- **Media**: Image Picker, File Picker, Audio Players

## Future Enhancements

- AI-powered essay grading
- Real-time quiz sessions
- Analytics dashboard for teachers
- Leaderboards
- Quiz scheduling
- Push notifications
- Export results to PDF/CSV
- Video question support

## License

This project is licensed under the MIT License.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.
