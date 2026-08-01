import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'app/app.dart';
import 'cubits/auth/auth_cubit.dart';
import 'cubits/auth/task_cubit.dart';
import 'cubits/notes/note_cubit.dart';
import 'cubits/theme/theme_cubit.dart';

import 'repositories/auth_repository.dart';
import 'repositories/note_repository.dart';
import 'repositories/task_repository.dart';

import 'services/notification_service.dart';

import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize notifications BEFORE runApp
  await NotificationService.instance.initialize();

  final authRepository = AuthRepository();
  final taskRepository = TaskRepository();
  final noteRepository = NoteRepository();

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => AuthCubit(authRepository)
            ..listenToAuthChanges(),
        ),
        BlocProvider(
          create: (_) => ThemeCubit()..loadTheme(),
        ),
        BlocProvider(
          lazy: false,
          create: (_) => TaskCubit(taskRepository)
            ..listenToAuthChanges(),
        ),
        BlocProvider(
          create: (_) => NoteCubit(noteRepository),
        ),
      ],
      child: const DayFlowApp(),
    ),
  );
}