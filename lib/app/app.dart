import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../core/theme/app_theme.dart';
import '../cubits/auth/auth_cubit.dart';
import '../cubits/theme/theme_cubit.dart';
import 'router.dart';

class DayFlowApp extends StatefulWidget {
  const DayFlowApp({super.key});

  @override
  State<DayFlowApp> createState() => _DayFlowAppState();
}

class _DayFlowAppState extends State<DayFlowApp> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _router = AppRouter.createRouter(context.read<AuthCubit>());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, state) {
        return MaterialApp.router(
          debugShowCheckedModeBanner: false,
          title: 'DayFlow',

          theme: AppTheme.light,
          darkTheme: AppTheme.dark,

          themeMode:
              state.isDark ? ThemeMode.dark : ThemeMode.light,

          routerConfig: _router,
        );
      },
    );
  }
}