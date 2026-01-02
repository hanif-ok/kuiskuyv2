# Kuiskuy v2 - Architecture Overview

## System Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                        Kuiskuy v2 Platform                       │
│                   Flutter/Firebase Quiz System                   │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│                         PRESENTATION LAYER                       │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  ┌──────────────┐                           ┌──────────────┐   │
│  │     Auth     │                           │     Home     │   │
│  │   Screens    │──────────────────────────▶│    Router    │   │
│  │ (Login/Signup)│                           │              │   │
│  └──────────────┘                           └──────┬───────┘   │
│                                                     │            │
│                                    ┌────────────────┴──────────┐│
│                                    │                           ││
│                          ┌─────────▼────────┐    ┌────────────▼┤
│                          │  Teacher Screens  │    │  Student Screens│
│                          ├──────────────────┤    ├────────────────┤
│                          │ • Dashboard      │    │ • Dashboard    │
│                          │ • Create Class   │    │ • Join Class   │
│                          │ • Class Detail   │    │ • Class Detail │
│                          │ • Create Quiz    │    │ • Take Quiz    │
│                          │ • Quiz Detail    │    │ • View Results │
│                          │ • Grade Essays   │    │                │
│                          └──────────────────┘    └────────────────┘
│                                                                  │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│                         BUSINESS LOGIC LAYER                     │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  ┌─────┐│
│  │    Auth      │  │    Class     │  │     Quiz     │  │ Sub │││
│  │   Service    │  │   Service    │  │   Service    │  │Svc  │││
│  ├──────────────┤  ├──────────────┤  ├──────────────┤  ├─────┤││
│  │• Sign Up     │  │• Create Class│  │• Create Quiz │  │• Sub││││
│  │• Sign In     │  │• Join Class  │  │• Add Questions│  │ mit│││
│  │• Sign Out    │  │• Get Classes │  │• Upload Media│  │• Grd│││
│  │• Get User    │  │• Gen Codes   │  │• Get Quizzes │  │ Essay││
│  └──────────────┘  └──────────────┘  └──────────────┘  └─────┘││
│                                                                  │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│                           DATA LAYER                             │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐       │
│  │   User   │  │  Class   │  │   Quiz   │  │Submission│       │
│  │  Model   │  │  Model   │  │  Model   │  │  Model   │       │
│  ├──────────┤  ├──────────┤  ├──────────┤  ├──────────┤       │
│  │• id      │  │• id      │  │• id      │  │• id      │       │
│  │• email   │  │• name    │  │• title   │  │• quizId  │       │
│  │• name    │  │• teacherId│  │• classId │  │• studentId│      │
│  │• role    │  │• joinCode│  │• questions│  │• answers │       │
│  │• created │  │• password│  │• visibility│  │• score   │       │
│  └──────────┘  │• students│  │• created │  │• isGraded│       │
│                └──────────┘  └──────────┘  └──────────┘       │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│                         FIREBASE BACKEND                         │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  ┌──────────────────┐  ┌──────────────────┐  ┌──────────────┐ │
│  │  Authentication  │  │   Cloud          │  │    Cloud     │ │
│  │                  │  │   Firestore      │  │   Storage    │ │
│  ├──────────────────┤  ├──────────────────┤  ├──────────────┤ │
│  │• Email/Password  │  │• users/          │  │• quiz_images/│ │
│  │• User Sessions   │  │• classes/        │  │• quiz_audio/ │ │
│  │• Auth State      │  │• quizzes/        │  │              │ │
│  │                  │  │• submissions/    │  │              │ │
│  └──────────────────┘  └──────────────────┘  └──────────────┘ │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

## Data Flow Diagrams

### Teacher Creates Quiz Flow
```
Teacher → Create Quiz Screen → Quiz Service → Upload Media → Firebase Storage
                                     ↓
                              Save Quiz Data → Cloud Firestore
                                     ↓
                              Return Quiz ID → Update UI
```

### Student Takes Quiz Flow
```
Student → Take Quiz Screen → Answer Questions → Build Submission
                                                      ↓
                                              Submission Service
                                                      ↓
                                            Auto-grade MCQ Questions
                                                      ↓
                                            Save to Cloud Firestore
                                                      ↓
                                            Show Results (if enabled)
```

### Teacher Grades Essay Flow
```
Teacher → Grade Submission Screen → Enter Points/Feedback
                                           ↓
                                  Submission Service
                                           ↓
                                  Update Answer in Firestore
                                           ↓
                                  Calculate Final Score
                                           ↓
                                  Update isGraded Status
```

## Security Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                      SECURITY LAYERS                             │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │            Firebase Authentication                        │  │
│  │  • Email/Password verification                           │  │
│  │  • Session management                                    │  │
│  │  • UID assignment                                        │  │
│  └──────────────────────────────────────────────────────────┘  │
│                            ↓                                     │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │         Firestore Security Rules                         │  │
│  │  • Role-based access (teacher/student)                   │  │
│  │  • Document-level permissions                            │  │
│  │  • Read/Write restrictions                               │  │
│  └──────────────────────────────────────────────────────────┘  │
│                            ↓                                     │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │          Storage Security Rules                          │  │
│  │  • Authenticated uploads only                            │  │
│  │  • File type restrictions                                │  │
│  │  • Size limits                                           │  │
│  └──────────────────────────────────────────────────────────┘  │
│                            ↓                                     │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │         Application-Level Security                       │  │
│  │  • Input validation                                      │  │
│  │  • Error handling                                        │  │
│  │  • UI-based access control                               │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

## Key Design Patterns

### 1. Service Layer Pattern
- Separation of business logic from UI
- Reusable Firebase operations
- Centralized data access

### 2. Model-View Pattern
- Data models represent Firestore documents
- Views consume models for display
- Clean serialization/deserialization

### 3. Stream-Based Architecture
- Real-time data updates
- Firebase streams for live sync
- Automatic UI refresh

### 4. Role-Based UI Rendering
- Single codebase
- Conditional screen routing
- Role-specific features

## Scalability Considerations

### Performance
- Pagination for large lists (ready to implement)
- Lazy loading of media content
- Caching strategies for frequently accessed data

### Database Structure
- Flat collection structure for efficient queries
- Denormalized data where appropriate
- Indexed fields for search operations

### Storage Optimization
- Compressed image uploads
- Appropriate audio format selection
- CDN delivery via Firebase

## Future Architecture Enhancements

1. **Microservices**: Cloud Functions for complex operations
2. **Real-time**: WebSocket for live quiz sessions
3. **Analytics**: BigQuery integration for insights
4. **Caching**: Redis layer for high-traffic data
5. **CDN**: Enhanced media delivery
6. **Search**: Algolia integration for advanced search
7. **Notifications**: FCM for push notifications
8. **AI/ML**: TensorFlow for essay auto-grading
