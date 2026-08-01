# DayFlow 🚀

DayFlow is a feature-rich, modern personal productivity application built with **Flutter**, **Firebase**, and **Bloc/Cubit**. DayFlow empowers users to organize their daily schedule with tasks, schedule local notification reminders, capture thoughts with notes, and customize their interface with dynamic light and dark theme modes.

---

## 📋 Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Folder & Architecture Overview](#folder--architecture-overview)
- [Setup & Installation Steps](#setup--installation-steps)
- [Decisions Made & Rationale](#decisions-made--rationale)
- [Future Improvements & What I'd Do Differently](#future-improvements--what-id-do-differently)

---

## ✨ Features

- 🔐 **Authentication**: Firebase Email & Password login, user registration, and password reset functionality.
- 📝 **Task Management**: Create, edit, delete, mark completed, and categorize tasks with priority levels (Low, Medium, High) and due dates.
- 🔔 **Scheduled Local Notifications**: Local push reminders scheduled based on task due dates using native platform notification engines.
- 📓 **Notes Capture**: Full CRUD note-taking functionality with real-time Firestore sync.
- 🔍 **Filtering & Search**: Dynamic filtering by priority, completion status, and real-time text query search across tasks and notes.
- 🎨 **Material 3 UI & Dark Theme**: Full support for system, light, and dark mode themes with persistence via `SharedPreferences`.
- 🛡️ **Security Rules**: User-scoped Firestore rules ensuring strong multi-tenant data isolation.

---

## 🏗️ Folder & Architecture Overview

DayFlow follows **Clean Architecture** principles combined with the **Bloc/Cubit Pattern**. The codebase cleanly separates presentation, business logic, repository/data layers, and core services.

```text
lib/
├── app/                  # Application configuration & Router initialization
│   ├── app.dart          # MaterialApp configuration, theme bindings, GoRouter entry
│   └── router.dart       # Declarative routing & Auth guard via GoRouter
├── core/                 # Core styling & app themes
│   └── theme/            # Material 3 light/dark ThemeData definitions
├── cubits/               # State management layer (Bloc/Cubit)
│   ├── auth/             # AuthCubit & TaskCubit state management
│   ├── notes/            # NoteCubit state & stream management
│   └── theme/           # ThemeCubit for persistent theme switching
├── models/               # Domain data models & JSON/Firestore mappers
│   ├── note.dart         # NoteModel schema
│   └── tasks.dart        # TaskModel schema & priority enums
├── repositories/         # Data Abstraction Layer (Firebase interfaces)
│   ├── auth_repository.dart # FirebaseAuth operations
│   ├── note_repository.dart # Firestore notes collection operations
│   └── task_repository.dart # Firestore tasks collection operations
├── screens/              # UI Screen Views (Grouped by domain feature)
│   ├── auth/             # Login & Register views
│   ├── home/             # Home Dashboard view
│   ├── notes/            # Notes List, Create, and Edit views
│   ├── settings/         # User Settings & Theme configuration view
│   ├── splash/           # Initializing Splash screen
│   └── tasks/            # Task List, Add Task, and Edit Task views
├── services/             # Platform-level service wrappers
│   └── notification_service.dart # flutter_local_notifications & timezone scheduling logic
├── utils/                # Helper functions, formatters, and constants
└── widgets/              # Reusable custom UI components and dialogs
```

---

## 🛠️ Setup & Installation Steps

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (Version `>= 3.6.0`)
- [Dart SDK](https://dart.dev/get-started) (Version `>= 3.6.0`)
- Android Studio / Xcode (for device emulators)
- Firebase Account & Node.js (for Firebase CLI)

### 1. Clone & Dependencies

```bash
git clone https://github.com/your-username/DayFlow.git
cd DayFlow
flutter pub get
```

### 2. Firebase Configuration

DayFlow relies on Firebase Authentication and Cloud Firestore.

1. Install the FlutterFire CLI:
   ```bash
   dart pub global activate flutterfire_cli
   ```
2. Configure Firebase project bindings:
   ```bash
   flutterfire configure
   ```
   *This command generates `lib/firebase_options.dart` configured for your Android/iOS/Web target applications.*

3. Enable Firebase Authentication:
   - Go to **Firebase Console > Authentication > Sign-in method**.
   - Enable **Email/Password**.

4. Configure Cloud Firestore:
   - Create a Cloud Firestore database in production mode.
   - Deploy security rules from `firestore.rules`:
     ```bash
     firebase deploy --only firestore:rules
     ```

### 3. Run Application

```bash
# Run on connected device or emulator
flutter run

# Execute automated test suite
flutter test
```

---

## 🧠 Decisions Made & Rationale

| Architecture Decision | Selection | Rationale / Why |
| :--- | :--- | :--- |
| **State Management** | `flutter_bloc` / `Cubit` | Provides predictable, unidirectional data flow with explicit state states (`Initial`, `Loading`, `Loaded`, `Error`). Minimizes UI boilerplate compared to full Blocs while remaining lightweight and testable. |
| **Data Layer** | Repository Pattern | Abstracts Firestore and FirebaseAuth APIs away from business logic. Enables independent unit testing (e.g. mocking `TaskRepository`) and seamless future migration if the database provider changes. |
| **Routing & Auth Guard** | `GoRouter` + `GoRouterRefreshStream` | Provides declarative URL-based routing with integrated authentication state listener streams. Automatically handles auth-gated redirects (e.g., redirecting unauthenticated users to `/login`). |
| **Data Isolation** | Subcollections (`users/{uid}/tasks`) | User-scoped Firestore paths combined with security rules (`request.auth.uid == userId`) guarantee strict multi-tenant isolation and prevent unauthorized data leaks. |
| **Notification Engine** | `flutter_local_notifications` + `timezone` | Enables local notification scheduling tied directly to task due dates without requiring a backend server or external notification payload expenses. |
| **Theme Persistence** | `SharedPreferences` | Simple key-value store to retain dark/light mode preference across application restarts without overhead. |

---

## 🔮 Future Improvements & What I'd Do Differently

Given additional time and development scope, the following enhancements would be prioritized:

1. **Offline-First Synchronization (Hive / Isar Cache)**
   - Implement local database caching using Hive or Isar to store tasks and notes locally on-device. This would allow complete offline usability with optimistic UI updates and background synchronization when connectivity is restored.

2. **Dependency Injection (GetIt & Injectable)**
   - Replace manual repository instantiation in `main.dart` with a dependency injection container like `GetIt` to decouple dependencies further and facilitate mock injections during integration testing.

3. **Rich Task & Note Features**
   - Add Markdown / Rich Text editing support for notes.
   - Support for sub-tasks / checklists within individual tasks.
   - Category tags, color coding, and file/image attachment capabilities.
   - Recurring task schedules (e.g., daily, weekly, custom intervals).

4. **Remote Push Notifications (Firebase Cloud Messaging - FCM)**
   - Upgrade from purely local scheduled notifications to FCM server-side push notifications to ensure timely delivery across multiple user devices even when the app process is terminated by the OS.

5. **Expanded Unit & Integration Test Coverage**
   - Expand `bloc_test` suites for all Cubits, repository integration tests using `fake_cloud_firestore`, and end-to-end Flutter UI golden tests.

6. **CI/CD Pipeline**
   - Setup GitHub Actions workflows to execute linter rules, run unit/widget test suites, and automate release builds (Android APK/AAB and iOS TestFlight deployments).
#   D a y F l o w  
 #   D a y F l o w  
 