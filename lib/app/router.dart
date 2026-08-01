import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';

import '../cubits/auth/auth_cubit.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/tasks/tasks_screen.dart';
import '../screens/tasks/add_task_screen.dart';
import '../screens/tasks/edit_task_screen.dart';
import '../screens/notes/notes_screen.dart';
import '../screens/notes/create_note_screen.dart';
import '../screens/notes/edit_note_screen.dart';
import '../screens/settings/settings_screen.dart';

class GoRouterRefreshStream extends ChangeNotifier {
  late final StreamSubscription<dynamic> _subscription;

  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

class AppRouter {
  static GoRouter createRouter(AuthCubit authCubit) {
    return GoRouter(
      initialLocation: '/login',
      refreshListenable: GoRouterRefreshStream(authCubit.stream),
      redirect: (context, state) {
        final authState = authCubit.state;
        if (authState is AuthInitial) return null;

        final isAuth = authState is AuthAuthenticated;
        final isAuthRoute =
            state.matchedLocation == '/login' || state.matchedLocation == '/register';

        if (!isAuth && !isAuthRoute) {
          return '/login';
        }
        if (isAuth && isAuthRoute) {
          return '/home';
        }
        return null;
      },
      routes: [
        GoRoute(
          path: '/login',
          builder: (_, __) => const LoginScreen(),
        ),
        GoRoute(
          path: '/register',
          builder: (_, __) => const RegisterScreen(),
        ),
        GoRoute(
          path: '/home',
          builder: (context, state) {
            final message = state.extra as String?;
            return HomeScreen(
              successMessage: message,
            );
          },
        ),
        GoRoute(
          path: '/tasks',
          builder: (_, __) => const TasksScreen(),
        ),
        GoRoute(
          path: '/tasks/add',
          builder: (_, __) => const AddTaskScreen(),
        ),
        GoRoute(
          path: '/tasks/edit/:id',
          builder: (_, state) {
            return EditTaskScreen(
              taskId: state.pathParameters['id']!,
            );
          },
        ),
        GoRoute(
          path: '/notes',
          builder: (context, state) {
            final message = state.extra as String?;
            return NotesScreen(successMessage: message);
          },
        ),
        GoRoute(
          path: '/notes/add',
          builder: (_, __) => const CreateNoteScreen(),
        ),
        GoRoute(
          path: '/notes/edit/:id',
          builder: (_, state) {
            return EditNoteScreen(
              noteId: state.pathParameters['id']!,
            );
          },
        ),
        GoRoute(
          path: '/settings',
          builder: (_, __) => const SettingsScreen(),
        ),
      ],
    );
  }
}