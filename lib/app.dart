import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/config/flavor_config.dart';
import 'core/config/interface_mode.dart';
import 'core/theme/usayd_theme.dart';
import 'features/home/presentation/screens/home_screen.dart';

class UsaydApp extends StatefulWidget {
  final InterfaceMode initialMode;

  const UsaydApp({super.key, this.initialMode = InterfaceMode.pro});

  @override
  State<UsaydApp> createState() => _UsaydAppState();
}

class _UsaydAppState extends State<UsaydApp> {
  late InterfaceMode _currentMode;

  @override
  void initState() {
    super.initState();
    _currentMode = widget.initialMode;
  }

  void _onModeChanged(InterfaceMode newMode) {
    setState(() {
      _currentMode = newMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'أكاديمية أُسَيْد',
      debugShowCheckedModeBanner: FlavorConfig.isDev,
      theme: UsaydTheme.light(_currentMode),
      darkTheme: UsaydTheme.dark(_currentMode),
      themeMode: ThemeMode.light,
      locale: const Locale('ar'),
      supportedLocales: const [Locale('ar'), Locale('en')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child ?? const SizedBox.shrink(),
        );
      },
      home: HomeScreen(
        currentMode: _currentMode,
        onModeChanged: _onModeChanged,
      ),
    );
  }
}
