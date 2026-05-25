import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/anomaly_result.dart';
import '../blocs/transactions/transactions_bloc.dart';
import '../blocs/transactions/transactions_event.dart';
import '../blocs/ai_chat/ai_chat_bloc.dart';
import '../blocs/anomaly/anomaly_bloc.dart';
import '../blocs/anomaly/anomaly_event.dart';
import '../blocs/analytics/analytics_bloc.dart';
import '../screens/home/home_screen.dart';
import '../screens/auth/sign_in_screen.dart';
import '../screens/auth/sign_up_screen.dart';
import '../screens/onboarding/onboarding_screen.dart';
import '../screens/add_expense/add_expense_screen.dart';
import '../screens/transactions/transactions_screen.dart';
import '../screens/analytics/analytics_screen.dart';
import '../screens/ai_assistant/ai_assistant_screen.dart';
import '../screens/anomaly_detail/anomaly_detail_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../../core/di/service_locator.dart';

class AppRouter {
  static const String initialRoute  = '/';
  static const String home          = '/home';
  static const String signIn        = '/sign-in';
  static const String signUp        = '/sign-up';
  static const String onboarding    = '/onboarding';
  static const String addExpense    = '/add-expense';
  static const String transactions  = '/transactions';
  static const String analytics     = '/analytics';
  static const String aiAssistant   = '/ai-assistant';
  static const String anomalyDetail = '/anomaly-detail';
  static const String profile       = '/profile';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case initialRoute:
      case signIn:
        return _fade(const SignInScreen());

      case signUp:
        return _slide(const SignUpScreen());

      case onboarding:
        return _fade(const OnboardingScreen());

      case home:
        return _fade(
          MultiBlocProvider(
            providers: [
              BlocProvider(
                create: (_) => sl<TransactionsBloc>()..add(const LoadTransactions()),
              ),
              BlocProvider(create: (_) => sl<AiChatBloc>()),
              BlocProvider(
                create: (_) => sl<AnomalyBloc>()..add(const CheckAnomalies()),
              ),
              BlocProvider(create: (_) => sl<AnalyticsBloc>()),
            ],
            child: const HomeScreen(),
          ),
        );

      case addExpense:
        return _slide(const AddExpenseScreen());

      case transactions:
        return _slide(const TransactionsScreen());

      case analytics:
        return _slide(const AnalyticsScreen());

      case aiAssistant:
        return _slide(const AiAssistantScreen());

      case anomalyDetail:
        final result = settings.arguments as AnomalyResult;
        return _slide(AnomalyDetailScreen(result: result));

      case profile:
        return _slide(const ProfileScreen());

      default:
        return _fade(const SignInScreen());
    }
  }

  // ── Transitions ───────────────────────────────────────────────

  static PageRoute _fade(Widget page) => PageRouteBuilder(
        pageBuilder: (_, __, ___) => page,
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
        transitionDuration: const Duration(milliseconds: 250),
      );

  static PageRoute _slide(Widget page) => PageRouteBuilder(
        pageBuilder: (_, __, ___) => page,
        transitionsBuilder: (_, animation, __, child) => SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1.0, 0.0),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
          child: child,
        ),
        transitionDuration: const Duration(milliseconds: 250),
      );
}
