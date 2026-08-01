import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeState extends Equatable {
  final bool isDark;

  const ThemeState({
    required this.isDark,
  });

  @override
  List<Object?> get props => [
        isDark,
      ];
}

class ThemeCubit extends Cubit<ThemeState> {
  ThemeCubit()
      : super(
          const ThemeState(
            isDark: false,
          ),
        );

  Future<void> loadTheme() async {
    final prefs =
        await SharedPreferences.getInstance();

    emit(
      ThemeState(
        isDark:
            prefs.getBool('darkMode') ??
                false,
      ),
    );
  }

  Future<void> toggleTheme() async {
    final value = !state.isDark;

    final prefs =
        await SharedPreferences.getInstance();

    await prefs.setBool(
      'darkMode',
      value,
    );

    emit(
      ThemeState(
        isDark: value,
      ),
    );
  }

  Future<void> setLightMode() async {
    final prefs =
        await SharedPreferences.getInstance();

    await prefs.setBool(
      'darkMode',
      false,
    );

    emit(
      const ThemeState(
        isDark: false,
      ),
    );
  }

  Future<void> setDarkMode() async {
    final prefs =
        await SharedPreferences.getInstance();

    await prefs.setBool(
      'darkMode',
      true,
    );

    emit(
      const ThemeState(
        isDark: true,
      ),
    );
  }
}