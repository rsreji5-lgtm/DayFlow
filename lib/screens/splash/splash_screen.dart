import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../cubits/auth/auth_cubit.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 700), () {
      if (!mounted) return;
      final state = context.read<AuthCubit>().state;
      if (state is AuthAuthenticated) {
        context.go('/home');
      } else if (state is AuthUnauthenticated) {
        context.go('/login');
      } else {
        Future.delayed(const Duration(milliseconds: 700), () {
          if (!mounted) return;
          final current = context.read<AuthCubit>().state;
          context.go(current is AuthAuthenticated ? '/home' : '/login');
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/Dayflow_logo.png',
              height: 140,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 12),
            const Text(
              'Organize. Focus. Achieve.',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 36),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
