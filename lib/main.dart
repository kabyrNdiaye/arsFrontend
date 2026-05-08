import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'screens/auth/accueil.dart';
import 'providers/auth_provider.dart';
import 'providers/language_provider.dart';
import 'providers/mission_provider.dart';
import 'providers/recipe_provider.dart';
import 'providers/notification_provider.dart';
import 'providers/document_provider.dart';
import 'services/notification_service.dart';
import 'services/token_service.dart';
import 'services/api_service.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('fr_FR', null);
  await NotificationService.init();
  final token = await TokenService.get();
  if (token != null) ApiService().setToken(token);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
        ChangeNotifierProvider(create: (_) => MissionProvider()),
        ChangeNotifierProvider(create: (_) => RecipeProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => DocumentProvider()),
      ],
      child: Consumer<LanguageProvider>(
        builder: (context, langProvider, child) {
          return MaterialApp(
            title: 'ARS App',
            theme: appTheme(),
            home: AccueilScreen(),
            debugShowCheckedModeBanner: false,
            locale: Locale(langProvider.currentLanguage),
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('fr', 'FR'),
              Locale('en', 'US'),
              Locale('es', 'ES'),
            ],
          );
        },
      ),
    );
  }
}