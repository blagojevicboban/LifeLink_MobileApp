import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'providers/sensor_provider.dart';
import 'core/app_theme.dart';
import 'core/localization.dart';
import 'screens/dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Removed Firebase initialization
  // await Firebase.initializeApp();
  runApp(const LifeLinkApp());
}

class LifeLinkApp extends StatelessWidget {
  const LifeLinkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => SensorProvider())],
      child: Consumer<SensorProvider>(
        builder: (context, provider, child) {
          return MaterialApp(
            title: 'LifeLink Companion',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.theme,
            locale: provider.locale != null ? Locale(provider.locale!) : null,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [Locale('en', ''), Locale('sr', '')],
            home: const DashboardScreen(),
          );
        },
      ),
    );
  }
}
