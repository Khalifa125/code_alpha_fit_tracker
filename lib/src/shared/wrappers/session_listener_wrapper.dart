import 'package:fit_tracker/src/imports/core_imports.dart';
import 'package:fit_tracker/src/imports/packages_imports.dart';

import 'package:fit_tracker/src/features/auth/presentation/providers/session_provider.dart';


class SessionListenerWrapper extends ConsumerWidget {
  final Widget child;
  const SessionListenerWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<SessionState>(sessionProvider, (prev, next) {
      if (next.status != SessionStatus.unknown) {
        FlutterNativeSplash.remove();
        try {
          if (next.status == SessionStatus.authenticated) {
            context.go(AppRoutes.home);
          } else if (next.status == SessionStatus.unauthenticated) {
            context.go(AppRoutes.onboarding);
          }
        } catch (_) {
          // GoRouter not available, ignore
        }
      }
    });

    return child;
  }
}
