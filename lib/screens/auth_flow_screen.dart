import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../features/auth/presentation/bloc/auth_bloc.dart';
import '../features/auth/presentation/bloc/auth_state.dart';
import '../features/auth/presentation/bloc/auth_event.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/auth/presentation/register_screen.dart';
import 'home_screen.dart';

class AuthFlowScreen extends StatefulWidget {
  const AuthFlowScreen({Key? key}) : super(key: key);

  @override
  State<AuthFlowScreen> createState() => _AuthFlowScreenState();
}

class _AuthFlowScreenState extends State<AuthFlowScreen> {
  bool showLogin = true;

  void toggle() => setState(() => showLogin = !showLogin);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is Authenticated) {
          return HomeScreen(
            onSignOut: () => context.read<AuthBloc>().add(SignOutRequested()),
          );
        } else if (showLogin) {
          return LoginScreen(onRegisterTap: toggle);
        } else {
          return RegisterScreen(onLoginTap: toggle);
        }
      },
    );
  }
}
