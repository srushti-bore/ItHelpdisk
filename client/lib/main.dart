import 'package:flutter/material.dart';
import 'package:it_helpdesk_client/app/router.dart';
import 'package:it_helpdesk_client/app/theme.dart';
import 'package:it_helpdesk_client/features/auth/auth_controller.dart';
import 'package:it_helpdesk_client/shared/constants/app_constants.dart';
import 'package:provider/provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthController()),
      ],
      child: const AIITHelpdeskApp(),
    ),
  );
}

class AIITHelpdeskApp extends StatelessWidget {
  const AIITHelpdeskApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = context.watch<AuthController>();
    final router = createRouter(authController);

    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      routerConfig: router,
    );
  }
}
