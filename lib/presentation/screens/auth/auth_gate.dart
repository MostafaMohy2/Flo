import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/theme_extensions.dart';
import '../../../core/di/service_locator.dart';
import '../../blocs/ai_chat/ai_chat_bloc.dart';
import '../../blocs/analytics/analytics_bloc.dart';
import '../../blocs/anomaly/anomaly_bloc.dart';
import '../../blocs/anomaly/anomaly_event.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_state.dart';
import '../../blocs/transactions/transactions_bloc.dart';
import '../../blocs/transactions/transactions_event.dart';
import '../home/home_screen.dart';
import 'sign_in_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthInitial || state is AuthLoading) {
          return const _SplashScreen();
        }
        if (state is AuthAuthenticated) {
          return const _AppShell();
        }
        // AuthUnauthenticated or AuthFailure
        return const SignInScreen();
      },
    );
  }
}

/// Provides all app-level blocs only when the user is authenticated.
/// Disposing these blocs on sign-out happens automatically because
/// [_AppShell] is removed from the tree when AuthBloc emits [AuthUnauthenticated].
class _AppShell extends StatelessWidget {
  const _AppShell();

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => sl<TransactionsBloc>()..add(const LoadTransactions()),
        ),
        BlocProvider(
          create: (_) => sl<AiChatBloc>(),
        ),
        BlocProvider(
          create: (_) => sl<AnomalyBloc>()..add(const CheckAnomalies()),
        ),
        BlocProvider(
          create: (_) => sl<AnalyticsBloc>(),
        ),
      ],
      child: const HomeScreen(),
    );
  }
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Scaffold(
      backgroundColor: palette.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.account_balance_wallet_outlined,
                size: 48, color: palette.primary),
            const SizedBox(height: 16),
            CircularProgressIndicator(
              color: palette.primary,
              strokeWidth: 2,
            ),
          ],
        ),
      ),
    );
  }
}
