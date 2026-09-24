const fs = require('fs');
let code = fs.readFileSync('lib/main.dart', 'utf8');

// 1. Add imports
code = code.replace(
  "import 'package:flutter/material.dart';",
  "import 'package:flutter/material.dart';\nimport 'package:flutter_localizations/flutter_localizations.dart';\nimport 'package:dt_trade_app/l10n/app_localizations.dart';"
);

// 2. Add Locale state to EngulfingMasterApp
code = code.replace(
  "ThemeMode _themeMode = ThemeMode.light;",
  "ThemeMode _themeMode = ThemeMode.light;\n  Locale _locale = const Locale('zh');\n\n  void _setLocale(Locale locale) {\n    setState(() {\n      _locale = locale;\n    });\n  }"
);

// 3. Add localizationsDelegates and supportedLocales to MaterialApp
code = code.replace(
  "debugShowCheckedModeBanner: false,",
  "debugShowCheckedModeBanner: false,\n      locale: _locale,\n      localizationsDelegates: AppLocalizations.localizationsDelegates,\n      supportedLocales: AppLocalizations.supportedLocales,"
);

// 4. Pass setLocale to MainScreen
code = code.replace(
  "home: MainScreen(\n          toggleTheme: _toggleTheme, isDark: _themeMode == ThemeMode.dark),",
  "home: MainScreen(\n          toggleTheme: _toggleTheme,\n          isDark: _themeMode == ThemeMode.dark,\n          setLocale: _setLocale,\n          currentLocale: _locale,\n        ),"
);

// 5. Add setLocale to MainScreen constructor
code = code.replace(
  "final bool isDark;",
  "final bool isDark;\n  final Function(Locale) setLocale;\n  final Locale currentLocale;"
);
code = code.replace(
  "const MainScreen(\n      {super.key, required this.toggleTheme, required this.isDark});",
  "const MainScreen({\n    super.key,\n    required this.toggleTheme,\n    required this.isDark,\n    required this.setLocale,\n    required this.currentLocale,\n  });"
);

// 6. Add Language Dropdown to AppBar in _MainScreenState
const langButton = `
          PopupMenuButton<String>(
            icon: const Icon(Icons.language, color: Color(0xFFF59E0B)),
            onSelected: (String code) {
              widget.setLocale(Locale(code));
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'zh',
                child: Text('中文 (Chinese)'),
              ),
              const PopupMenuItem<String>(
                value: 'en',
                child: Text('English'),
              ),
              const PopupMenuItem<String>(
                value: 'ms',
                child: Text('Bahasa Melayu'),
              ),
            ],
          ),`;

code = code.replace(
  "IconButton(\n              icon: widget.isDark",
  langButton + "\n          IconButton(\n              icon: widget.isDark"
);

// 7. Translate BottomNavigationBar
code = code.replace("label: '首页'", "label: AppLocalizations.of(context)!.navHome");
code = code.replace("label: '组合防呆'", "label: AppLocalizations.of(context)!.navRisk");
code = code.replace("label: '双轨手数'", "label: AppLocalizations.of(context)!.navDual");
code = code.replace("label: '吞没狙击'", "label: AppLocalizations.of(context)!.navSniper");
code = code.replace("label: '复利走势'", "label: AppLocalizations.of(context)!.navTrend");

// 8. Translate AppBar Title
code = code.replace(
  "title: Row(\n            children: [\n              Container(",
  "title: Row(\n            children: [\n              Container("
); // Just finding the title
code = code.replace("const Text('双轨风控大师 Pro')", "Text(AppLocalizations.of(context)!.appTitle)");

fs.writeFileSync('lib/main.dart', code);
console.log("Successfully injected localization framework into main.dart");
