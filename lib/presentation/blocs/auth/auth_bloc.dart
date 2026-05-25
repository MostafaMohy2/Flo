import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _repo;

  AuthBloc(this._repo) : super(const AuthInitial()) {
    on<AppStarted>(_onAppStarted);
    on<SignInRequested>(_onSignIn);
    on<SignUpRequested>(_onSignUp);
    on<SignOutRequested>(_onSignOut);
  }

  Future<void> _onAppStarted(AppStarted event, Emitter emit) async {
    emit(const AuthLoading());
    try {
      final user = await _repo.getSignedInUser();
      if (user != null) {
        emit(AuthAuthenticated(user));
      } else {
        emit(const AuthUnauthenticated());
      }
    } catch (_) {
      emit(const AuthUnauthenticated());
    }
  }

  Future<void> _onSignIn(SignInRequested event, Emitter emit) async {
    emit(const AuthLoading());
    try {
      final user = await _repo.signIn(
        email:    event.email,
        password: event.password,
      );
      emit(AuthAuthenticated(user));
    } catch (e) {
      emit(AuthFailure(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onSignUp(SignUpRequested event, Emitter emit) async {
    emit(const AuthLoading());
    try {
      final user = await _repo.signUp(
        name:     event.name,
        email:    event.email,
        password: event.password,
      );
      emit(AuthAuthenticated(user));
    } catch (e) {
      emit(AuthFailure(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onSignOut(SignOutRequested event, Emitter emit) async {
    await _repo.signOut();
    emit(const AuthUnauthenticated());
  }
}
