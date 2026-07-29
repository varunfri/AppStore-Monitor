import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../../../dashboard/presentation/screens/app_list_screen.dart';
import '../providers/auth_provider.dart';
import 'config_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        if (authProvider.isLoading) {
          return const CupertinoPageScaffold(
            child: Center(
              child: CupertinoActivityIndicator(radius: 14),
            ),
          );
        }

        if (authProvider.isAuthenticated) {
          return const AppListScreen();
        } else {
          return const ConfigScreen();
        }
      },
    );
  }
}
