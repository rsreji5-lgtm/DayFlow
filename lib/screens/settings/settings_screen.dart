import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../cubits/auth/auth_cubit.dart';
import '../../cubits/theme/theme_cubit.dart';
import '../../widgets/app_shell.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    final yes = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Sign Out?'),
        content: const Text('Are you sure you want to sign out of your account?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Sign Out')),
        ],
      ),
    );
    if (yes == true) {
      await context.read<AuthCubit>().logout();
      if (context.mounted) context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final email = context.select<AuthCubit, String>((cubit) {
      final s = cubit.state;
      return s is AuthAuthenticated ? s.email : '';
    });

    return AppShell(
      currentIndex: 3,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text('Settings', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          const Text('Customize your DayFlow experience.'),
          const SizedBox(height: 24),
          const Text('Appearance', style: TextStyle(fontWeight: FontWeight.bold)),
          Card(
            child: BlocBuilder<ThemeCubit, ThemeState>(
              builder: (context, state) => SwitchListTile(
                title: const Text('Dark Mode'),
                secondary: Icon(state.isDark ? Icons.dark_mode : Icons.light_mode),
                value: state.isDark,
                onChanged: (_) => context.read<ThemeCubit>().toggleTheme(),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text('Account', style: TextStyle(fontWeight: FontWeight.bold)),
          Card(
            child: ListTile(
              leading: const Icon(Icons.email_outlined),
              title: const Text('Email'),
              subtitle: Text(email.isEmpty ? 'Not available' : email),
            ),
          ),
          const SizedBox(height: 16),
          const Text('About', style: TextStyle(fontWeight: FontWeight.bold)),
          const Card(
            child: ListTile(
              leading: Icon(Icons.info_outline),
              title: Text('About DayFlow'),
              subtitle: Text('Version 1.0.0'),
            ),
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: () => _logout(context),
            icon: const Icon(Icons.logout),
            label: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}
